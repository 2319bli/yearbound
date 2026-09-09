class_name YBScenery
extends RefCounted

static func active(stage: Dictionary) -> bool:
	return stage.get("decoration_profile","")=="early_summer"

static func block(n: Node2D, at: Vector2, size: Vector2, tint: Color) -> void:
	n.draw_rect(Rect2(at,size),tint)

static func cluster(n: Node2D, at: Vector2, width: float, height: float, tint: Color) -> void:
	# Stepped leaf masses, with no flat luminous edge that could be mistaken for terrain.
	var shape=PackedVector2Array([Vector2(-width*.5,0),Vector2(-width*.5,-height*.5),Vector2(-width*.4,-height*.5),Vector2(-width*.4,-height*.78),Vector2(-width*.22,-height*.78),Vector2(-width*.22,-height),Vector2(width*.18,-height),Vector2(width*.18,-height*.87),Vector2(width*.37,-height*.87),Vector2(width*.37,-height*.61),Vector2(width*.5,-height*.61),Vector2(width*.5,-height*.19),Vector2(width*.36,-height*.19),Vector2(width*.36,0)])
	for i in shape.size(): shape[i]+=at
	n.draw_colored_polygon(shape,tint)

static func hedge(n: Node2D, at: Vector2, width: float, height: float, seed_value: float, muted: bool=false) -> void:
	var dark=Color("385848") if not muted else Color("648a7d")
	var middle=Color("527a49") if not muted else Color("72998a")
	var light=Color("799852") if not muted else Color("86aa90")
	for i in int(width/22)+1:
		var x=minf(width-10,12+i*22)
		var h=height*(.68+YBLandscape.hash_value(i+seed_value)*.32)
		cluster(n,at+Vector2(x,0),32,h,dark)
		cluster(n,at+Vector2(x-2,-3),23,h*.75,middle)
		cluster(n,at+Vector2(x-5,-h*.42),13,h*.29,light)
		if i%2==0: block(n,at+Vector2(x+2,-h*.34),Vector2(3,2),middle.lightened(.10))

static func flowers(n: Node2D, at: Vector2, width: float, time: float, seed_value: float, scale_value: float=1.0) -> void:
	var flower_colors=[Color("e9e2b6"),Color("a5bcdb"),Color("d59c9a"),Color("e9e2b6")]
	for i in int(width/9):
		var x=i*9+YBLandscape.hash_value(i+seed_value)*6
		var h=(7+YBLandscape.hash_value(i*7+seed_value)*17)*scale_value
		var lean=roundf(sin(time*1.5+i)*1.5)*scale_value
		var root=at+Vector2(x,0)
		n.draw_line(root,root+Vector2(lean,-h),Color("436344"),2*scale_value)
		n.draw_line(root+Vector2(0,-h*.45),root+Vector2(-4*scale_value,-h*.65),Color("73954e"),2*scale_value)
		if i%3==0:
			var head=root+Vector2(lean,-h)
			var tint=flower_colors[posmod(i+int(seed_value),4)]
			block(n,head-Vector2(3,1)*scale_value,Vector2(6,2)*scale_value,tint)
			block(n,head-Vector2(1,3)*scale_value,Vector2(2,6)*scale_value,tint)
			block(n,head-Vector2(1,1)*scale_value,Vector2(2,2)*scale_value,Color("a99562"))
		else:
			n.draw_line(root,root+Vector2(4*scale_value,-h*.6),Color("799d53"),2*scale_value)

static func fence(n: Node2D, at: Vector2, width: float, height: float=35.0) -> void:
	var shadow=Color("49665b")
	var wood=Color("82977b")
	for y in [height*.42,height*.8]:
		n.draw_line(at-Vector2(0,y),at+Vector2(width,-y),shadow,5)
		n.draw_line(at-Vector2(0,y+2),at+Vector2(width,-y-2),wood,2)
	for x in range(0,int(width)+1,46):
		block(n,at+Vector2(x,-height),Vector2(5,height),shadow)
		block(n,at+Vector2(x,-height),Vector2(2,height-3),wood)
		block(n,at+Vector2(x-1,-height-2),Vector2(7,3),Color("a5af8b"))

