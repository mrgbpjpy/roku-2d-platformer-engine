function LoadWorld()  as Object
    	world = {}
	
    	world.platforms = []

	' Ground
	world.platforms.Push({x:500, y:600, w:200, h: 30, type: "PlatformA",  topOffset: 30})
	world.platforms.Push({x:700, y:600, w:200, h: 30, type: "PlatformA",  topOffset: 30})
	world.platforms.Push({x:900, y:600, w:200, h: 30, type: "PlatformA",  topOffset: 30})
	world.platforms.Push({x:1500, y:600, w:200, h: 30, type: "PlatformA",  topOffset: 30})
	world.platforms.Push({x:1700, y:600, w:200, h: 30, type: "PlatformA",  topOffset: 30})
	world.platforms.Push({x:1900, y:600, w:200, h: 30, type: "PlatformA",  topOffset: 30})
	world.platforms.Push({x:2100, y:655, w:255, h: 30, type:"PlatformA",   topOffset: 30})
	world.platforms.Push({x:3000, y:600, w:200, h: 30, type: "PlatformA",  topOffset: 30})
	world.platforms.Push({x:3200, y:600, w:200, h: 30, type: "PlatformA",  topOffset: 30})
	world.platforms.Push({x:4200, y:600, w:200, h: 30, type: "PlatformA",  topOffset: 30})
	world.platforms.Push({x:4400, y:600, w:200, h: 30, type: "PlatformA",  topOffset: 30})

	'Floating Platforms
	world.platforms.Push({x:700, y:500, w:200, h: 20, type: "PlatformB", topOffset: 30 })
	world.platforms.Push({x:900, y:400, w:200, h: 20, type: "PlatformC", topOffset: 30 })
	world.platforms.Push({x:1150, y:300, w:200, h: 20, type: "PlatformB", topOffset: 30 })
	world.platforms.Push({x:1500, y:200, w:200, h: 20, type: "PlatformC", topOffset: 30 })
	world.platforms.Push({x:1720, y:200, w:200, h: 20, type: "PlatformA", topOffset: 30 })
	world.platforms.Push({x:2000, y:400, w:200, h: 20, type: "PlatformB", topOffset: 30 })
	world.platforms.Push({x:2150, y:300, w:200, h: 20, type: "PlatformB", topOffset: 30 })
	world.platforms.Push({x:2500, y:200, w:200, h: 20, type: "PlatformC", topOffset: 30 })
	world.platforms.Push({x:2720, y:200, w:200, h: 20, type: "PlatformC", topOffset: 30 })
	world.platforms.Push({x:3000, y:400, w:200, h: 20, type: "PlatformA", topOffset: 30 })
	world.platforms.Push({x:3300, y:200, w:200, h: 20, type: "PlatformB", topOffset: 30 })
	world.platforms.Push({x:3500, y:300, w:200, h: 20, type: "PlatformC", topOffset: 30 })
	world.platforms.Push({x:3750, y:400, w:200, h: 20, type: "PlatformB", topOffset: 30 })
	world.platforms.Push({x:4000, y:500, w:200, h: 20, type: "PlatformC", topOffset: 30 })

   
    return world
end function
