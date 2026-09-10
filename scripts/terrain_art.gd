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
		# Composed terrain masses: one continuous body per platform with organic
		# treatment on exposed edges only, so adjoining cells read as a single
		# ledge instead of a stack of bordered boxes. The drawn silhouette always
		# matches the collision rectangle exactly; decoration never extends past
		# it. The old per-tile look remains in tile() for the layout workshop.
		if d.kind in ["wood","moving"]:
			beam(n,rect,p,d.kind=="moving")
		else:
			mass(n,rect,d,stage,p,platform_data.get("occupied",{}))
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
		# The base ground is one continuous earth mass with a grass/snow cap,
		# not rows of individual tiles.
		var top=float(stage.ground.y)
		var left=floorf((cam-48)/48)*48
		earth_mass(n,Rect2(left,top,cam+1392-left,864-top),stage,palette(stage))
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

static func buried(occupied: Dictionary, cx: int, cy: int) -> bool:
	return occupied.has(YBLayoutDocument.key(Vector2i(cx,cy)))

static func cap_band(n: Node2D, at: Vector2, width: float, top: Color, mid: Color, low: Color, seed_value: float, tufts: bool=true, flowery: bool=false, frozen: bool=false) -> void:
	# Ornate overhanging cap, Towerverse-style: the band spills 3 px past the
	# sides, carries a sunlit crest with a hot highlight, and a fringed lower
	# edge hangs INTO the mass (never below it). Feet land exactly at at.y.
	var over=3.0
	var band=Rect2(at+Vector2(-over,0),Vector2(width+2*over,12))
	# Soft light bleed above the crest: visible at night, subtle in daylight.
	n.draw_rect(Rect2(at+Vector2(-over,-4),Vector2(width+2*over,4)),Color(top,0.13))
	n.draw_rect(band,mid)
	n.draw_rect(Rect2(at+Vector2(-over,6),Vector2(width+2*over,6)),low)
	n.draw_rect(Rect2(at+Vector2(-over,0),Vector2(width+2*over,3)),top)
	n.draw_rect(Rect2(at+Vector2(-over,0),Vector2(width+2*over,1)),top.lightened(0.5))
	# Fringe: paired drips hanging into the body, alternating depths.
	for x in range(2,int(width)-6,13):
		var h=4+YBLandscape.hash_value(seed_value+x*1.13)*6
		n.draw_rect(Rect2(at+Vector2(x,12),Vector2(minf(7,width-x-2),h)),low)
		n.draw_rect(Rect2(at+Vector2(x+1,12),Vector2(minf(4,width-x-3),h*0.55)),mid.darkened(0.12))
	# Pixel-craft speckle inside the band.
	for x in range(4,int(width)-4,9):
		if YBLandscape.hash_value(seed_value+x*3.7)<0.55: continue
		n.draw_rect(Rect2(at+Vector2(x,4+YBLandscape.hash_value(x+seed_value)*5),Vector2(2,2)),top.darkened(0.12))
	if tufts:
		if frozen:
			# Frozen caps get low snow clumps, never upright blades that could
			# be mistaken for icicle hazards.
			for x in range(6,int(width)-6,19):
				var w=4+YBLandscape.hash_value(seed_value+x*1.9)*5
				n.draw_rect(Rect2(at+Vector2(x,-2),Vector2(w,3)),top.darkened(0.04))
		else:
			# Paired, curved, leaf-soft blades: clearly vegetation, never the
			# straight single strokes that bramble/icicle hazards use.
			for x in range(5,int(width)-5,17):
				var h=2.5+YBLandscape.hash_value(seed_value*1.7+x*3.1)*4
				var lean=YBLandscape.hash_value(seed_value+x*0.7)*5-2.5
				var tint=low if posmod(int(x/17),2) else mid
				n.draw_polyline(PackedVector2Array([at+Vector2(x,1),at+Vector2(x+lean*0.4,-h*0.5),at+Vector2(x+lean,-h)]),tint,1.2,true)
				n.draw_polyline(PackedVector2Array([at+Vector2(x+2,1),at+Vector2(x+2-lean*0.3,-h*0.4),at+Vector2(x+2-lean*0.7,-h*0.75)]),tint.darkened(0.08),1.1,true)
		if flowery:
			var petals=[Color("f3e5b1"),Color("d9a5a0"),Color("b9cfe4")]
			for x in range(9,int(width)-8,31):
				if YBLandscape.hash_value(seed_value+x*7.7)<0.45: continue
				var pos=at+Vector2(x,-4-YBLandscape.hash_value(x+seed_value)*3)
				n.draw_circle(pos,1.8,petals[posmod(int(x/31)+int(seed_value),3)],true,-1,true)
				n.draw_circle(pos+Vector2(1.5,-1),0.8,Color("fff6d8"),true,-1,true)

