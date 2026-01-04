function LoadWorld()  as Object
    	world = {}
	
    	world.platforms = []

	' Ground
	world.platforms.Push({x:0, y:700, w:4000, h: 30 })

	'Floating Platforms
	world.platforms.Push({x:700, y:500, w:200, h: 20 })
	world.platforms.Push({x:900, y:400, w:180, h: 20 })
	world.platforms.Push({x:1150, y:300, w:220, h: 20 })
	world.platforms.Push({x:1500, y:200, w:180, h: 20 })

   
    return world
end function
