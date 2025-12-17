' ==========================================================
' UTILITIES
' ==========================================================

function loadFrames(prefix, count)
    frames = []
    for i = 0 to count - 1
        bmp = CreateObject("roBitmap", prefix + i.ToStr() + ".png")
        region = CreateObject("roRegion", bmp, 0, 0, bmp.GetWidth(), bmp.GetHeight())
        region.SetScaleMode(0)
        region.SetPreTranslation(-bmp.GetWidth() / 2, -bmp.GetHeight())
        frames.Push(region)
    end for
    return frames
end function

function getGroundY(groundMap, worldX, resolution)
    index = Int(worldX / resolution)
    if index < 0 then index = 0
    if index >= groundMap.Count() then index = groundMap.Count() - 1
    return groundMap[index]
end function

sub debugFrame(tick, state, worldX, screenX, y, velX, velY, cameraX)
    print "[FRAME " + tick.ToStr() + "] state=" + state + " worldX=" + worldX.ToStr() + " screenX=" + screenX.ToStr() + " y=" + y.ToStr() + " velX=" + velX.ToStr() + " velY=" + velY.ToStr() + " camX=" + cameraX.ToStr()
end sub

' ==========================================================
' MAIN
' ==========================================================

sub main()

    SCREEN_W = 1280
    SCREEN_H = 720

    WALK_ACCEL = 0.6
    MAX_SPEED  = 6
    FRICTION   = 0.85
    HOLD_TIMEOUT = 0.12

    GRAVITY = 1.2
    JUMP_VELOCITY = -30

    HALF_WIDTH = 50
    PLAYER_SCREEN_X = SCREEN_W / 2
    GROUND_MAP_RESOLUTION = 10

    ' ------------------------------
    ' SCREEN
    ' ------------------------------
    screen = CreateObject("roScreen", true, SCREEN_W, SCREEN_H)
    screen.SetAlphaEnable(true)
    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)

    ' ------------------------------
    ' BACKGROUND / WORLD
    ' ------------------------------
    bgBitmap = CreateObject("roBitmap", "pkg:/images/BG/BG.png")
    bgRegion = CreateObject("roRegion", bgBitmap, 0, 0, bgBitmap.GetWidth(), bgBitmap.GetHeight())
    WORLD_WIDTH = bgBitmap.GetWidth()

    ' ------------------------------
    ' GROUND MAP (LOWERED BY 100 PX)
    ' ------------------------------
    groundMap = []
    for x = 0 to WORLD_WIDTH step GROUND_MAP_RESOLUTION
        if x < 800 then
            groundMap.Push(420)   ' 360 + 100
        else if x < 1400 then
            groundMap.Push(460)
        else
            groundMap.Push(430)   ' 380 + 100
        end if
    end for

    ' ------------------------------
    ' SPRITES
    ' ------------------------------
    idleFrames = loadFrames("pkg:/images/Mickey/idle_2/idle_", 11)
    walkFrames = loadFrames("pkg:/images/Mickey/walk/walk_", 12)
    jumpFrames = loadFrames("pkg:/images/Mickey/jump/jump_", 6)

    currentFrames = idleFrames
    frameIndex = 0
    animSpeed = 6
    tick = 0

    ' ------------------------------
    ' PLAYER STATE
    ' ------------------------------
    playerWorldX = 300
    y = 460         ' matches ground
    velX = 0
    velY = 0
    facing = 1
    onGround = true
    cameraX = 0

    lastLeftTime  = -999.0
    lastRightTime = -999.0
    jumpRequested = false

    state = "idle"
    running = true

    clock = CreateObject("roTimespan")

    ' ======================================================
    ' GAME LOOP
    ' ======================================================
    while running

        tick++
        now = clock.TotalMilliseconds() / 1000.0

        ' INPUT
        msg = port.GetMessage()
        while type(msg) = "roUniversalControlEvent"
            code = msg.GetInt()
            if code = 4 then
                lastLeftTime = now
                facing = -1
            else if code = 5 then
                lastRightTime = now
                facing = 1
            else if code = 2 then
                jumpRequested = true
            else if code = 0 then
                running = false
            end if
            msg = port.GetMessage()
        end while

        leftHeld  = (now - lastLeftTime)  < HOLD_TIMEOUT
        rightHeld = (now - lastRightTime) < HOLD_TIMEOUT

        ' HORIZONTAL PHYSICS
        if leftHeld and not rightHeld then
            velX -= WALK_ACCEL
        else if rightHeld and not leftHeld then
            velX += WALK_ACCEL
        else
            velX *= FRICTION
        end if

        if abs(velX) < 0.15 then velX = 0
        if velX < -MAX_SPEED then velX = -MAX_SPEED
        if velX >  MAX_SPEED then velX =  MAX_SPEED

        playerWorldX += velX

        if playerWorldX < HALF_WIDTH then playerWorldX = HALF_WIDTH
        if playerWorldX > WORLD_WIDTH - HALF_WIDTH then
            playerWorldX = WORLD_WIDTH - HALF_WIDTH
        end if

        ' CAMERA
        cameraX = playerWorldX - PLAYER_SCREEN_X
        if cameraX < 0 then cameraX = 0
        if cameraX > WORLD_WIDTH - SCREEN_W then
            cameraX = WORLD_WIDTH - SCREEN_W
        end if

        ' JUMP
        if jumpRequested and onGround then
            velY = JUMP_VELOCITY
            onGround = false
            state = "jump"
            currentFrames = jumpFrames
            frameIndex = 0
        end if
        jumpRequested = false

        velY += GRAVITY
        y += velY

        groundY = getGroundY(groundMap, playerWorldX, GROUND_MAP_RESOLUTION)

        if y >= groundY then
            y = groundY
            velY = 0
            onGround = true
        end if

        ' STATE
        if onGround then
            if velX <> 0 then
                if state <> "walk" then
                    state = "walk"
                    currentFrames = walkFrames
                    frameIndex = 0
                end if
            else
                if state <> "idle" then
                    state = "idle"
                    currentFrames = idleFrames
                    frameIndex = 0
                end if
            end if
        end if

        ' ANIMATION
        if tick mod animSpeed = 0 then
            frameIndex++
            if frameIndex >= currentFrames.Count() then frameIndex = 0
        end if

        ' RENDER
        screen.Clear(&h000000FF)
        screen.DrawObject(-cameraX, 0, bgRegion)

        playerScreenX = playerWorldX - cameraX
        screen.DrawTransformedObject(playerScreenX, y, 0, facing, 1, currentFrames[frameIndex])
        ' DEBUG: draw ground collision line
        screen.DrawRect(playerScreenX - 20, groundY, 40, 4, &hFF0000FF)
        screen.SwapBuffers()
        sleep(16)
    end while
end sub
