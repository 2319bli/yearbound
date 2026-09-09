class_name YBTerrainArt
extends RefCounted

static var styles: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://content/terrain_styles.json"))

static func palette(stage: Dictionary) -> Dictionary:
	return styles.get(stage.get("terrain_style",stage.season),styles.june)

static func ink(p: Dictionary, key: String) -> Color:
	return Color(p[key])

static func face(n: Node2D, rect: Rect2, p: Dictionary, seed_value: float) -> void:
	# Exact rectangular collision silhouette, restrained interior facets and a dark frame.
	n.draw_rect(rect,ink(p,"outline"))
	if rect.size.y<10: return
	var inner=Rect2(rect.position+Vector2(3,10),rect.size-Vector2(6,13))
	n.draw_rect(inner,ink(p,"soil"))
	for row in range(0,int(inner.size.y),26):
		for col in range(-32 if row%52==0 else 0,int(inner.size.x),70):
			var x=maxf(0,col+6)
			var w=minf(45+YBLandscape.hash_value(col+row+seed_value)*17,inner.size.x-x-4)
			var h=minf(15,inner.size.y-row-3)
			if w<8 or h<5: continue
			var at=inner.position+Vector2(x,row+2)
			var vertices=PackedVector2Array([at+Vector2(5,0),at+Vector2(w,0),at+Vector2(w-6,h),at+Vector2(0,h)])
			n.draw_colored_polygon(vertices,ink(p,"soil_light") if int(col+row)%3==0 else ink(p,"soil_dark"))
			if int(col+row)%3==0: n.draw_line(at+Vector2(6,0),at+Vector2(w-4,0),ink(p,"seam"),2)
	n.draw_rect(Rect2(rect.position+Vector2(3,15),Vector2(4,maxf(0,rect.size.y-21))),ink(p,"soil_light"))
	n.draw_rect(Rect2(rect.end-Vector2(8,rect.size.y-12),Vector2(5,maxf(0,rect.size.y-17))),ink(p,"soil_dark"))
	n.draw_rect(Rect2(rect.position+Vector2(3,rect.size.y-7),Vector2(rect.size.x-6,4)),ink(p,"soil_dark"))

static func cap(n: Node2D, rect: Rect2, p: Dictionary, frozen: bool=false) -> void:
	var at=rect.position
	var top=Color("f1f7e6") if frozen else ink(p,"top")
	var mid=Color("b6d6dc") if frozen else ink(p,"grass")
	var lower=Color("6e9dab") if frozen else ink(p,"grass_shadow")
	n.draw_rect(Rect2(at,Vector2(rect.size.x,3)),top)
	n.draw_rect(Rect2(at+Vector2(2,3),Vector2(rect.size.x-4,6)),mid)
	n.draw_rect(Rect2(at+Vector2(3,9),Vector2(rect.size.x-6,5)),lower)
	# Sparse scallops below the ledge never obscure its walkable top.
	for x in range(13,int(rect.size.x)-12,34):
		n.draw_rect(Rect2(at+Vector2(x,12),Vector2(9,4)),lower)
		n.draw_rect(Rect2(at+Vector2(x+2,9),Vector2(4,3)),mid)
	n.draw_rect(Rect2(at+Vector2(1,3),Vector2(2,10)),top.darkened(0.15))
	n.draw_rect(Rect2(at+Vector2(rect.size.x-3,3),Vector2(2,10)),lower)

