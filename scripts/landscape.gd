class_name YBLandscape
extends RefCounted

static var palettes: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://content/themes.json"))
static var textures: Dictionary = {}
static var texture_recent: Array[String] = []
const MAX_CACHED_TEXTURES = 16
const PLATES = {"june":"summer","mill":"summer","boss":"summer","autumn":"autumn","winter":"winter","spring":"spring"}

static func color(season: String, index: int) -> Color:
	return Color(palettes.get(season,palettes.june)[index])

static func texture(path: String) -> Texture2D:
	if not textures.has(path):
		if not ResourceLoader.exists(path): return null
		textures[path]=load(path)
	texture_recent.erase(path)
	texture_recent.append(path)
	while texture_recent.size()>MAX_CACHED_TEXTURES:
		textures.erase(texture_recent.pop_front())
	return textures.get(path)

static func hash_value(value: float) -> float:
	return fposmod(sin(value*127.1+311.7)*43758.5453,1.0)

static func background(n: Node2D, season: String, cam: float, time: float, reduced: bool = false, art_path: String="", ambience: Dictionary={}) -> void:
	var plate=texture(art_path if not art_path.is_empty() else "res://art/"+PLATES.get(season,"summer")+".png")
	var month_scene=str(ambience.get("month_scene",""))
	var june_scene=str(ambience.get("june_scene",""))
	if YBJuneScenery.scenes.has(june_scene):
		YBJuneScenery.background(n,june_scene,cam,0 if reduced else time)
	elif YBMonthScenery.scenes.has(month_scene):
		YBMonthScenery.background(n,month_scene,cam,0 if reduced else time)
	elif plate:
		var drift=sin(cam*0.00016)*130
		n.draw_texture_rect(plate,Rect2(-140-drift,-48,1560,878),false,Color("76889e") if season=="boss" else Color.WHITE)
	else:
		for y in range(0,720,4): n.draw_rect(Rect2(0,y,1280,4),color(season,0).lerp(color(season,1),float(y)/720))
	if season=="boss": storm_sky(n,time,reduced)
	# Atmospheric depth separates distance from sharp collidable foreground.
	var haze=Color(ambience.get("haze","bccad0" if season=="winter" else "acb6a0"))
	for i in 24:
		var y=410+i*13
		n.draw_rect(Rect2(0,y,1280,14),Color(haze,(0.025+float(i)/500)*float(ambience.get("haze_strength",1))))
	if season in ["june","mill"] and ambience.is_empty(): YBScenery.depth_layer(n,cam,time)
	if season=="mill" and june_scene.is_empty():
		for i in 2:
			var x=fposmod(i*850.0-cam*0.32,2000)-100
			mill(n,Vector2(x,529),time,0.90)
	if season in ["june","mill","spring"] and june_scene not in ["glasshouse_run","woodland_detour"]:
		for i in 4:
			var x=fposmod(i*357.0+time*(9 if not reduced else 0)-cam*0.19,1540)-80
			var y=175+i*19+sin(time*0.8+i)*5
			var flap=sin(time*3.8+i)*3
			n.draw_polyline(PackedVector2Array([Vector2(x-7,y-1+flap),Vector2(x-3,y-1),Vector2(x,y+1),Vector2(x+3,y-1),Vector2(x+7,y-1+flap)]),Color(0.14,0.18,0.20,0.62),1,true)

static func storm_sky(n: Node2D, time: float, reduced: bool) -> void:
	# Pixel bands and a drifting cloud bank frame the readable boss silhouette.
	for i in 40:
		var y=i*12.0
		var tint=Color("394c65").lerp(Color("9aa5a7"),float(i)/40)
		n.draw_rect(Rect2(0,y,1280,12),Color(tint,clampf((480-y)/190,0,1)))
	var clouds=texture("res://art/storm_clouds.png")
	if clouds:
		var drift=0.0 if reduced else sin(time*0.035)*24
		n.draw_texture_rect(clouds,Rect2(-64+drift,-24,1408,472),false)
	for i in 3:
		var x=135+i*34
		n.draw_colored_polygon(PackedVector2Array([Vector2(x,270),Vector2(x+7,270),Vector2(x+188,532),Vector2(x+155,532)]),Color(0.92,0.84,0.61,0.045))
	for i in 19:
		var x=670+i*23
		var y=310+sin(i*0.7)*14
		n.draw_line(Vector2(x,y),Vector2(x-34,506),Color(0.57,0.68,0.76,0.13),8)

