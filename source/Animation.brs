function LoadFrames(prefix as String, count as Integer) as Object
    frames = []

    for i = 0 to count - 1
        path = prefix + i.ToStr() + ".png"
        bmp = CreateObject("roBitmap", path)

        if bmp = invalid then
            print "ERROR: Missing sprite -> "; path
        else
            reg = CreateObject("roRegion", bmp, 0, 0, bmp.GetWidth(), bmp.GetHeight())
            reg.SetScaleMode(0)
            reg.SetPreTranslation(-bmp.GetWidth() / 2, -bmp.GetHeight())
            frames.Push(reg)
        end if
    end for

    return frames
end function


function CreateAnimation() as Object
    anim = {}

    anim.idleFrames = LoadFrames("pkg:/images/Mickey/idle_2/idle_", 11)
    anim.walkFrames = LoadFrames("pkg:/images/Mickey/walk/walk_", 12)
    anim.jumpFrames = LoadFrames("pkg:/images/Mickey/jump/jump_", 6)

    anim.currentFrames = anim.idleFrames
    anim.frameIndex = 0
    anim.speed = 6

    return anim
end function


sub ResolveAnimation(player as Object, anim as Object)
    if not player.onGround then
        anim.currentFrames = anim.jumpFrames
    else if player.velX <> 0 then
        anim.currentFrames = anim.walkFrames
    else
        anim.currentFrames = anim.idleFrames
    end if
end sub


sub AdvanceAnimation(anim as Object, tick as Integer)
    if anim.currentFrames = invalid then return

    if tick mod anim.speed = 0 then
        anim.frameIndex = anim.frameIndex + 1
        if anim.frameIndex >= anim.currentFrames.Count() then
            anim.frameIndex = 0
        end if
    end if
end sub
