class_name YBJuneScenery
extends RefCounted
## Nine authored scene identities. All props are visual, behind collidable blocks.
const TYPES=["glasshouse_bay","palm_planter","fern_bed","crossing_bridge","trail_fingerpost","river_rapids","river_boat","orchard_ladder","orchard_crown","fruit_basket","wildflower_drift","pollinators","woodland_trunk","woodland_stump","mill_tower","wind_ribbon","hay_roll","hay_barn","brook_cascade","brook_arch","pool_lilies"]
static var scenes: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://content/june_scenes.json"))
static func block(n: Node2D, at: Vector2, size: Vector2, tint: String) -> void:
	n.draw_rect(Rect2(at.round(),size),Color(tint))
static func leaves(n: Node2D, at: Vector2, w: float, h: float, tint: String) -> void:
	YBDayDecor.leaf(n,at,w,h,tint)
static func background(n: Node2D, key: String, cam: float, time: float) -> void:
	var s: Dictionary=scenes[key]
	var plate=YBLandscape.texture(s.plate)
	if plate: n.draw_texture_rect(plate,Rect2(-140-sin(cam*.00016)*130,-48,1560,878),false,Color(s.tint))
	# Keep painted composition intact. Small animated accents add depth without
	# introducing opaque bands or extra silhouettes across the quiet playfield.
	if key=="glasshouse_run":
		for i in 8:
			var x=fposmod(i*197-cam*.13,1420)-60
			var alpha=.07+maxf(0,sin(time*.55+i))*.05
			n.draw_line(Vector2(x,208+i%3*42),Vector2(x+22,183+i%3*42),Color(.88,.99,.87,alpha),2)
	elif key in ["riverside_rush","brookside_bounce"]:
		for i in 24:
			var x=fposmod(i*81-time*18-cam*.2,1400)-50
			n.draw_line(Vector2(x,554+i%5*9),Vector2(x+13+i%4*6,554+i%5*9),Color(.78,.92,.84,.14),2)
	elif key=="woodland_detour":
		var clearing=clampf(1-absf(cam+640-3450)/950,0,1)
		n.draw_rect(Rect2(0,0,1280,625),Color(.14,.27,.26,.13*(1-clearing)))
	elif key=="windmill_heights":
		for i in 2:
			var x=fposmod(i*710-cam*.16,1690)-160
			YBLandscape.mill(n,Vector2(x,516+i*29),time+i,.62)