static func platform(n: Node2D, platform_data: Dictionary, stage: Dictionary, time: float, camera_x: float=0) -> void:
	if platform_data.gone: return
	var d: Dictionary=platform_data.data
	var at: Vector2=platform_data.body.position
	if d.kind=="crumble" and platform_data.crumble>0: at.x+=sin(time*65)*2
	var rect=Rect2(at,Vector2(d.w,d.h))
	var p=palette(stage)
	if stage.get("grid_size",0)==48:
		for y in range(0,int(d.h),48):
			for x in range(maxi(0,floori((camera_x-80-at.x)/48)*48),mini(int(d.w),ceili((camera_x+1360-at.x)/48)*48),48):
				var surface=y==0
				if d.kind=="ground": surface=not platform_data.get("occupied",{}).has(YBLayoutDocument.key(Vector2i((at+Vector2(x,y))/48)-Vector2i(0,1)))
				tile(n,at+Vector2(x,y),d,stage,surface)
		return
	if d.kind=="block":
		obstacle(n,rect,str(d.get("material","stone")),p)
	elif d.kind in ["wood","moving"]:
		n.draw_rect(rect,ink(p,"outline"))
		n.draw_rect(Rect2(at+Vector2(3,5),Vector2(d.w-6,maxf(4,d.h-9))),ink(p,"wood"))
		for x in range(5,int(d.w)-6,28):
			var width=minf(24,d.w-x-4)
			n.draw_rect(Rect2(at+Vector2(x,6),Vector2(width,3)),ink(p,"wood_light"))
			n.draw_line(at+Vector2(x+width+1,5),at+Vector2(x+width+1,d.h-5),ink(p,"outline"),2)
			n.draw_line(at+Vector2(x+4,14),at+Vector2(x+width-4,14),ink(p,"wood_light").darkened(0.12),1)
			n.draw_rect(Rect2(at+Vector2(x+3,7),Vector2(2,2)),ink(p,"wood_top"))
		n.draw_rect(Rect2(at,Vector2(d.w,3)),ink(p,"wood_top"))
		n.draw_rect(Rect2(at+Vector2(2,3),Vector2(d.w-4,2)),ink(p,"wood_light"))
		n.draw_line(at+Vector2(3,d.h-5),at+Vector2(d.w-3,d.h-5),ink(p,"wood_light").darkened(0.2),2)
		for x in [8,float(d.w)-15]:
			n.draw_rect(Rect2(at+Vector2(x,5),Vector2(5,d.h-9)),ink(p,"outline"))
			n.draw_rect(Rect2(at+Vector2(x+1,8),Vector2(2,2)),Color("d4c896"))
		if d.kind=="moving":
			var center=at+Vector2(d.w/2,12)
			n.draw_colored_polygon(PackedVector2Array([center+Vector2(-5,0),center+Vector2(0,-4),center+Vector2(5,0),center+Vector2(0,4)]),ink(p,"wood_top"))
	elif d.kind=="crumble":
		n.draw_rect(Rect2(at,Vector2(d.w,3)),ink(p,"top"))
		n.draw_line(at+Vector2(1,9),at+Vector2(d.w-1,9),ink(p,"outline"),9)
		for x in range(4,int(d.w)-5,14):
			var v=at+Vector2(x,5)
			n.draw_colored_polygon(PackedVector2Array([v,v+Vector2(11,0),v+Vector2(9,10),v+Vector2(2,14),v+Vector2(-2,7)]),ink(p,"grass"))
			n.draw_line(v+Vector2(3,2),v+Vector2(3,9),ink(p,"top"),2)
	else:
		face(n,rect,p,float(d.x))
		if d.kind=="ice":
			n.draw_rect(Rect2(at+Vector2(3,5),Vector2(d.w-6,minf(d.h-9,25))),Color("659dac"))
			for x in range(13,int(d.w)-20,43):
				n.draw_polyline(PackedVector2Array([at+Vector2(x,7),at+Vector2(x+7,15),at+Vector2(x+4,21)]),Color("b9e7e8"),2)
			cap(n,rect,p,true)
		else: cap(n,rect,p,stage.season=="winter")
		if d.kind=="spring":
			for x in range(14,int(d.w)-7,23):
				var flower=at+Vector2(x,-6)
				for j in 5:
					var end=flower+Vector2.from_angle(j*TAU/5)*5
					n.draw_line(flower,end,Color("f2dd94"),4)
				n.draw_rect(Rect2(flower-Vector2(2,2),Vector2(4,4)),Color("b67d37"))

