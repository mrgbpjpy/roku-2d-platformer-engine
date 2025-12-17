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

sub debugFrame(tick, state, x, y, velX, velY)
    print "[FRAME " + tick.ToStr() + "] state=" + state + " x=" + x.ToStr() + " y=" + y.ToStr() + " velX=" + velX.ToStr() + " velY=" + velY.ToStr()
end sub


' ==========================================================
' MAIN
' ==========================================================

sub main()

    ' ------------------------------
    ' CONSTANTS
    ' ------------------------------
    SCREEN_W = 1280
    SCREEN_H = 720

    WALK_ACCEL = 0.6
    MAX_SPEED  = 6
    FRICTION   = 0.85
    HOLD_TIMEOUT = 0.12

    GRAVITY = 1.2
    JUMP_VELOCITY = -30

    GROUND_Y = 380
    HALF_WIDTH = 50

    MIN_X = HALF_WIDTH
    MAX_X = SCREEN_W - HALF_WIDTH

    ' ------------------------------
    ' SCREEN
    ' ------------------------------
    screen = CreateObject("roScreen", true, SCREEN_W, SCREEN_H)
    screen.SetAlphaEnable(true)

    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)

    ' ------------------------------
    ' SPRITES
    ' ------------------------------
    idleFrames = loadFrames("pkg:/images/Mickey/idle_2/idle_", 11)
    walkFrames = loadFrames("pkg:/images/Mickey/walk/walk_", 12)
    jumpFrames = loadFrames("pkg:/images/Mickey/jump/jump_", 6) ' adjust count

    currentFrames = idleFrames
    frameIndex = 0
    animSpeed = 6
    tick = 0

    ' ------------------------------
    ' PLAYER STATE
    ' ------------------------------
    x = 300
    y = GROUND_Y
    velX = 0
    velY = 0

    facing = 1
    onGround = true

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

        ' ------------------------------
        ' INPUT
        ' ------------------------------
        msg = port.GetMessage()
        while type(msg) = "roUniversalControlEvent"

            code = msg.GetInt()

            if code = 4 then ' LEFT
                lastLeftTime = now
                facing = -1

            else if code = 5 then ' RIGHT
                lastRightTime = now
                facing = 1

            else if code = 2 then ' UP (JUMP)
                jumpRequested = true

            else if code = 0 then ' BACK
                running = false
            end if

            msg = port.GetMessage()
        end while

        leftHeld  = (now - lastLeftTime)  < HOLD_TIMEOUT
        rightHeld = (now - lastRightTime) < HOLD_TIMEOUT

        ' ------------------------------
        ' HORIZONTAL PHYSICS
        ' ------------------------------
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

        x += velX

        ' Clamp to screen
        if x < MIN_X then x = MIN_X
        if x > MAX_X then x = MAX_X

        ' ------------------------------
        ' JUMP / GRAVITY
        ' ------------------------------
        if jumpRequested and onGround then
            velY = JUMP_VELOCITY
            onGround = false
            state = "jump"
            currentFrames = jumpFrames
            frameIndex = 0
        end if
        jumpRequested = false

        if not onGround then
            velY += GRAVITY
            y += velY

            if y >= GROUND_Y then
                y = GROUND_Y
                velY = 0
                onGround = true
            end if
        end if

        ' ------------------------------
        ' STATE MACHINE
        ' ------------------------------
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

        ' ------------------------------
        ' ANIMATION
        ' ------------------------------
        if tick mod animSpeed = 0 then
            frameIndex++
            if frameIndex >= currentFrames.Count() then
                frameIndex = 0
            end if
        end if

        ' ------------------------------
        ' DEBUG
        ' ------------------------------
        debugFrame(tick, state, x, y, velX, velY)

        ' ------------------------------
        ' RENDER
        ' ------------------------------
        screen.Clear(&h000000FF)
        screen.DrawTransformedObject(x, y, 0, facing, 1, currentFrames[frameIndex])
        screen.SwapBuffers()

        sleep(16)
    end while
end sub