static func earth_body(n: Node2D, rect: Rect2, base: Color, light: Color, dark: Color, seed_value: float, cap_depth: float=12) -> void:
	# Rich soil: warm fill, sunlit band under the cap darkening with depth,
	# strata, pebble clusters, embedded stones and rootlets trailing from above.
	n.draw_rect(rect,base)
	n.draw_rect(Rect2(rect.position+Vector2(0,cap_depth),Vector2(rect.size.x,7)),Color(light,0.5))
	var bands=maxi(0,int((rect.size.y-30)/34))
	for i in bands:
		n.draw_rect(Rect2(rect.position+Vector2(0,rect.size.y-(i+1)*34),Vector2(rect.size.x,34)),Color(dark,minf(0.34,(i+1)*0.1)))
	# Strata: broken, slightly wandering horizontal seams.
	for y in range(34,int(rect.size.y)-10,37):
		var yy=rect.position.y+y
		for x in range(4,int(rect.size.x)-20,38):
			var w=16+YBLandscape.hash_value(seed_value+x*1.9+y)*18
			n.draw_line(Vector2(rect.position.x+x,yy),Vector2(rect.position.x+x+w,yy+YBLandscape.hash_value(x+y)*2),Color(dark,0.45),1)
	# Pebble clusters and embedded stones.
	for x in range(8,int(rect.size.x)-14,27):
		for yy in range(int(cap_depth)+10,int(rect.size.y)-8,29):
			var h1=YBLandscape.hash_value(seed_value+x*3.1+yy*1.7)
			if h1<0.45: continue
			var px=rect.position.x+x+h1*9
			var py=rect.position.y+yy
			var tint=light if h1>0.72 else dark
			n.draw_rect(Rect2(px,py,4+h1*4,3),tint)
			n.draw_rect(Rect2(px+1,py-1.5,2+h1*3,1.5),tint.lightened(0.15))
	# Rootlets trailing from the cap.
	for x in range(10,int(rect.size.x)-10,43):
		if YBLandscape.hash_value(seed_value+x*5.3)<0.5: continue
		var root=rect.position+Vector2(x,cap_depth+4)
		var len=7+YBLandscape.hash_value(x+seed_value)*14
		n.draw_polyline(PackedVector2Array([root,root+Vector2(2,len*0.5),root+Vector2(-1,len)]),dark.darkened(0.15),1,true)

static func edge_rims(n: Node2D, rect: Rect2, left_open: bool, right_open: bool, rim: Color, lit: Color, moss: Color=Color.TRANSPARENT, seed_value: float=0) -> void:
	# Exposed vertical faces: dark outer rim, thin lit bevel inside, and
	# optional damp streaks trailing down from the cap.
	if left_open:
		n.draw_rect(Rect2(rect.position,Vector2(3,rect.size.y)),rim)
		n.draw_rect(Rect2(rect.position+Vector2(3,4),Vector2(1,maxf(0,rect.size.y-8))),lit)
		if moss.a>0:
			for y in range(16,int(rect.size.y)-8,31):
				if YBLandscape.hash_value(seed_value+y*2.9)<0.5: continue
				n.draw_rect(Rect2(rect.position+Vector2(3,y),Vector2(2,5+YBLandscape.hash_value(y)*8)),moss)
	if right_open:
		n.draw_rect(Rect2(Vector2(rect.end.x-3,rect.position.y),Vector2(3,rect.size.y)),rim)
		n.draw_rect(Rect2(Vector2(rect.end.x-4,rect.position.y+4),Vector2(1,maxf(0,rect.size.y-8))),lit)
		if moss.a>0:
			for y in range(20,int(rect.size.y)-8,29):
				if YBLandscape.hash_value(seed_value+y*3.7)<0.55: continue
				n.draw_rect(Rect2(Vector2(rect.end.x-5,rect.position.y+y),Vector2(2,4+YBLandscape.hash_value(y+7)*7)),moss)

