class_name YBMonthScenery
extends RefCounted

## Original seasonal landmarks over the shared distant landscape library.
## No scenery in this component creates collision or covers playable top caps.
const TYPES=["wheat","harvest_cart","storm_beacon","boathouse","copper_tree","flood_marker","snow_pine","winter_cabin","thaw_pool","snowdrop","blossom_tree","garden_arch","flower_meadow"]
static var scenes: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://content/month_scenes.json"))
static func block(n: Node2D, at: Vector2, size: Vector2, tint: String) -> void:
	n.draw_rect(Rect2(at.round(),size),Color(tint))
static func background(n: Node2D, key: String, cam: float, time: float) -> void:
	var s: Dictionary=scenes[key]
	var plate=YBLandscape.texture("res://art/"+s.plate+".png")
	if plate: n.draw_texture_rect(plate,Rect2(-140-sin(cam*.00016)*130,-48,1560,878),false,Color(s.tint))
	if key=="july":
		for radius in [102,90,78]: n.draw_circle(Vector2(994,162),radius,Color(1,.87,.47,.09))
		n.draw_circle(Vector2(994,162),64,Color("ffe1a0"))
		for i in 4:
			var x=fposmod(i*438-cam*.23,1720)-100
			YBLandscape.mill(n,Vector2(x,515),time,.75)
	elif key=="august" or key=="november":
		var clouds=YBLandscape.texture("res://art/storm_clouds.png")
		if clouds: n.draw_texture_rect(clouds,Rect2(-60+sin(time*.04)*20,-100,1400,400),false,Color(1,.9,.93,.6 if key=="august" else .86))
		if key=="august": n.draw_circle(Vector2(192,294),47,Color(1,.7,.42,.65))
		for band in range(0,145,5): n.draw_rect(Rect2(0,540+band,1280,5),Color(.28,.49,.54,.14+band*.0015))
		for i in 30:
			var x=fposmod(i*113-time*6-cam*.29,1380)-50
			n.draw_line(Vector2(x,550+i%9*11),Vector2(x+30+i%4*10,550+i%9*11),Color(.73,.8,.75,.19),2)
	elif key=="april":
		var colors=["eac0b3","e7d9a4","b8d5a6","a6d1cd","b1bddb","c4b2d1"]
		for i in 6: n.draw_arc(Vector2(845,532),350-i*9,PI,TAU,80,Color(Color(colors[i]),.48),8)
	elif key=="december":
		# A gradual snowline: the far end visibly accumulates more white.
		n.draw_rect(Rect2(0,0,1280,720),Color(.83,.88,.93,clampf(cam/8000,0,.22)))
	elif key=="february":
		for i in 12:
			var x=fposmod(i*173-cam*.2,1600)-120
			n.draw_line(Vector2(x,567+i%3*14),Vector2(x+90,567+i%3*14),Color(.47,.66,.64,.28),5)
	elif key=="may":
		for i in 5:
			var x=fposmod(i*371-cam*.28,1700)-80
			props(n,{"type":"garden_arch","x":x,"y":570,"width":135,"height":150},time)

static func weather(n: Node2D, key: String, cam: float, time: float, rain_floor: float=780.0) -> void:
	var weather_type: String=scenes[key].weather
	for i in (62 if weather_type in ["rain","snow","storm"] else 32):
		var rain=weather_type in ["rain","storm","showers"]
		var speed=220 if rain else 22
		var at=Vector2(fposmod(i*179.7+time*(42 if rain else 13)-cam*.62,1360)-40,fposmod(i*83.3+time*speed,780)-30)
		if rain and at.y>rain_floor-14: continue
		if weather_type=="pollen": block(n,at,Vector2(2,2),"dfd69b")
		elif rain: n.draw_line(at,at+Vector2(-4,12),Color(.8,.88,.91,.23 if key!="november" else .38),1)
		elif weather_type in ["snow","thaw"]:
			if weather_type=="thaw" and i%3!=0: continue
			n.draw_rect(Rect2(at.round(),Vector2(2+i%2,2)),Color(1,1,1,.65))
		else:
			at.x+=sin(time+i)*14
			var tint=Color("d9a068") if weather_type=="leaves" else Color("ead4d2")
			n.draw_line(at,at+Vector2(4,2+sin(time+i)*3),Color(tint,.6),2)