static func tree(n: Node2D, at: Vector2, scale_value: float, season: String, fill: Color) -> void:
	var atlas=texture("res://art/trees.png")
	if atlas:
		var index=2 if season=="winter" else (1 if season=="autumn" else 0)
		var regions=[Rect2(0,64,538,875),Rect2(540,64,552,875),Rect2(1096,64,440,875)]
		var source: Rect2=regions[index]
		var source_width=source.size.x
		var height=205.0*scale_value
		var width=height*source_width/source.size.y
		n.draw_texture_rect_region(atlas,Rect2(at-Vector2(width/2,height),Vector2(width,height)),source)
		return
	var bark=Color("484b3b") if season!="winter" else Color("55616a")
	var trunk=PackedVector2Array([at+Vector2(-5,0)*scale_value,at+Vector2(-2,-67)*scale_value,at+Vector2(-6,-104)*scale_value,at+Vector2(-1,-118)*scale_value,at+Vector2(4,-65)*scale_value,at+Vector2(7,0)*scale_value])
	n.draw_colored_polygon(trunk,bark)
	n.draw_polyline(PackedVector2Array([at+Vector2(0,-2)*scale_value,at+Vector2(1,-59)*scale_value,at+Vector2(-3,-97)*scale_value]),bark.lightened(0.16),1.5*scale_value,true)
	var evergreen=season=="winter"
	for branch in 13:
		var side=1 if branch%2==0 else -1
		var y=-28-branch*6
		var spread=(41-branch*1.7) if evergreen else 22+hash_value(branch)*22
		var tip=at+Vector2(side*spread,y-17)*scale_value
		n.draw_line(at+Vector2(0,y)*scale_value,tip,bark,1.6*scale_value,true)
		var clusters=5 if evergreen else 4
		for c in clusters:
			var center=tip+Vector2((hash_value(branch*8+c)-0.5)*21,(hash_value(branch*18+c)-0.5)*17)*scale_value
			var poly=PackedVector2Array()
			for j in 13:
				var r=(8+hash_value(branch+c)*7)*(0.62+hash_value(j+branch*17+c*5)*0.6)*scale_value
				poly.append(center+Vector2(cos(j*TAU/13)*r,sin(j*TAU/13)*r*0.7))
			var tint=fill.darkened(0.08).lightened(hash_value(branch*7+c)*0.18)
			if evergreen and c==0: tint=Color("bbc8c9")
			n.draw_colored_polygon(poly,tint)

static func grass(n: Node2D, at: Vector2, width: float, season: String, time: float, seed_value: float, foreground: bool=false) -> void:
	var base=Color("789846")
	if season=="autumn": base=Color("b58c4b")
	elif season=="winter": base=Color("9aada9")
	elif season=="spring": base=Color("628d58")
	elif season=="boss": base=Color("556755")
	for i in int(width/5):
		var x=i*5.0+hash_value(i+seed_value)*5
		var h=3+pow(hash_value(i*3+seed_value),2)*18
		if foreground: h*=2.1
		var lean=sin(time*1.6+i*0.13)*2+hash_value(i+9)*7-3
		var root=at+Vector2(x,0)
		var tint=base.darkened(hash_value(i+seed_value)*0.27)
		var points=PackedVector2Array([root,root+Vector2(lean*0.3,-h*0.55),root+Vector2(lean,-h)])
		n.draw_polyline(points,tint,0.6 if not foreground else 0.8,true)
		if i%7==0 and season not in ["winter","boss"]:
			var flower=root+Vector2(lean,-h)
			var petals=Color("ebd395") if i%2 else Color("d29caa")
			for j in 4: n.draw_circle(flower+Vector2.from_angle(j*TAU/4)*1.5,1.1,petals,true,-1,true)
			n.draw_circle(flower,0.9,Color("bd9b57"),true,-1,true)