static func underside(n: Node2D, rect: Rect2, dark: Color, rim: Color, seed_value: float) -> void:
	# Shadowed underside: a dark band inside the rect, notches rising into it,
	# and short tapered drips hanging just below — the Towerverse ragged
	# underside. Drips are small, dark and clearly attached; they never
	# resemble a standable surface or a hazard.
	n.draw_rect(Rect2(Vector2(rect.position.x,rect.end.y-5),Vector2(rect.size.x,5)),rim)
	for x in range(8,int(rect.size.x)-10,29):
		var h=3+YBLandscape.hash_value(seed_value+x*2.3)*5
		n.draw_rect(Rect2(rect.position.x+x,rect.end.y-5-h,4,h),dark.darkened(0.15))
	for x in range(6,int(rect.size.x)-8,21):
		if YBLandscape.hash_value(seed_value+x*4.1)<0.45: continue
		var h=4+YBLandscape.hash_value(seed_value+x*1.7)*6
		var px=rect.position.x+x
		n.draw_colored_polygon(PackedVector2Array([Vector2(px,rect.end.y-1),Vector2(px+5,rect.end.y-1),Vector2(px+2.5,rect.end.y+h)]),dark.darkened(0.2))

static func speckle(n: Node2D, rect: Rect2, colors: Array, step: int, seed_value: float, chance: float=0.5, size: float=2) -> void:
	# Cheap pixel-craft texture: sparse 2-3 px flecks in harmonised tones.
	for y in range(int(rect.position.y)+3,int(rect.end.y)-3,step):
		for x in range(int(rect.position.x)+3,int(rect.end.x)-3,step):
			var h=YBLandscape.hash_value(seed_value+x*1.31+y*2.17)
			if h>chance: continue
			n.draw_rect(Rect2(x+int(h*40)%3,y+int(h*70)%3,size,size),colors[posmod(int(h*997),colors.size())])