static func ground(n: Node2D, stage: Dictionary, cam: float) -> void:
	if stage.get("grid_size",0)==48:
		for x in range(int(floorf((cam-48)/48))*48,int(cam)+1392,48):
			for y in range(int(stage.ground.y),864,48):
				tile(n,Vector2(x,y),{"kind":"ground"},stage,y==int(stage.ground.y))
		return
	var p=palette(stage)
	var top=float(stage.ground.y)
	var left=maxf(-80,floorf((cam-80)/64)*64)
	var width=minf(float(stage.length)+80,left+1472)-left
	var rect=Rect2(left,top,width,900-top)
	# A continuous horizontal grass/snow cap, with earth filling to the screen bottom.
	n.draw_rect(rect,ink(p,"soil"))
	n.draw_rect(Rect2(left,top+14,width,12),ink(p,"soil_dark"))
	for x in range(int(left),int(left+width),64):
		var hash=YBLandscape.hash_value(x)
		for row in 3:
			var at=Vector2(x+hash*23,top+36+row*29)
			n.draw_rect(Rect2(at,Vector2(9+hash*9,3)),ink(p,"soil_light").darkened(.08))
	cap(n,rect,p,stage.season=="winter")

static func tile(n: Node2D, at: Vector2, data: Dictionary, stage: Dictionary, surface: bool=true) -> void:
	# One 48 x 48 visual unit, shared verbatim with the layout editor.
	var p=palette(stage)
	var kind=str(data.get("kind","ground"))
	var material=str(data.get("material","stone"))
	var rect=Rect2(at,Vector2(48,48))
	var fill=ink(p,"soil")
	var light=ink(p,"soil_light")
	var top=ink(p,"top")
	if kind in ["wood","moving"] or material=="log" and kind=="block":
		fill=ink(p,"wood");light=ink(p,"wood_light");top=ink(p,"wood_top")
	elif kind=="block" and material=="hay":
		fill=Color("ba9550");light=Color("d3b56b");top=Color("f3dc98")
	elif kind=="block":
		fill=Color("667877");light=Color("82958e");top=Color("d7dfc0")
	elif kind=="ice":
		fill=Color("649caf");light=Color("8fc7d4");top=Color("edfbf2")
	elif kind=="spring":
		fill=Color("477250");light=Color("6b965a");top=Color("f4dc8d")
	elif kind=="crumble":
		fill=Color("966744");light=Color("c58b50");top=Color("f2cd89")
		if data.get("surface","")=="ice": fill=Color("548d9e");light=Color("9dbbc5");top=Color("d6eced")
	n.draw_rect(rect,ink(p,"outline"))
	n.draw_rect(Rect2(at+Vector2(2,3),Vector2(44,42)),fill)
	n.draw_rect(Rect2(at+Vector2(3,4),Vector2(3,36)),light)
	n.draw_rect(Rect2(at+Vector2(6,4),Vector2(36,3)),light)
	n.draw_rect(Rect2(at+Vector2(42,5),Vector2(3,39)),fill.darkened(.25))
	n.draw_rect(Rect2(at+Vector2(4,42),Vector2(38,3)),fill.darkened(.25))
	if kind in ["wood","moving"] or kind=="block" and material=="log":
		for y in [16,29]: n.draw_line(at+Vector2(7,y),at+Vector2(40,y),fill.darkened(.3),2)
		for pos in [Vector2(9,10),Vector2(38,37)]: n.draw_rect(Rect2(at+pos,Vector2(3,3)),top)
	elif kind=="block" and material=="hay":
		for y in [14,22,30,38]: n.draw_line(at+Vector2(6,y),at+Vector2(40,y),light,2)
		n.draw_rect(Rect2(at+Vector2(20,4),Vector2(6,40)),Color("77613b"))
	elif kind=="ice":
		n.draw_polyline(PackedVector2Array([at+Vector2(17,12),at+Vector2(24,22),at+Vector2(20,35)]),top.darkened(.1),2)
	elif kind=="crumble":
		n.draw_polyline(PackedVector2Array([at+Vector2(26,7),at+Vector2(19,20),at+Vector2(28,29),at+Vector2(21,42)]),fill.darkened(.4),3)
	elif kind=="spring" or kind=="moving": pass
	else:
		n.draw_line(at+Vector2(12,19),at+Vector2(24,19),light,2)
		n.draw_line(at+Vector2(28,32),at+Vector2(37,32),fill.darkened(.2),2)
	if kind in ["spring","moving"]:
		var center=at+Vector2(24,24)
		n.draw_polyline(PackedVector2Array([center+Vector2(-8,4),center+Vector2(0,-4),center+Vector2(8,4)]),top,3)
	if surface:
		n.draw_rect(Rect2(at,Vector2(48,3)),top)
		if kind=="ground":
			n.draw_rect(Rect2(at+Vector2(2,3),Vector2(44,6)),Color("c5e4dd") if stage.season=="winter" else ink(p,"grass"))

