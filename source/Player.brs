function CreatePlayer() as Object
    p = {}

    p.x = 650
    p.y = 300
    p.velX = 0
    p.velY = 0

    p.w = 64
    p.h = 96
    p.halfW = p.w / 2

    p.onGround = false
    p.facing = 1

    return p
end function