static func mass(n: Node2D, rect: Rect2, d: Dictionary, stage: Dictionary, p: Dictionary, occupied: Dictionary) -> void:
	# One solid mass with a material-appropriate body and seasonal cap.
	var kind=str(d.get("kind","block"))
	var material=str(d.get("material","stone"))
	var season=str(stage.get("season","june"))
	var seed_value=float(d.get("x",0))*0.73+float(d.get("y",0))*1.31
	var frozen=season=="winter" or kind=="ice"
	var fill=ink(p,"soil");var light=ink(p,"soil_light");var dark=ink(p,"soil_dark")
	var cap_top=Color("f1f7e6") if frozen else ink(p,"top")
	var cap_mid=Color("b6d6dc") if frozen else ink(p,"grass")
	var cap_low=Color("6e9dab") if frozen else ink(p,"grass_shadow")
	var tufts=true
	var flowery=season in ["june","mill","spring"]
	if kind=="ice":
		fill=Color("6fa8b8");light=Color("93cbd6");dark=Color("4f8395")
		cap_top=Color("f2fbf7");cap_mid=Color("c9e8ea");cap_low=Color("8fc0cc");tufts=false;flowery=false
	elif kind=="crumble":
		if str(d.get("surface",""))=="ice":
			fill=Color("548d9e");light=Color("9dbbc5");dark=Color("3f7080")
		else:
			fill=Color("966744");light=Color("c58b50");dark=Color("77503a")
		cap_top=Color("f2cd89");cap_mid=Color("c58b50");cap_low=Color("8a5f3d");tufts=false;flowery=false
	elif kind=="block" and material=="log":
		fill=ink(p,"wood");light=ink(p,"wood_light");dark=ink(p,"wood").darkened(.3)
		cap_top=ink(p,"wood_top");cap_mid=light;cap_low=dark;tufts=false;flowery=false
	elif kind=="block" and material=="hay":
		fill=Color("ba9550");light=Color("d3b56b");dark=Color("94743f")
		cap_top=Color("f3dc98");cap_mid=light;cap_low=dark;tufts=false;flowery=false
	elif kind=="block":
		fill=Color("667877");light=Color("82958e");dark=Color("4c5e5b")
		cap_top=Color("e3ead0");cap_mid=Color("a9b8a4");cap_low=Color("7d9187")
	elif kind=="spring":
		fill=Color("477250");light=Color("6b965a");dark=Color("35593f")
		cap_top=Color("f4dc8d");cap_mid=Color("7fae62");cap_low=Color("4d7a4b");flowery=true
	# Edge exposure against the shared solid-cell map (includes abutting platforms).
	var gx=int(round(rect.position.x/48.0));var gy=int(round(rect.position.y/48.0))
	var cols=maxi(1,int(round(rect.size.x/48.0)));var rows=maxi(1,int(round(rect.size.y/48.0)))
	var ground_y=float(stage.get("ground",{}).get("y",100000))
	var left_open=not buried(occupied,gx-1,gy)
	var right_open=not buried(occupied,gx+cols,gy)
	var bottom_open=absf(rect.end.y-ground_y)>1
	if bottom_open:
		bottom_open=false
		for c in cols:
			if not buried(occupied,gx+c,gy+rows): bottom_open=true;break
	# Body.
	var rim=fill.darkened(0.42)
	if kind=="block" and material=="stone":
		# Carved masonry: framed courses, staggered joints and moss settling
		# from the cap. Reads as hewn stone and merges across cells.
		n.draw_rect(rect,fill)
		n.draw_rect(Rect2(rect.position+Vector2(0,12),Vector2(rect.size.x,6)),Color(light,0.4))
		for y in range(14,int(rect.size.y)-4,14):
			n.draw_line(rect.position+Vector2(2,y),rect.position+Vector2(rect.size.x-2,y),Color(dark,0.55),1)
			n.draw_line(rect.position+Vector2(2,y+1),rect.position+Vector2(rect.size.x-2,y+1),Color(light,0.25),1)
			for x in range(22 if posmod(y,28)==0 else 6,int(rect.size.x)-6,30):
				n.draw_line(rect.position+Vector2(x,y-13),rect.position+Vector2(x,y),Color(dark,0.45),1)
		for x in range(6,int(rect.size.x)-8,23):
			if YBLandscape.hash_value(seed_value+x*1.7)<0.5: continue
			n.draw_rect(Rect2(rect.position+Vector2(x,9+YBLandscape.hash_value(x+seed_value)*8),Vector2(5,3)),Color(cap_low,0.55))
		speckle(n,rect,[light,dark],13,seed_value,0.4)
	elif kind=="block" and material=="log":
		# Stacked timber: plank courses, grain streaks, knots and end grain.
		n.draw_rect(rect,fill)
		for y in range(12,int(rect.size.y)-4,12):
			n.draw_line(rect.position+Vector2(2,y),rect.position+Vector2(rect.size.x-2,y),dark,1.5)
			n.draw_line(rect.position+Vector2(2,y-1),rect.position+Vector2(rect.size.x-2,y-1),Color(light,0.5),1)
		for y in range(7,int(rect.size.y)-8,12):
			for x in range(6,int(rect.size.x)-18,34):
				var w=10+YBLandscape.hash_value(seed_value+x+y)*14
				n.draw_line(rect.position+Vector2(x,y),rect.position+Vector2(x+w,y+1),Color(light,0.4),1)
		for x in range(16,int(rect.size.x)-10,57):
			if YBLandscape.hash_value(seed_value+x*2.7)<0.5: continue
			var knot=rect.position+Vector2(x,10+YBLandscape.hash_value(x)*maxf(6,rect.size.y-22))
			n.draw_circle(knot,2.6,dark,true,-1,true)
			n.draw_circle(knot,1.1,dark.darkened(0.3),true,-1,true)
		if left_open:
			n.draw_rect(Rect2(rect.position+Vector2(3,3),Vector2(5,rect.size.y-6)),dark)
			for y in range(7,int(rect.size.y)-6,9): n.draw_line(rect.position+Vector2(3,y),rect.position+Vector2(8,y+2),Color(light,0.5),1)
		if right_open:
			n.draw_rect(Rect2(Vector2(rect.end.x-8,rect.position.y+3),Vector2(5,rect.size.y-6)),dark)
			for y in range(7,int(rect.size.y)-6,9): n.draw_line(Vector2(rect.end.x-8,rect.position.y+y),Vector2(rect.end.x-3,rect.position.y+y+2),Color(light,0.5),1)
	elif kind=="block" and material=="hay":
		# Pressed bales: diagonal straw strokes, twine bands, loose wisps.
		n.draw_rect(rect,fill)
		for y in range(5,int(rect.size.y)-3,7):
			for x in range(3,int(rect.size.x)-10,17):
				var up=YBLandscape.hash_value(seed_value+x*2.2+y)>0.5
				n.draw_line(rect.position+Vector2(x,y+(0 if up else 3)),rect.position+Vector2(x+8,y+(3 if up else 0)),Color(light,0.5),1)
		for f in [0.33,0.66]:
			n.draw_rect(Rect2(rect.position+Vector2(rect.size.x*f-2,2),Vector2(4,rect.size.y-4)),Color("77613b"))
			n.draw_rect(Rect2(rect.position+Vector2(rect.size.x*f-3,2),Vector2(1,rect.size.y-4)),Color("a98f5e"))
	elif kind=="ice":
		# Frozen mass: luminous core, sheen streaks, trapped bubbles, frost flecks.
		n.draw_rect(rect,fill)
		n.draw_rect(Rect2(rect.position+Vector2(6,10),rect.size-Vector2(12,18)),Color(light,0.35))
		for i in range(20,int(rect.size.x)-10,74):
			var base=rect.position+Vector2(i+YBLandscape.hash_value(seed_value+i)*20,8)
			n.draw_polyline(PackedVector2Array([base,base+Vector2(9,10),base+Vector2(5,18)]),Color("e2f7f7",0.75),1.5,true)
		for i in range(8,int(rect.size.x)-6,41):
			n.draw_circle(rect.position+Vector2(i,18+YBLandscape.hash_value(i+seed_value)*maxf(4,rect.size.y-26)),1.4,Color("e8fbf7",0.5),true,-1,true)
		speckle(n,rect,[Color("f2fbf7"),Color("8fc0cc")],11,seed_value+5,0.45)
	elif kind=="crumble":
		# Dry plates drifting apart: irregular tinted panels split by fissures.
		n.draw_rect(rect,fill)
		for y in range(10,int(rect.size.y)-8,20):
			for x in range(8,int(rect.size.x)-16,34):
				var h1=YBLandscape.hash_value(seed_value+x*1.9+y*3.3)
				n.draw_rect(Rect2(rect.position+Vector2(x,y),Vector2(14+h1*8,8)),Color(light if h1>0.5 else dark,0.35))
		for i in range(10,int(rect.size.x)-8,52):
			if YBLandscape.hash_value(seed_value+i*5.1)<0.3: continue
			var crack=PackedVector2Array()
			var drift=0.0
			for s in 4:
				crack.append(rect.position+Vector2(i+drift,5+s*maxf(6,(rect.size.y-10)/4)))
				drift+=(YBLandscape.hash_value(seed_value+i+s*13.7)-0.5)*9
			n.draw_polyline(crack,dark.darkened(0.25),1.5,true)
	else:
		earth_body(n,rect,fill,light,dark,seed_value)
	# Exposed-edge treatment, then the cap last so nothing covers the walk edge.
	var moss=Color(cap_low,0.55) if kind in ["block","ground","spring"] and material=="stone" else Color.TRANSPARENT
	edge_rims(n,rect,left_open,right_open,rim,Color(light,0.7),moss,seed_value)
	if bottom_open: underside(n,rect,dark,rim,seed_value)
	var run_start=-1
	for c in cols+1:
		var open=c<cols and not buried(occupied,gx+c,gy-1)
		if open and run_start<0: run_start=c
		if not open and run_start>=0:
			cap_band(n,rect.position+Vector2(run_start*48,0),(c-run_start)*48,cap_top,cap_mid,cap_low,seed_value+run_start*7.3,tufts,flowery,frozen)
			run_start=-1
	if kind=="spring":
		for c in cols:
			var center=rect.position+Vector2(c*48+24,10)
			n.draw_polyline(PackedVector2Array([center+Vector2(-7,4),center+Vector2(0,-3),center+Vector2(7,4)]),cap_top,2.5,true)