static func mill(n: Node2D, at: Vector2, time: float, scale_value: float) -> void:
	var body=PackedVector2Array([at+Vector2(-21,0)*scale_value,at+Vector2(-13,-97)*scale_value,at+Vector2(12,-97)*scale_value,at+Vector2(25,0)*scale_value])
	n.draw_colored_polygon(body,Color("b0ab92"))
	for j in 18:
		var y=-j*5.1
		n.draw_line(at+Vector2(-20-j*-0.4,y)*scale_value,at+Vector2(23-j*0.55,y)*scale_value,Color(0.25,0.28,0.25,0.28),1,true)
	n.draw_colored_polygon(PackedVector2Array([at+Vector2(-19,-94)*scale_value,at+Vector2(0,-119)*scale_value,at+Vector2(19,-94)*scale_value]),Color("4b514c"))
	var hub=at+Vector2(0,-93)*scale_value
	for i in 4:
		var angle=time*0.22+i*PI/2
		var direction=Vector2(cos(angle),sin(angle))
		var normal=direction.orthogonal()
		n.draw_line(hub,hub+direction*75*scale_value,Color("51544b"),3*scale_value,true)
		for k in 9:
			var center=hub+direction*(22+k*5.5)*scale_value
			n.draw_line(center-normal*2*scale_value,center+normal*11*scale_value,Color("c0b99e"),2*scale_value,true)
		n.draw_line(hub+(direction*20+normal*10)*scale_value,hub+(direction*72+normal*10)*scale_value,Color("686957"),1.5*scale_value,true)
	n.draw_circle(hub,4*scale_value,Color("494e46"),true,-1,true)

static func gate(n: Node2D, at: Vector2, time: float, scale_value: float=1.0) -> void:
	var light=Color(1.0,0.91,0.64,0.08)
	for r in range(6,48,6): n.draw_circle(at-Vector2(0,39)*scale_value,r*scale_value,Color(light,0.065*(1-float(r)/50)),true,-1,true)
	for side in [-1,1]:
		var post=at+Vector2(side*24,0)*scale_value
		n.draw_line(post,post-Vector2(0,79)*scale_value,Color("494434"),8*scale_value,true)
		n.draw_line(post+Vector2(-1,0),post+Vector2(-1,-79)*scale_value,Color("8d8262"),2*scale_value,true)
	for y in [-19,-52]: n.draw_line(at+Vector2(-22,y)*scale_value,at+Vector2(22,y)*scale_value,Color("a49976"),5*scale_value,true)
	n.draw_line(at+Vector2(-21,-17)*scale_value,at+Vector2(21,-54)*scale_value,Color("867b5d"),4*scale_value,true)
	for x in [-13,0,13]: n.draw_line(at+Vector2(x,-11)*scale_value,at+Vector2(x,-63)*scale_value,Color("978f70"),3*scale_value,true)
	n.draw_circle(at+Vector2(19,-45)*scale_value,3*scale_value,Color("d9c788"),true,-1,true)
	for i in 4:
		var pos=at+Vector2(sin(time*0.8+i*3)*18,-20-i*12+cos(time+i)*3)*scale_value
		n.draw_circle(pos,1.3,Color("ffe6a1"),true,-1,true)

static func foreground(n: Node2D, season: String, cam: float, time: float) -> void:
	# Fine nearby reeds and restrained weather, avoiding a dense overlay over hazards.
	if season in ["autumn","winter","boss","spring"]:
		for i in 52:
			var x=fposmod(i*179.7+time*(48 if season!="winter" else 12)-cam*0.65,1360)-40
			var y=fposmod(i*83.3+time*(230 if season in ["boss","spring","autumn"] else 21),780)-30
			if season=="winter": n.draw_circle(Vector2(x,y),0.7+(i%3)*0.45,Color(1,1,1,0.6),true,-1,true)
			elif season=="autumn" and i%4==0:
				n.draw_set_transform(Vector2(x+sin(time+i)*12,y),time*0.7+i)
				n.draw_colored_polygon(PackedVector2Array([Vector2(-3,0),Vector2(0,-1),Vector2(5,0),Vector2(1,2)]),Color("b58c59"))
				n.draw_set_transform(Vector2.ZERO)
			else: n.draw_line(Vector2(x,y),Vector2(x-4,y+13),Color(0.86,0.93,0.95,0.25),0.7,true)