static func props(n: Node2D, d: Dictionary, time: float) -> void:
	var at=Vector2(d.x,d.y);var w=float(d.get("width",180));var h=float(d.get("height",160))
	match str(d.type):
		"wheat":
			for i in int(w/9):
				var root=at+Vector2(i*9,0);var height=h*(.32+YBLandscape.hash_value(i+d.x)*.35)
				var top=root+Vector2(roundf(sin(time*1.5+i*.22)*5),-height)
				n.draw_line(root,top,Color("9b965c"),2)
				for j in 4:
					block(n,top+Vector2(-4,-j*5),Vector2(4,3),"c5b878");block(n,top+Vector2(2,-j*5-2),Vector2(4,3),"dace8d")
		"harvest_cart":
			for x in [25,w-30]:
				n.draw_circle(at+Vector2(x,-15),22,Color("57624e"));n.draw_circle(at+Vector2(x,-15),16,Color("979474"),false,3)
				for j in 6: n.draw_line(at+Vector2(x,-15),at+Vector2(x,-15)+Vector2.from_angle(j*TAU/6)*15,Color("868970"),2)
			block(n,at+Vector2(0,-65),Vector2(w,34),"8e9670")
			for x in range(8,int(w)-8,36):
				block(n,at+Vector2(x,-100),Vector2(33,35),"bdb47c");block(n,at+Vector2(x+7,-100),Vector2(3,35),"8d9067")
		"copper_tree","blossom_tree":
			n.draw_line(at,at-Vector2(5,h*.74),Color("666855"),12)
			for j in 7:
				var tip=at+Vector2((j-3)*w/8,-h*.53-absf(sin(j))*h*.3)
				n.draw_line(at-Vector2(2,h*.38),tip,Color("7b7b5d"),5)
				var tint=("b77a51" if j%2 else "d5a569") if d.type=="copper_tree" else ("d9b8bd" if j%2 else "e6d0c9")
				YBDayDecor.leaf(n,tip,w*.36,h*.28,tint)
		"storm_beacon","flood_marker":
			block(n,at-Vector2(4,h),Vector2(8,h),"71847c")
			for y in range(12,int(h),18):block(n,at+Vector2(-4,-y),Vector2(15,3),"b4bb9a")
			block(n,at+Vector2(-18,-h-26),Vector2(36,31),"546c69")
			block(n,at+Vector2(-12,-h-20),Vector2(24,19),"d8bd81")
			n.draw_circle(at-Vector2(0,h+10),32,Color(.96,.77,.37,.065))
			if d.type=="storm_beacon":
				n.draw_colored_polygon(PackedVector2Array([at+Vector2(4,-h+20),at+Vector2(63+sin(time)*6,-h+32),at+Vector2(4,-h+46)]),Color("bc9c83"))
		"boathouse","winter_cabin":
			var snow=d.type=="winter_cabin"
			block(n,at-Vector2(0,h*.64),Vector2(w,h*.64),"708582" if not snow else "7b8983")
			for x in range(8,int(w),18):block(n,at+Vector2(x,-h*.61),Vector2(2,h*.59),"8c9d90")
			n.draw_colored_polygon(PackedVector2Array([at+Vector2(-17,-h*.64),at+Vector2(w*.5,-h),at+Vector2(w+17,-h*.64)]),Color("dae2df" if snow else "657c7c"))
			for x in range(25,int(w)-30,64):
				block(n,at+Vector2(x,-h*.5),Vector2(29,34),"b9c5b6");block(n,at+Vector2(x+4,-h*.5+4),Vector2(21,26),"aabcaf" if not snow else "d8c69d")
			block(n,at+Vector2(w*.5-18,-58),Vector2(36,58),"536d6a")
		"snow_pine":
			block(n,at+Vector2(-5,-h),Vector2(10,h),"788481")
			for j in 5:
				var y=-h+j*h*.15;var span=w*(.22+j*.15)
				var poly=PackedVector2Array([at+Vector2(0,y-25),at+Vector2(span*.5,y+h*.33),at+Vector2(-span*.5,y+h*.33)])
				n.draw_colored_polygon(poly,Color("76918b"))
				n.draw_line(poly[0],poly[1]-Vector2(8,7),Color("d3e0db"),5)
		"thaw_pool":
			YBScenery.cluster(n,at-Vector2(0,4),w,16,Color("7fa9b0"))
			for i in int(w/25):block(n,at+Vector2(-w*.4+i*25,-8+sin(time+i)*2),Vector2(16,2),"bdd8d3")
		"snowdrop":
			for i in int(w/15):
				var root=at+Vector2(i*15,0);var height=12+i%4*6
				n.draw_line(root,root-Vector2(-3,height),Color("819d77"),2);block(n,root+Vector2(1,-height),Vector2(6,7),"e4ede0")
		"garden_arch":
			for side in [0,w]:block(n,at+Vector2(side,-h),Vector2(9,h),"869e83")
			for y in range(12,int(h),24):
				for side in [0,w-16]:block(n,at+Vector2(side,-y),Vector2(24,3),"9bac8f")
			var points=PackedVector2Array()
			for j in 19: points.append(at+Vector2(w*.5+cos(PI+j*PI/18)*w*.5,-h+sin(PI+j*PI/18)*h*.23))
			n.draw_polyline(points,Color("86a07c"),10)
			for j in range(0,points.size(),2):
				YBDayDecor.leaf(n,points[j],26,22,"74956e");block(n,points[j]+Vector2(3,-7),Vector2(7,5),"dfc2be")
		"flower_meadow":
			YBScenery.flowers(n,at,w,time,d.x,1.5)