static func earth_mass(n: Node2D, rect: Rect2, stage: Dictionary, p: Dictionary) -> void:
	# The continuous base ground: rich soil darkening with depth and a full cap.
	var season=str(stage.get("season","june"))
	var frozen=season=="winter"
	var seed_value=float(stage.get("ground",{}).get("y",624))
	earth_body(n,rect,ink(p,"soil"),ink(p,"soil_light"),ink(p,"soil_dark"),seed_value)
	cap_band(n,rect.position,rect.size.x,Color("f1f7e6") if frozen else ink(p,"top"),Color("b6d6dc") if frozen else ink(p,"grass"),Color("6e9dab") if frozen else ink(p,"grass_shadow"),seed_value,true,season in ["june","mill","spring"],frozen)

static func beam(n: Node2D, rect: Rect2, p: Dictionary, moving: bool) -> void:
	# Structural timber beam: framed edge, plank body with grain and knots, a
	# pale walk strip carrying the same hot crest as terrain caps, end grain
	# and nail heads. Matches the support posts drawn by the scenery pass.
	var at=rect.position
	var seed_value=at.x*0.61+at.y*1.17
	var outline=ink(p,"outline");var wood=ink(p,"wood");var light=ink(p,"wood_light");var top=ink(p,"wood_top")
	n.draw_rect(rect,outline)
	n.draw_rect(Rect2(at+Vector2(2,3),rect.size-Vector2(4,5)),wood)
	for y in range(6,int(rect.size.y)-5,9):
		n.draw_line(at+Vector2(3,y),at+Vector2(rect.size.x-3,y),wood.darkened(0.3),1)
	for x in range(6,int(rect.size.x)-14,29):
		var y0=6+YBLandscape.hash_value(seed_value+x)*maxf(4,rect.size.y-14)
		n.draw_line(at+Vector2(x,y0),at+Vector2(minf(x+12,rect.size.x-4),y0+1),Color(light,0.5),1)
	for x in range(18,int(rect.size.x)-12,53):
		if YBLandscape.hash_value(seed_value+x*2.1)<0.55: continue
		n.draw_circle(at+Vector2(x,7+YBLandscape.hash_value(x+seed_value)*maxf(3,rect.size.y-14)),1.8,wood.darkened(0.35),true,-1,true)
	n.draw_rect(Rect2(at,Vector2(rect.size.x,3)),top)
	n.draw_rect(Rect2(at,Vector2(rect.size.x,1)),top.lightened(0.5))
	n.draw_rect(Rect2(at+Vector2(2,3),Vector2(rect.size.x-4,2)),light)
	n.draw_rect(Rect2(Vector2(at.x,rect.end.y-4),Vector2(rect.size.x,3)),wood.darkened(0.35))
	for side in [0,1]:
		var ex=at.x+2 if side==0 else rect.end.x-5
		n.draw_rect(Rect2(ex,at.y+2,3,rect.size.y-4),light.darkened(0.2))
		n.draw_rect(Rect2(ex+0.5,at.y+rect.size.y*0.5-1,2,2),outline)
	if moving:
		var center=at+Vector2(rect.size.x/2,rect.size.y/2)
		n.draw_colored_polygon(PackedVector2Array([center+Vector2(-6,0),center+Vector2(0,-5),center+Vector2(6,0),center+Vector2(0,5)]),top)
		n.draw_colored_polygon(PackedVector2Array([center+Vector2(-3,0),center+Vector2(0,-2.5),center+Vector2(3,0),center+Vector2(0,2.5)]),outline)

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