static func ivy(n: Node2D, at: Vector2, length: float, time: float) -> void:
	var points=PackedVector2Array()
	for i in int(length/6)+1:
		var x=sin(i*.72+time*.4)*3
		points.append(at+Vector2(x,i*6))
	n.draw_polyline(points,Color("314e3c"),2)
	for i in range(1,points.size(),2):
		var center=points[i]+Vector2(-3 if i%4==1 else 3,0)
		var leaf=PackedVector2Array([center+Vector2(-4,0),center+Vector2(0,-3),center+Vector2(5,0),center+Vector2(1,4)])
		n.draw_colored_polygon(leaf,Color("638452") if i%4==1 else Color("4d714b"))
		block(n,center-Vector2(1,1),Vector2(2,2),Color("8ca56b"))

static func props(n: Node2D, entry: Dictionary, time: float) -> void:
	if str(entry.type) in YBJuneScenery.TYPES:
		YBJuneScenery.props(n,entry,time);return
	if str(entry.type) in YBMonthScenery.TYPES:
		YBMonthScenery.props(n,entry,time);return
	if str(entry.type) in YBDayDecor.TYPES:
		YBDayDecor.props(n,entry,time);return
	var at=Vector2(entry.x,entry.y)
	var width=float(entry.get("width",90))
	var scale_value=float(entry.get("scale",1))
	match str(entry.type):
		"fence": fence(n,at,width,float(entry.get("height",34)))
		"hedge": hedge(n,at,width,float(entry.get("height",34)),float(entry.x))
		"flowers": flowers(n,at,width,time,float(entry.x))
		"flowerbed":
			hedge(n,at,width,18,float(entry.x))
			flowers(n,at-Vector2(0,5),width,time,float(entry.x),1.45)
			for i in int(width/21):
				var stem=at+Vector2(9+i*21,-17)
				var lean=roundf(sin(time*.9+i)*2)
				n.draw_line(stem,stem+Vector2(lean,-21),Color("456a49"),2)
				for bud in 4:
					block(n,stem+Vector2(lean-2+(3 if bud%2 else 0),-9-bud*4),Vector2(4,3),Color("a5b7cf") if i%2 else Color("ddca96"))
		"boulder":
			cluster(n,at+Vector2(width*.5,0),width,20,Color("637763"))
			cluster(n,at+Vector2(width*.47,-3),width*.78,13,Color("8b9a78"))
			block(n,at+Vector2(width*.3,-16),Vector2(width*.24,3),Color("a3ad85"))
			flowers(n,at+Vector2(width*.72,0),20,time,entry.x,.8)
		"beehive":
			for leg in [-12,12]: block(n,at+Vector2(leg,-13),Vector2(4,13),Color("55654c"))
			for row in 5:
				var w=36-row*4
				block(n,at+Vector2(-w*.5,-15-row*6),Vector2(w,6),Color("bba97c") if row%2 else Color("998864"))
			block(n,at+Vector2(-4,-19),Vector2(8,4),Color("59644b"))
			for i in 2:
				var bee=at+Vector2(sin(time*1.5+i*4)*24,-37+cos(time*1.8+i)*9)
				block(n,bee,Vector2(3,2),Color("cfbc80"))
				block(n,bee+Vector2(-1,-2),Vector2(2,2),Color("e7dec0"))
		"tree": YBLandscape.tree(n,at,scale_value,str(entry.get("season","june")),Color.WHITE)
		"ivy": ivy(n,at,float(entry.get("height",40)),time)
		"birdhouse":
			n.draw_line(at,at-Vector2(0,69)*scale_value,Color("4a6554"),5*scale_value)
			var house=at-Vector2(0,74)*scale_value
			block(n,house-Vector2(11,10)*scale_value,Vector2(22,24)*scale_value,Color("c4c39b"))
			n.draw_colored_polygon(PackedVector2Array([house+Vector2(-16,-10)*scale_value,house+Vector2(0,-23)*scale_value,house+Vector2(16,-10)*scale_value]),Color("687b61"))
			block(n,house-Vector2(3,4)*scale_value,Vector2(6,8)*scale_value,Color("455846"))
			n.draw_line(house+Vector2(-5,8)*scale_value,house+Vector2(6,8)*scale_value,Color("7e805e"),3*scale_value)
		"signpost":
			n.draw_line(at,at-Vector2(0,48),Color("536348"),5)
			var board=at-Vector2(0,42)
			n.draw_colored_polygon(PackedVector2Array([board+Vector2(-15,-8),board+Vector2(16,-8),board+Vector2(23,0),board+Vector2(16,8),board+Vector2(-15,8)]),Color("aa9a71"))
			n.draw_line(board+Vector2(-8,0),board+Vector2(12,0),Color("556148"),2)
			n.draw_polyline(PackedVector2Array([board+Vector2(6,-4),board+Vector2(12,0),board+Vector2(6,4)]),Color("556148"),2)
		"stone_wall":
			for row in 3:
				for x in range(0,int(width),25):
					var pos=at+Vector2(x+(8 if row%2 else 0),-8-row*8)
					block(n,pos,Vector2(minf(23,width-x),7),Color("81947b") if row%2 else Color("768973"))
		"reeds":
			for i in 9:
				var pos=at+Vector2(i*6,0)
				var h=26+YBLandscape.hash_value(i+at.x)*20
				n.draw_line(pos,pos+Vector2(sin(time+i)*2,-h),Color("58785e"),2)
				block(n,pos+Vector2(-1,-h),Vector2(3,9),Color("8b8962"))

