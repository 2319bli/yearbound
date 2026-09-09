class_name YBDayDecor
extends RefCounted

# Per-day scenic vocabulary. These props never create collision or front-layer cover.
const TYPES=["willow","riverbank","dragonflies","kite","clover","orchard_tree","orchard_wall","trellis","railway","station","meadow_train","waterwheel","sluice","water_spray","sunflowers","hazel_arch","lantern_string","lantern_post","pavilion"]
static func rect(n: Node2D, at: Vector2, size: Vector2, tint: String) -> void:
	n.draw_rect(Rect2(at.round(),size),Color(tint))
static func leaf(n: Node2D, at: Vector2, width: float, height: float, tint: String) -> void:
	YBScenery.cluster(n,at.round(),width,height,Color(tint))
	# Small leaf clusters soften broad silhouettes while staying on the pixel grid.
	for i in int(width*height/180):
		var x=(YBLandscape.hash_value(i*19+at.x)-.5)*width*.65
		var y=(-.2-YBLandscape.hash_value(i*31+at.y)*.56)*height
		var color=Color(tint).lightened(.07) if i%3 else Color(tint).darkened(.06)
		n.draw_rect(Rect2((at+Vector2(x,y)).round(),Vector2(3+i%3,2+i%2)),color)
static func props(n: Node2D, d: Dictionary, time: float) -> void:
	var at=Vector2(d.x,d.y)
	var width=float(d.get("width",180))
	var height=float(d.get("height",160))
	var phase=float(d.get("phase",0))
	var t=time+phase
	match str(d.type):
		"willow":
			n.draw_polyline(PackedVector2Array([at,at+Vector2(-12,-height*.35),at+Vector2(2,-height*.72),at+Vector2(-14,-height)]),Color("53664e"),13)
			n.draw_polyline(PackedVector2Array([at+Vector2(-2,0),at+Vector2(-7,-height*.4),at+Vector2(7,-height*.76)]),Color("8c9264"),4)
			for side in [-1,1]: n.draw_line(at+Vector2(0,-height*.62),at+Vector2(side*width*.42,-height*.85),Color("68744f"),6)
			for i in 13:
				var x=(float(i)/12-.5)*width
				var root=at+Vector2(x,-height*.77-26*sin(float(i)/12*PI))
				leaf(n,root,42,48,"638b61");leaf(n,root-Vector2(4,5),32,32,"80a76e")
				var length=height*(.26+YBLandscape.hash_value(i+d.x)*.28)
				for j in range(0,int(length),8):
					var pos=root+Vector2(roundf(sin(t*.7+i+j*.035)*3),j)
					rect(n,pos,Vector2(3,7),"7b9e62" if j%16 else "537c58")
		"riverbank":
			var shape=PackedVector2Array([at+Vector2(0,-14),at+Vector2(28,-height*.65),at+Vector2(width*.35,-height),at+Vector2(width*.7,-height*.7),at+Vector2(width,-24),at+Vector2(width,12),at+Vector2(0,12)])
			n.draw_colored_polygon(shape,Color("659f9b"))
			for i in int(width/23):
				var x=14+i*23
				var y=-14-YBLandscape.hash_value(i+d.x)*height*.52
				n.draw_line(at+Vector2(x,y),at+Vector2(x+11+sin(t+i)*3,y),Color("a9c8b7"),2)
			for i in int(width/65):
				var pos=at+Vector2(20+i*65,-10-YBLandscape.hash_value(i)*15)
				leaf(n,pos,26,10,"718b80");leaf(n,pos-Vector2(2,2),18,6,"b1b8a0")
		"dragonflies":
			for i in 5:
				var p=at+Vector2(12+fposmod(i*57+sin(t*.6+i)*20,width),-18-sin(t*.9+i)*12)
				rect(n,p,Vector2(10,3),"6cc5cb")
				n.draw_line(p+Vector2(3,1),p+Vector2(0,-5-sin(t*16+i)*2),Color("c6e5dd"),2)
				n.draw_line(p+Vector2(4,1),p+Vector2(6,-6+sin(t*16+i)*2),Color("bfd9d4"),2)
		"kite":
			var head=at+Vector2(sin(t*.65)*12,-height+sin(t*.9)*6)
			var colors=["d9997f","adc8c5","d8c58a"]
			var tint=Color(colors[posmod(int(phase),3)])
			var size=width*.23
			var string=PackedVector2Array([at,at+Vector2(15,-height*.33),head+Vector2(-8,height*.28),head])
			n.draw_polyline(string,Color(.62,.7,.63,.5),1)
			n.draw_colored_polygon(PackedVector2Array([head+Vector2(0,-size),head+Vector2(size*.8,0),head+Vector2(0,size*1.3),head+Vector2(-size*.8,0)]),tint)
			n.draw_colored_polygon(PackedVector2Array([head+Vector2(0,-size),head+Vector2(size*.8,0),head+Vector2(0,size*1.3)]),tint.darkened(.16))
			for j in 6:
				var p=head+Vector2(sin(t+j*.5)*5,size*1.3+j*9)
				rect(n,p,Vector2(3,8),"a4bab0")
				if j%2==0: rect(n,p-Vector2(4,0),Vector2(10,3),colors[posmod(int(phase)+1,3)])
		"clover":
			for i in int(width/13):
				var p=at+Vector2(i*13,-5-YBLandscape.hash_value(i+d.x)*13)
				for offset in [Vector2(-3,0),Vector2(3,0),Vector2(0,-4)]: rect(n,p+offset,Vector2(5,5),"6c9663")
				if i%4==0:
					rect(n,p+Vector2(1,-7),Vector2(6,4),"d6c8d5");rect(n,p+Vector2(3,-10),Vector2(3,4),"ede3db")
		"orchard_tree":
			n.draw_line(at,at+Vector2(-4,-height*.64),Color("766f51"),10)
			for i in 7:
				var p=at+Vector2((i-3)*width/9,-height*.54-absf(sin(i))*height*.18)
				n.draw_line(at+Vector2(0,-height*.34),p-Vector2(0,22),Color("74754e"),5)
				leaf(n,p,width*.35,height*.34,"496f50");leaf(n,p-Vector2(4,8),width*.28,height*.26,"759155")
				for j in 4:
					var fruit=p+Vector2((YBLandscape.hash_value(i*7+j)-.5)*width*.24,-8-j*8)
					rect(n,fruit,Vector2(5,6),"a3ae68");rect(n,fruit+Vector2(0,1),Vector2(2,2),"c5ca83")
		"orchard_wall":
			for row in int(height/14):
				for x in range(0,int(width),36):
					var p=at+Vector2(x+(12 if row%2 else 0),-14-row*14)
					rect(n,p,Vector2(minf(33,width-x),12),"8b9476" if (row+x)%3 else "9a9c7d")
			for i in int(width/83):
				var p=at+Vector2(i*83+24,-height+8)
				YBScenery.ivy(n,p,42+YBLandscape.hash_value(i)*28,t)
		"trellis":
			for x in range(0,int(width)+1,22): n.draw_line(at+Vector2(x,0),at+Vector2(x,-height),Color("758669"),3)
			for y in range(15,int(height),22): n.draw_line(at-Vector2(0,y),at+Vector2(width,-y),Color("8e9a76"),2)
			for i in int(width/33):
				leaf(n,at+Vector2(i*33+10,-height*.5),45,height*.6,"54774f")
		"railway":
			for x in range(0,int(width),22): rect(n,at+Vector2(x,-4),Vector2(9,9),"677666")
			n.draw_line(at+Vector2(0,-3),at+Vector2(width,-3),Color("a3a28b"),2)
			n.draw_line(at+Vector2(0,3),at+Vector2(width,3),Color("77867a"),2)
		"station":
			rect(n,at-Vector2(0,height),Vector2(width,height),"728d77")
			for x in range(5,int(width),16): n.draw_line(at+Vector2(x,-height+6),at+Vector2(x,-2),Color("8b9f82"),2)
			n.draw_colored_polygon(PackedVector2Array([at+Vector2(-12,-height),at+Vector2(width*.5,-height-48),at+Vector2(width+12,-height)]),Color("657b73"))
			for row in range(1,7):
				var span=(width+24)*row/7.0
				for x in range(0,int(span),17):
					rect(n,at+Vector2(width*.5-span*.5+x,-height-48+row*7),Vector2(minf(14,span-x),3),"7f8f7d" if x%3 else "738575")
			n.draw_line(at+Vector2(-14,-height),at+Vector2(width+14,-height),Color("a4aa8c"),4)
			for x in range(20,int(width)-20,52):
				rect(n,at+Vector2(x,-height+23),Vector2(25,32),"b5b79c");rect(n,at+Vector2(x+3,-height+26),Vector2(19,26),"557a7c")
				rect(n,at+Vector2(x+11,-height+26),Vector2(2,26),"adb69b");rect(n,at+Vector2(x+3,-height+38),Vector2(19,2),"adb69b")
				rect(n,at+Vector2(x-3,-height+56),Vector2(31,8),"948c69")
				YBScenery.flowers(n,at+Vector2(x,-height+56),26,t,x,.65)
			rect(n,at+Vector2(width*.5-14,-50),Vector2(28,50),"4f6e65")
			rect(n,at+Vector2(width*.5-11,-47),Vector2(22,24),"839b88");rect(n,at+Vector2(width*.5+6,-20),Vector2(3,3),"b9b891")
			for x in [-9,width+6]: n.draw_line(at+Vector2(x,0),at+Vector2(x,-height*.66),Color("778b72"),4)
			n.draw_line(at+Vector2(-18,-height*.64),at+Vector2(width+18,-height*.64),Color("b4af82"),6)
		"meadow_train":
			var p=at+Vector2(fposmod(t*23,width),0)
			for i in 3:
				var body=p-Vector2(i*65,0)
				rect(n,body-Vector2(0,30),Vector2(57,26),"547e70" if i==0 else "b3a16e")
				if i==0:
					rect(n,body-Vector2(-28,49),Vector2(24,22),"75947d");rect(n,body-Vector2(-3,43),Vector2(8,18),"56766a")
				else:
					for x in [8,24,40]: rect(n,body+Vector2(x,-23),Vector2(10,15),"7f9c8b")
				for x in [10,43]: n.draw_circle(body+Vector2(x,-2),7,Color("536f68"));n.draw_line(body+Vector2(x-4,-2),body+Vector2(x+4,-2),Color("91a58b"),2)
			for i in 4:
				leaf(n,p+Vector2(8-i*18,-50-i*13),22+i*7,14+i*4,"c1c9ac")
		"waterwheel":
			var center=at-Vector2(0,height*.52);var radius=height*.47
			n.draw_line(at-Vector2(0,6),center,Color("637567"),10)
			n.draw_arc(center,radius,0,TAU,48,Color("566f65"),10)
			n.draw_arc(center,radius-12,0,TAU,48,Color("a09671"),4)
			for i in 12:
				var angle=t*.35+i*TAU/12
				var dir=Vector2.from_angle(angle);var tip=center+dir*radius
				n.draw_line(center,tip,Color("637969"),5)
				n.draw_line(tip-dir.orthogonal()*13,tip+dir.orthogonal()*13,Color("a6a17b"),7)
				n.draw_line(tip-dir*3-dir.orthogonal()*11,tip-dir*3+dir.orthogonal()*11,Color("c0b28b"),2)
			n.draw_circle(center,11,Color("667b65"));n.draw_circle(center,4,Color("b2b594"))
		"sluice":
			for x in [0,width]: rect(n,at+Vector2(x,-height),Vector2(10,height),"748776")
			for y in range(10,int(height),14): rect(n,at+Vector2(10,-y),Vector2(width-10,10),"8d9d82")
			n.draw_line(at+Vector2(width*.5,-height-24),at+Vector2(width*.5,-10),Color("647d72"),4)
			n.draw_circle(at+Vector2(width*.5,-height-24),13,Color("6b8478"),false,3)
		"water_spray":
			for i in 18:
				var x=YBLandscape.hash_value(i)*width
				var y=fposmod(t*90+i*17,height)
				rect(n,at+Vector2(x,-height+y),Vector2(2,6),"bed8cc")
			for i in 8: n.draw_circle(at+Vector2(i*width/8,-6),10,Color(.72,.87,.80,.08))
		"sunflowers":
			for i in int(width/29):
				var root=at+Vector2(i*29+8,0);var h=height*(.65+YBLandscape.hash_value(i+d.x)*.35)
				var lean=roundf(sin(t*.65+i)*3);var head=root+Vector2(lean,-h)
				n.draw_line(root,head,Color("526b42"),4)
				for j in [1,2,3]:
					var p=root+Vector2(0,-h*j/5)
					n.draw_colored_polygon(PackedVector2Array([p,p+Vector2(-17,-9),p+Vector2(-13,-18),p+Vector2(-3,-14)]),Color("72864a"))
					n.draw_colored_polygon(PackedVector2Array([p-Vector2(0,12),p+Vector2(16,-26),p+Vector2(21,-20),p+Vector2(8,-9)]),Color("647c43"))
				for j in 8:
					var end=head+Vector2.from_angle(j*TAU/8)*12
					rect(n,end-Vector2(4,4),Vector2(8,8),"d6b65c" if j%2 else "c99b43")
				rect(n,head-Vector2(7,7),Vector2(14,14),"7d7043");rect(n,head-Vector2(5,5),Vector2(5,4),"aa8f4f")
		"hazel_arch":
			for side in [0,1]:
				var root=at+Vector2(width*side,0)
				n.draw_polyline(PackedVector2Array([root,root+Vector2(18 if side==0 else -18,-height*.6),at+Vector2(width*.5,-height)]),Color("687853"),8)
			for i in 8:
				var p=at+Vector2(i*width/7,-height+sin(float(i)/7*PI)*-20)
				leaf(n,p,width*.24,40,"4b7154");leaf(n,p-Vector2(4,9),width*.2,25,"72915e")
		"lantern_string":
			var rope=PackedVector2Array()
			for i in 21: rope.append(at+Vector2(i*width/20,sin(float(i)/20*PI)*24))
			n.draw_polyline(rope,Color("7c8277"),2)
			for i in range(1,int(width/65)):
				var x=i*65.0;var root=at+Vector2(x,sin(x/width*PI)*24)
				var p=root+Vector2(roundf(sin(t*.8+i)*3),18)
				n.draw_line(root,p,Color("9a9b85"),1)
				lantern(n,p,1.0 if i%3 else 1.3)
		"lantern_post":
			n.draw_line(at,at-Vector2(0,height),Color("6d796d"),5)
			n.draw_line(at-Vector2(0,height),at+Vector2(30,-height),Color("879082"),3)
			lantern(n,at+Vector2(28+sin(t)*2,-height+18),1.2)
		"pavilion":
			for x in [0,width*.33,width*.67,width]: n.draw_line(at+Vector2(x,0),at+Vector2(x,-height),Color("87938b"),5)
			n.draw_colored_polygon(PackedVector2Array([at+Vector2(-16,-height),at+Vector2(width*.5,-height-45),at+Vector2(width+16,-height)]),Color("7f8189"))
			n.draw_line(at+Vector2(-8,-height+5),at+Vector2(width+8,-height+5),Color("b3a38b"),4)
			for x in range(16,int(width),43): lantern(n,at+Vector2(x,-height+32),.7)
static func lantern(n: Node2D, at: Vector2, scale_value: float) -> void:
	for radius in [28,18]: n.draw_circle(at,radius*scale_value,Color(1,.72,.38,.045))
	rect(n,at-Vector2(8,11)*scale_value,Vector2(16,22)*scale_value,"dca97d")
	rect(n,at-Vector2(5,9)*scale_value,Vector2(10,17)*scale_value,"f0c990")
	rect(n,at-Vector2(3,8)*scale_value,Vector2(6,15)*scale_value,"f8dfa5")
	rect(n,at+Vector2(-5,11)*scale_value,Vector2(10,3)*scale_value,"bca789")
