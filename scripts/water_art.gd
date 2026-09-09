class_name YBWaterArt
extends RefCounted
## Rear water carries the depth; foreground detail stays sparse and translucent.
static func volume(n: Node2D, z: Dictionary, cam: float, time: float) -> void:
	var left=maxf(z.x,cam-40);var right=minf(z.x+z.w,cam+1320)
	if right<=left: return
	var top=float(z.y);var bottom=minf(720,z.y+z.h)
	for y in range(int(top),int(bottom),12):
		var depth=clampf((y-top)/maxf(1,bottom-top),0,1)
		var tint=Color("4d9caa").lerp(Color("173e59"),depth)
		n.draw_rect(Rect2(left,y,right-left,12),Color(tint,.64))
	# Broken shafts sit behind terrain and hazards, never over their outlines.
	for i in range(floori(left/210),ceili(right/210)):
		var x=i*210+sin(time*.3+i)*12
		var a=maxf(left,x);var b=minf(right,x+42)
		if b>a:
			n.draw_colored_polygon(PackedVector2Array([Vector2(a,top+6),Vector2(b,top+6),Vector2(minf(right,b+120),bottom),Vector2(minf(right,a+80),bottom)]),Color(.65,.85,.77,.035))
	for i in range(floori(left/320),ceili(right/320)):
		var fish=Vector2(i*320+60+sin(time*.25+i)*45,top+96+fposmod(i*97,250))
		for j in 3:
			var at=fish+Vector2(j*22,j%2*11)
			n.draw_rect(Rect2(at,Vector2(9,3)),Color("356878"))
			n.draw_line(at-Vector2(3,2),at+Vector2(1,2),Color("356878"),2)
	# Water plants are scenery, with their roots hidden behind the flat riverbed.
	for i in range(floori(left/96),ceili(right/96)):
		var x=i*96+27
		for stem in 3:
			var points=PackedVector2Array()
			for j in 7:
				points.append(Vector2(x+stem*6+sin(time*.8+i+j*.3)*j*1.2,624-j*(5+i%4)))
			n.draw_polyline(points,Color("4c817b"),2)
	n.draw_rect(Rect2(left,top,right-left,3),Color("a8d9d7"))
	n.draw_rect(Rect2(left,top+4,right-left,3),Color(.63,.85,.86,.28))
	for i in range(floori(left/51),ceili(right/51)):
		var x=i*51+sin(time*1.2+i)*8
		n.draw_line(Vector2(maxf(left,x),top-2),Vector2(minf(right,x+24),top-2),Color(.77,.92,.9,.52),2)

static func foreground(n: Node2D, volumes: Array, cam: float, time: float, player: CharacterBody2D) -> void:
	for z in volumes:
		var left=maxf(z.x,cam);var right=minf(z.x+z.w,cam+1280)
		if right<=left: continue
		# Only a light wash crosses the actor. Terrain caps and hazards stay crisp.
		n.draw_rect(Rect2(left,z.y,right-left,minf(720,z.y+z.h)-z.y),Color(.15,.45,.53,.075))
		for i in range(floori(left/90),ceili(right/90)):
			var at=Vector2(i*90+sin(time*.6+i)*8,z.y+12+fposmod(i*63-time*(14+i%4*4),minf(z.h,475)))
			n.draw_rect(Rect2(at.round(),Vector2(2,2)),Color(.71,.92,.90,.38))
		for i in range(floori(left/77),ceili(right/77)):
			var x=i*77+sin(time+i)*12
			n.draw_line(Vector2(x,615),Vector2(x+17,613),Color(.55,.86,.81,.14),2)
	if player.swimming.submerged:
		for i in 3:
			var phase=fposmod(time*.75+i*.33,1)
			var at=player.position+Vector2(player.facing*10+sin(phase*8+i)*5,-36-phase*43)
			if at.y>player.swimming.surface_y+6:
				n.draw_circle(at.round(),2+i%2,Color(.75,.96,.95,.55*(1-phase)),false,1)