static func edge_plants(n: Node2D, p: Dictionary, stage: Dictionary, time: float) -> void:
	if not active(stage) or p.gone or p.data.kind!="ground": return
	var at: Vector2=p.body.position
	var width=float(p.data.w)
	# Decoration is behind the cap; leave take-off and landing edges entirely clear.
	for x in range(32,int(width)-32,74):
		flowers(n,at+Vector2(x,0),34,time,float(p.data.x+x),.7)

static func front_details(n: Node2D, p: Dictionary, stage: Dictionary, time: float) -> void:
	if not active(stage) or p.gone or p.data.kind!="ground": return
	var at: Vector2=p.body.position
	for x in range(52,int(p.data.w)-30,151):
		ivy(n,at+Vector2(x,15),minf(float(p.data.h)-25,24+YBLandscape.hash_value(x+p.data.x)*30),time)

static func stage_layer(n: Node2D, stage: Dictionary, platforms: Array[Dictionary], time: float, cam: float, layer: String) -> void:
	for authored in stage.get("decorations",[]):
		if authored.get("layer","back")!=layer: continue
		var d: Dictionary=authored.duplicate()
		if d.has("platform"):
			var p=platforms[int(d.platform)]
			if p.gone: continue
			d.x=p.body.position.x+float(d.get("offset",0))
			d.y=p.body.position.y+float(d.get("offset_y",0))
		if d.x+float(d.get("width",160))<cam-180 or d.x>cam+1460: continue
		props(n,d,time)

static func depth_layer(n: Node2D, cam: float, time: float) -> void:
	# A separately scrolling near meadow adds depth beneath the distant painting.
	for i in 10:
		var x=fposmod(i*173.0-cam*.48,1650)-150
		var y=677+sin(i*1.7)*16
		hedge(n,Vector2(x,y),125,45+sin(i)*9,float(i*7),true)
	for i in 4:
		var x=fposmod(i*457.0-cam*.31,1750)-170
		fence(n,Vector2(x,665),136,26)

static func atmosphere(n: Node2D, cam: float, time: float, reduced: bool) -> void:
	for i in 14:
		var x=fposmod(i*193.3-cam*.65+(time*8 if not reduced else 0),1370)-40
		var y=325+fposmod(i*91.7,285)+sin(time*.8+i)*9
		n.draw_rect(Rect2(x,y,2,2),Color(.98,.96,.75,.23))

static func near_frame(n: Node2D, cam: float, time: float) -> void:
	# Draw over the river, in world space. All foliage stays below y=674.
	for i in 5:
		var x=cam+fposmod(i*331.0-cam*1.08,1640)-110
		hedge(n,Vector2(x,754),105,65,float(i*9))
		for j in 5:
			var at=Vector2(x+12+j*11,739)
			var h=34+YBLandscape.hash_value(i*9+j)*24
			var lean=roundf(sin(time*.8+i+j)*2)
			n.draw_line(at,at+Vector2(lean,-h),Color("365e4c"),3)
			n.draw_line(at+Vector2(0,-h*.4),at+Vector2(-7,-h*.75),Color("527951"),3)
			block(n,at+Vector2(lean-1,-h),Vector2(4,10),Color("888451"))
