sub DrawCreditsDialog(screen as Object, font as Object)
    dialogW = 800 : dialogH = 400
    x = (1280 - dialogW) / 2 : y = (720 - dialogH) / 2

    screen.DrawRect(x, y, dialogW, dialogH, &h202020FF)
    screen.DrawRect(x, y, dialogW, 4, &hFFFFFFFF)

    screen.DrawText("Developer Info", x + 220, y + 40, &hFFFFFFFF, font)
    screen.DrawText("Erick Esquilin", x + 240, y + 120, &hFFFFFFFF, font)
    screen.DrawText("Mrgbpjpy@gmail.com", x + 190, y + 170, &hFFFFFFFF, font)

    btnW = 140 : btnH = 50
    btnX = x + (dialogW - btnW) / 2 : btnY = y + dialogH - 90
    screen.DrawRect(btnX, btnY, btnW, btnH, &hFFD700FF)
    screen.DrawText("OK", btnX + 45, btnY + 8, &h000000FF, font)
end sub


sub main()

    DEBUG_COLLISION = false

    SCREEN_W = 1280 : SCREEN_H = 720 : PLAYER_SCREEN_X = SCREEN_W / 2
    WALK_ACCEL = 1.2 : MAX_SPEED = 20 : FRICTION = 0.85
    GRAVITY = 1.2 : JUMP_VEL = -25 : HOLD_TIMEOUT = 0.12

    STATE_START = 0 : STATE_GAME = 1
    MENU_START = 0 : MENU_CREDITS = 1

    screen = CreateObject("roScreen", true, SCREEN_W, SCREEN_H)
    screen.SetAlphaEnable(true)
    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)

    font = CreateObject("roFontRegistry").GetDefaultFont(48, false, false)
    audio = CreateAudioManager()

    ' ============================
    ' LOAD BACKGROUNDS (ONCE)
    ' ============================
    bgSky = CreateObject("roBitmap", "pkg:/images/BG/Sky.png")
    bgCastle = CreateObject("roBitmap", "pkg:/images/BG/Castle.png")

    ' ============================
    ' LOAD PLATFORM IMAGES
    ' ============================
    platformImgs = {
    PlatformA: CreateObject("roBitmap", "pkg:/images/Platform/PlatformA.png")
    PlatformB: CreateObject("roBitmap", "pkg:/images/Platform/PlatformB.png")
    PlatformC: CreateObject("roBitmap", "pkg:/images/Platform/PlatformC.png")
}

    

    menuItems = ["START GAME", "CREDITS"]
    menuIndex = 0
    gameState = STATE_START
    dialogActive = false

    audio.PlayMusic("pkg:/sound/music/Menu_Music.mp3")

    ' ============================
    ' START MENU LOOP
    ' ============================
    while gameState = STATE_START

        screen.Clear(&h000000FF)
        if bgSky <> invalid then screen.DrawObject(0, 0, bgSky)
        if bgCastle <> invalid then screen.DrawObject(0, 0, bgCastle)

        screen.DrawText("MICKEY ADVENTURE", 450, 160, &h000000FF, font)

        for i = 0 to menuItems.Count() - 1
            color = &hFFFFFFFF : if i = menuIndex then color = &hFFD700FF
            screen.DrawText(menuItems[i], 520, 320 + (i * 60), color, font)
        end for

        if dialogActive then DrawCreditsDialog(screen, font)

        screen.SwapBuffers()

        msg = port.GetMessage()
        if type(msg) = "roUniversalControlEvent"
            code = msg.GetInt()
            if dialogActive
                if code = 6 or code = 0 then dialogActive = false
            else
                if code = 2 and menuIndex > 0 then menuIndex--
                if code = 3 and menuIndex < menuItems.Count() - 1 then menuIndex++
                if code = 6
                    if menuIndex = MENU_START then gameState = STATE_GAME : audio.PlayMusic("pkg:/sound/music/Main_Start.mp3")
                    if menuIndex = MENU_CREDITS then dialogActive = true
                end if
                if code = 0 then return
            end if
        end if

        sleep(16)
    end while

    ' ============================
    ' GAME INIT
    ' ============================
    world = LoadWorld() : player = CreatePlayer() : anim = CreateAnimation()
    clock = CreateObject("roTimespan")
    lastLeftTime = -999.0 : lastRightTime = -999.0
    cameraX = 0 : tick = 0 : running = true

    ' ============================
    ' GAME LOOP
    ' ============================
    while running

        tick++ : now = clock.TotalMilliseconds() / 1000.0

        msg = port.GetMessage()
        while msg <> invalid
            if type(msg) = "roUniversalControlEvent"
                code = msg.GetInt()
                if code = 4 then lastLeftTime = now
                if code = 5 then lastRightTime = now
                if code = 2 and player.onGround then audio.PlaySFX("pkg:/sound/sound_effects/cartoon_jump.mp3") : player.velY = JUMP_VEL : player.onGround = false
                if code = 0 then running = false
            end if
            msg = port.GetMessage()
        end while

        leftHeld = (now - lastLeftTime) < HOLD_TIMEOUT
        rightHeld = (now - lastRightTime) < HOLD_TIMEOUT

        if leftHeld and not rightHeld then player.velX -= WALK_ACCEL : player.facing = -1 else if rightHeld and not leftHeld then player.velX += WALK_ACCEL : player.facing = 1 else player.velX *= FRICTION
        if abs(player.velX) < 0.15 then player.velX = 0
        if player.velX < -MAX_SPEED then player.velX = -MAX_SPEED
        if player.velX > MAX_SPEED then player.velX = MAX_SPEED
        player.x += player.velX
        ' Apply gravity
        player.velY += GRAVITY
        player.y += player.velY
        player.onGround = false

        ' Platform collision
        for each plat in world.platforms

            collisionY = plat.y - plat.topOffset

            if player.x + player.halfW > plat.x and player.x - player.halfW < plat.x + plat.w
                if player.y - player.velY <= collisionY and player.y >= collisionY then
                    player.y = collisionY
                    player.velY = 0
                    player.onGround = true
                end if
            end if

        end for

        cameraX = player.x - PLAYER_SCREEN_X : if cameraX < 0 then cameraX = 0

        ResolveAnimation(player, anim) : AdvanceAnimation(anim, tick)

        ' ============================
        ' RENDER (PARALLAX)
        ' ============================
        screen.Clear(&h000000FF)

        skyX = -cameraX * 0.02 : castleX = -cameraX * 0.05
        if bgSky <> invalid then screen.DrawObject(skyX, 0, bgSky)
        if bgCastle <> invalid then screen.DrawObject(castleX, -250, bgCastle)

        for each plat in world.platforms
        screenX = plat.x - cameraX

            if DEBUG_COLLISION then
                screen.DrawRect(screenX, plat.y, plat.w, plat.h, &h888888FF)
                screen.DrawRect(screenX, plat.y, plat.w, 3, &hFF0000FF)
            else
                img = invalid
                if platformImgs.DoesExist(plat.type) then img = platformImgs[plat.type]
                if img <> invalid then screen.DrawObject(screenX, plat.y - img.GetHeight() + plat.h, img)
            end if
        end for


        if anim.currentFrames <> invalid and anim.frameIndex < anim.currentFrames.Count()
            screen.DrawTransformedObject(PLAYER_SCREEN_X, player.y, 0, player.facing, 1, anim.currentFrames[anim.frameIndex])
        end if

        screen.SwapBuffers()
        sleep(16)
    end while
end sub
