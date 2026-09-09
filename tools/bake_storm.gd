extends SceneTree
# Code-authored pixel cloud bank for the June boss. No raster reference is modified.
func _initialize() -> void:
	var noise=FastNoiseLite.new()
	noise.seed=619;noise.frequency=0.038;noise.fractal_octaves=4
	var broad=FastNoiseLite.new()
	broad.seed=280; broad.frequency=0.012; broad.fractal_octaves=2
	var colors=[Color("23354b"),Color("2c4056"),Color("394d64"),Color("4b6075"),Color("61778a"),Color("8093a0"),Color("acb6b6"),Color("d1cdb1")]
	var im=Image.create(352,118,false,Image.FORMAT_RGBA8)
	for y in 118:
		for x in 352:
			var f=noise.get_noise_2d(x,y)
			var large=broad.get_noise_2d(x,y)
			var edge=80+sin(x*0.055)*5+sin(x*0.018)*12
			if y>edge:
				im.set_pixel(x,y,Color.TRANSPARENT)
				continue
			var light=maxf(0,1-absf(x-61)/99.0)*0.47+pow(float(y)/118,2)*0.19
			var k=clampi(int(2+(f*0.9+large*0.6+light)*7),0,7)
			im.set_pixel(x,y,colors[k])
	im.save_png("res://art/storm_clouds.png")
	print("Native pixel-cloud layer baked")
	quit()
