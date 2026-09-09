extends SceneTree
# Original low-resolution material maps. Each surface has a small fixed palette.
func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute("res://art/materials")
	var noise=FastNoiseLite.new()
	noise.seed=8374;noise.frequency=0.10;noise.fractal_octaves=3
	var palettes={
		"earth":["3d382d","4b4030","584933","66563b","756545","82704b","96825a"],
		"rock":["454f52","53605f","677271","7b8580","92988b","a6ac9d","bac0b0"],
		"wood":["403d2e","514832","665338","7a6140","8e764e","a48b60","bba275"],
		"ice":["427788","518ba0","67a2b3","83bcc7","a4d3d8","c6e3e0","e1f2e6"],
		"snow":["91adb8","a7bdc5","beced0","d3deda","e3e8db","ecf0e3","f7f7ed"]}
	for kind in palettes:
		var im=Image.create(64,64,false,Image.FORMAT_RGB8)
		for y in 64:
			for x in 64:
				var f=noise.get_noise_2d(x,y)
				var k=clampi(int(3+f*5),0,6)
				match kind:
					"earth":
						if (x*7+y*3)%41<2: k=mini(6,k+1)
						if y%13==int(f*3+4): k=maxi(0,k-1)
					"rock":
						if absf(noise.get_noise_2d(x*0.7,y*1.3))<0.06: k=maxi(0,k-2)
					"wood":
						k=clampi(int(3+sin(y*0.9+noise.get_noise_2d(x*0.2,y)*3)*2),0,6)
						if y%17==0:k=0
					"ice":
						k=clampi(int(2+f*4),0,5)
						if posmod(x+int(y*0.7)+int(f*7),31)==0:k=6
					"snow":k=clampi(int(4+f*3),2,6)
				im.set_pixel(x,y,Color(palettes[kind][k]))
		im.save_png("res://art/materials/"+kind+".png")
	print("Five original pixel material maps baked")
	quit()