static func props(n: Node2D, d: Dictionary, time: float) -> void:
	var at=Vector2(d.x,d.y);var w=float(d.get("width",180));var h=float(d.get("height",160));var t=time+float(d.get("phase",0))
	match str(d.type):
		"glasshouse_bay":
			var roof=at+Vector2(w*.5,-h)
			var corners=PackedVector2Array([at+Vector2(0,-h*.77),roof,at+Vector2(w,-h*.77),at+Vector2(w,0),at])
			n.draw_colored_polygon(corners,Color(.68,.84,.78,.19))
			for x in range(0,int(w)+1,62):
				n.draw_line(at+Vector2(x,0),at+Vector2(x,-h*.77),Color("71938b"),4)
				n.draw_line(at+Vector2(x,-h*.77),roof,Color("83a399"),3)
			for row in [0.25,0.5,0.77]: n.draw_line(at-Vector2(0,h*row),at+Vector2(w,-h*row),Color("89a99b"),3)
			n.draw_polyline(corners,Color("71948c"),5)
			for x in range(18,int(w),62):
				n.draw_line(at+Vector2(x,-h*.61),at+Vector2(x+21,-h*.70),Color(.87,.96,.84,.28),3)
				n.draw_line(at+Vector2(x+6,-h*.34),at+Vector2(x+26,-h*.43),Color(.88,.96,.89,.16),2)
		"palm_planter":
			block(n,at+Vector2(-w*.13,-24),Vector2(w*.26,24),"8e8f71")
			var crown=at+Vector2(0,-h*.74)
			n.draw_line(at-Vector2(0,20),crown,Color("798569"),7)
			for side in [-1,1]:
				for leaf_index in 4:
					var points=PackedVector2Array()
					for j in 8:
						var f=j/7.0;points.append(crown+Vector2(side*f*w*(.3+leaf_index*.045),-sin(f*PI)*h*.14+f*leaf_index*9+sin(t*.5+leaf_index)*f*3))
					n.draw_polyline(points,Color("58836a") if leaf_index%2 else Color("719778"),6-leaf_index)
					for j in range(2,8): n.draw_line(points[j],points[j]+Vector2(-side*9,9),Color("719778"),2)
		"fern_bed":
			for i in int(w/32):
				var base=at+Vector2(i*32,0)
				for side in [-1,1]:
					for j in 5:
						var f=j/5.0;var tip=base+Vector2(side*j*5,-sin(f*PI)*h*.6)
						n.draw_line(base,tip,Color("719a70"),2);n.draw_line(tip,tip+Vector2(side*5,-4),Color("8cb081"),3)
		"crossing_bridge":
			for side in [0,w]: block(n,at+Vector2(side,-h),Vector2(7,h+13),"7f9277")
			for i in 2: n.draw_line(at-Vector2(0,h*(.4+i*.5)),at+Vector2(w,-h*(.4+i*.5)),Color("8e9d7d"),5)
			for x in range(0,int(w),15): block(n,at+Vector2(x,-8),Vector2(13,6),"829783")
		"trail_fingerpost":
			block(n,at-Vector2(3,h),Vector2(7,h),"78876a")
			for i in 3:
				var side=1 if i%2==0 else -1;var origin=at-Vector2(0,h-13-i*20)
				n.draw_colored_polygon(PackedVector2Array([origin+Vector2(0,-6),origin+Vector2(side*38,-6),origin+Vector2(side*47,0),origin+Vector2(side*38,6),origin+Vector2(0,6)]),Color("b4ba8c"))
		"river_rapids":
			n.draw_colored_polygon(PackedVector2Array([at,at+Vector2(0,-h*.5),at+Vector2(w*.34,-h),at+Vector2(w*.67,-h*.6),at+Vector2(w,-h*.4),at+Vector2(w,0)]),Color("69a9ad"))
			for i in int(w/18):
				var x=fposmod(i*31+t*65,w-25);var y=-8-fposmod(i*17,maxf(10,h*.55))
				n.draw_line(at+Vector2(x,y),at+Vector2(x+15,y-2),Color("bad5c6"),2)
			for i in int(w/110):
				var pos=at+Vector2(45+i*110,-h*.31)
				leaves(n,pos,33,18,"778e86")
		"river_boat":
			var bob=Vector2(0,sin(t)*2)
			n.draw_colored_polygon(PackedVector2Array([at+Vector2(-w*.5,-20)+bob,at+Vector2(w*.5,-20)+bob,at+Vector2(w*.3,0)+bob,at+Vector2(-w*.3,0)+bob]),Color("8a977f"))
			n.draw_line(at+Vector2(-w*.35,-18)+bob,at+Vector2(w*.35,-18)+bob,Color("b0b294"),3)
			n.draw_line(at+Vector2(-20,-35)+bob,at+Vector2(55,6)+bob,Color("82987c"),3)
		"orchard_crown":
			var atlas=YBLandscape.texture("res://art/trees.png")
			if atlas: n.draw_texture_rect_region(atlas,Rect2(at-Vector2(w*.5,h),Vector2(w,h)),Rect2(0,64,538,875),Color("dce5b9"))
			for i in 16:
				var pos=at+Vector2((YBLandscape.hash_value(i+d.x)-.5)*w*.62,-h*(.42+YBLandscape.hash_value(i+8)*.38))
				block(n,pos,Vector2(4,5),"afbd74");block(n,pos+Vector2(0,1),Vector2(2,2),"d6d39a")
		"orchard_ladder":
			for side in [0,25]: n.draw_line(at+Vector2(side,0),at+Vector2(side+w*.4,-h),Color("aba983"),4)
			for j in range(1,int(h/18)):
				var f=j*18/h;n.draw_line(at+Vector2(w*.4*f,-j*18),at+Vector2(w*.4*f+25,-j*18),Color("beb996"),3)
		"fruit_basket":
			block(n,at-Vector2(0,h),Vector2(w,h),"9c9872")
			for y in range(5,int(h),8): block(n,at+Vector2(0,-y),Vector2(w,2),"b2a782")
			for i in int(w/9): n.draw_circle(at+Vector2(i*9+5,-h-3-i%2*3),5,Color("a6b776"))
		"wildflower_drift":
			for i in int(w/11):
				var height=h*(.45+YBLandscape.hash_value(i+d.x)*.55);var root=at+Vector2(i*11,0)
				var tip=root+Vector2(roundf(sin(t*.7+i)*3),-height)
				n.draw_line(root,tip,Color("65875d"),2)
				var tint=["a7b4d9","cda4ba","e7dca2","c4c6de"][i%4]
				if i%3==0:
					for j in 4: block(n,tip+Vector2(j%2*4,j*6),Vector2(5,5),tint)
				else:
					block(n,tip-Vector2(4,1),Vector2(9,3),tint);block(n,tip-Vector2(1,4),Vector2(3,9),tint);block(n,tip,Vector2(2,2),"f0de99")
		"pollinators":
			for i in 4:
				var pos=at+Vector2(fposmod(i*61+sin(t*.55+i)*35,w),-sin(t+i)*13)
				block(n,pos,Vector2(5,3),"c7b16b");block(n,pos+Vector2(2,-3),Vector2(4,2),"dce4c5")
		"woodland_trunk":
			var atlas=YBLandscape.texture("res://art/trees.png")
			if atlas:
				var tint=Color("a2c4b1") if d.get("pale",false) else Color("d3e0bc")
				n.draw_texture_rect_region(atlas,Rect2(at-Vector2(w*.5,h),Vector2(w,h)),Rect2(0,64,538,875),tint)
		"woodland_stump":
			block(n,at-Vector2(w*.4,h),Vector2(w*.8,h),"758167")
			leaves(n,at-Vector2(0,h-3),w,12,"b2ab87")
			for i in 3:
				var x=w*.3+i*13;block(n,at+Vector2(x,-12),Vector2(3,12),"aaa98c");leaves(n,at+Vector2(x,-11),13,7,"b6a190")
		"mill_tower":
			YBLandscape.mill(n,at,t,h/119)
			for x in [-18,18]: n.draw_line(at+Vector2(x*h/119,-h*.5),at+Vector2(x*h/119,-h*.24),Color("889b7d"),3)
		"wind_ribbon":
			block(n,at-Vector2(2,h),Vector2(4,h),"9fae8c")
			var head=at-Vector2(0,h)
			var points=PackedVector2Array([head,head+Vector2(w*.45,sin(t)*6+4),head+Vector2(w,sin(t+1)*8+3),head+Vector2(w*.85,sin(t+1)*8+15),head+Vector2(w*.4,sin(t)*6+19),head+Vector2(0,16)])
			n.draw_colored_polygon(points,Color("d6b78d"))
		"hay_roll":
			var center=at-Vector2(0,h*.5)
			var outline=PackedVector2Array()
			for i in 20: outline.append(center+Vector2(cos(i*TAU/20)*w*.5,sin(i*TAU/20)*h*.5))
			n.draw_colored_polygon(outline,Color("b0ad73"))
			for i in 18:
				var f=YBLandscape.hash_value(i+d.x);var pos=center+Vector2((f-.5)*w*.75,(YBLandscape.hash_value(i+8)-.5)*h*.6)
				n.draw_line(pos,pos+Vector2(4,2),Color("c8c18b"),1)
			for r in [h*.4,h*.29,h*.17]: n.draw_arc(center,r,0,TAU,16,Color("d0c58d"),2)
			n.draw_line(center-Vector2(w*.31,h*.24),center+Vector2(w*.3,h*.2),Color("a6a674"),2)
		"hay_barn":
			block(n,at-Vector2(0,h*.72),Vector2(w,h*.72),"7c7f6b")
			for x in range(3,int(w)-3,11):
				var grain=YBLandscape.hash_value(x+at.x)
				block(n,at+Vector2(x,-h*.70),Vector2(8,h*.70),"9d9a7c" if grain>.5 else "8e8e75")
				for j in 4:
					block(n,at+Vector2(x+2,-h*(.13+j*.15)+grain*8),Vector2(2,7+j*2),"777f69")
			var peak=at+Vector2(w*.44,-h)
			n.draw_colored_polygon(PackedVector2Array([at+Vector2(-10,-h*.70),peak,at+Vector2(w+10,-h*.70)]),Color("697567"))
			n.draw_colored_polygon(PackedVector2Array([at+Vector2(-10,-h*.70),peak,at+Vector2(w*.44,-h*.70)]),Color("80856b"))
			for row in range(1,7):
				var f=row/7.0
				var left=peak.lerp(at+Vector2(-10,-h*.70),f)
				var right=peak.lerp(at+Vector2(w+10,-h*.70),f)
				n.draw_line(left,right,Color("929079") if row%2 else Color("78806b"),2)
			block(n,at+Vector2(-3,-h*.71),Vector2(w+6,5),"65745f")
			var door=at+Vector2(w*.35,-h*.46);var door_size=Vector2(w*.32,h*.46)
			block(n,door,door_size,"5a6c5d")
			for x in range(0,int(door_size.x),12): block(n,door+Vector2(x,0),Vector2(2,door_size.y),"6e7b62")
			n.draw_line(door+Vector2(2,3),door+door_size-Vector2(2,3),Color("969379"),4)
			n.draw_line(door+Vector2(door_size.x-2,3),door+Vector2(2,door_size.y-3),Color("8a8e72"),4)
			for side in [0,w-5]: block(n,at+Vector2(side,-h*.70),Vector2(5,h*.70),"b0a58a")
			for i in 2: props(n,{"type":"hay_roll","x":at.x+24+i*31,"y":at.y,"width":34,"height":28},time)
		"brook_cascade":
			for i in 3:
				var pos=at+Vector2(i*w*.29,-h*(1-i*.3))
				var pool=PackedVector2Array()
				for j in 18:
					var angle=j*TAU/18
					pool.append(pos+Vector2(w*.14+cos(angle)*w*.17,sin(angle)*11+8))
				n.draw_colored_polygon(pool,Color(.41,.63,.61,.42))
				for j in 9:
					var x=fposmod(j*29+t*16,w*.28);var y=sin(j*2.3)*7+7
					n.draw_line(pos+Vector2(x,y),pos+Vector2(x+5+j%3*3,y),Color(.69,.81,.75,.44),2)
				for side in [-1,1]:
					leaves(n,pos+Vector2(w*(.14+side*.16),18),22,14,"7c9484")
				for j in 6:
					var x=j*3;var y=fposmod(j*13+t*65,h*.37)
					n.draw_line(pos+Vector2(w*.26+x,y+8),pos+Vector2(w*.26+x+3,y+18),Color(.73,.85,.77,.58),2)
		"brook_arch":
			var center=at+Vector2(w*.5,0)
			n.draw_arc(center,w*.45,PI,TAU,20,Color("8baba0"),16)
			for j in 11:
				var angle=PI+j*PI/10
				n.draw_line(center+Vector2.from_angle(angle)*(w*.45-8),center+Vector2.from_angle(angle)*(w*.45+8),Color("c0cec0"),2)
		"pool_lilies":
			leaves(n,at,w,h,"74aea7")
			for i in int(w/40):
				var pos=at+Vector2((i+.5)*40-w*.5,-h*.5+sin(t+i)*1.5)
				leaves(n,pos,22,7,"9cb88a");block(n,pos-Vector2(3,5),Vector2(5,4),"e5dbc3")
