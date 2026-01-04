function RectsIntersect(a as Object, b as Object) as Boolean
    if a.x + a.w < b.x then return false
    if a.x > b.x + b.w then return false
    if a.y + a.h < b.y then return false
    if a.y > b.y + b.h then return false
    return true
end function