static func obstacle(n: Node2D, rect: Rect2, material: String, p: Dictionary) -> void:
	var at=rect.position
	n.draw_rect(rect,ink(p,"outline"))
	if material=="hay":
		n.draw_rect(Rect2(at+Vector2(3,3),rect.size-Vector2(6,6)),Color("bc9756"))
		for y in range(8,int(rect.size.y)-4,7):
			n.draw_line(at+Vector2(4,y),at+Vector2(rect.size.x-5,y),Color("d2b469"),2)
		for x in [rect.size.x*.24,rect.size.x*.76]:
			n.draw_rect(Rect2(at+Vector2(x,3),Vector2(5,rect.size.y-6)),Color("705d42"))
		n.draw_rect(Rect2(at,Vector2(rect.size.x,3)),Color("f0d98d"))
	elif material=="log":
		n.draw_rect(Rect2(at+Vector2(3,3),rect.size-Vector2(6,6)),Color("79563d"))
		for y in range(9,int(rect.size.y)-4,10):
			n.draw_line(at+Vector2(4,y),at+Vector2(rect.size.x-14,y-2),Color("a0784c"),2)
		n.draw_rect(Rect2(at+Vector2(rect.size.x-17,4),Vector2(13,rect.size.y-8)),Color("b6945c"))
		for y in range(10,int(rect.size.y)-6,8): n.draw_line(at+Vector2(rect.size.x-13,y),at+Vector2(rect.size.x-7,y+3),Color("8b6b45"),2)
		n.draw_rect(Rect2(at,Vector2(rect.size.x,3)),Color("d3b17a"))
	else:
		n.draw_rect(Rect2(at+Vector2(3,3),rect.size-Vector2(6,6)),Color("6a7a77"))
		for row in range(0,int(rect.size.y)-7,22):
			n.draw_line(at+Vector2(3,row+22),at+Vector2(rect.size.x-4,row+22),Color("465958"),3)
			for x in range(15 if row%44 else 36,int(rect.size.x)-3,44):
				n.draw_line(at+Vector2(x,row+4),at+Vector2(x,row+22),Color("485c59"),3)
			n.draw_line(at+Vector2(5,row+5),at+Vector2(rect.size.x-6,row+5),Color("89968a"),2)
		n.draw_rect(Rect2(at,Vector2(rect.size.x,3)),Color("d2d9b5"))
	# A contact shadow anchors solid obstacles to the terrain underneath.
	n.draw_rect(Rect2(at+Vector2(0,rect.size.y-4),Vector2(rect.size.x,4)),ink(p,"outline"))

static func bramble(n: Node2D, rect: Rect2, season: String, direction: String="up") -> void:
	var edge=Color("edb788") if season!="winter" else Color("ddf0ed")
	var body=Color("68494b") if season!="winter" else Color("6b9fb3")
	var length=rect.size.y if direction in ["left","right"] else rect.size.x
	var depth=rect.size.x if direction in ["left","right"] else rect.size.y
	for x in range(0,int(length)-2,12):
		var width=minf(12,length-x)
		var triangle=PackedVector2Array()
		for v in [Vector2(x,depth),Vector2(x+width*.5,0),Vector2(x+width,depth)]:
			var point=v
			match direction:
				"down": point=Vector2(v.x,depth-v.y)
				"left": point=Vector2(v.y,v.x)
				"right": point=Vector2(depth-v.y,v.x)
			triangle.append(rect.position+point)
		n.draw_colored_polygon(triangle,body)
		n.draw_line(triangle[0],triangle[1],edge,2)
