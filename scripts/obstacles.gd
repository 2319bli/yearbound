class_name YBObstacles
extends RefCounted
## Seasonal machines share their visible geometry with contact and dash sweeps.
## All timing comes from world age, so pause, replay and checkpoint resets agree.
const KINDS = ["windmill", "pendulum", "press", "shutter", "geyser", "bloom", "sawrail", "arc"]
const INK = Color("233b40")
const EDGE = Color("ffd296")
const DANGER = Color("df7656")

static func phase(h: Dictionary, time: float) -> float:
	return fposmod(time + float(h.get("phase", 0)), float(h.get("period", 4)))

static func state(h: Dictionary, time: float) -> String:
	if h.mechanism in ["windmill", "pendulum"]: return "moving"
	var t = phase(h, time)
	if t < float(h.get("safe_seconds", 1.05)): return "open"
	if t < float(h.get("safe_seconds", 1.05)) + float(h.get("warning_seconds", .65)): return "warning"
	return "active"

static func parts(h: Dictionary, time: float) -> Array:
	var at = Vector2(h.x, h.y)
	var t = phase(h, time)
	var period = float(h.get("period", 4))
	var radius = float(h.get("radius", 120))
	var result: Array = []
	if h.mechanism == "windmill":
		for i in int(h.get("blades", 3)):
			var angle = t / period * TAU * float(h.get("rotation_direction", 1)) + i * TAU / int(h.get("blades", 3))
			var ray = Vector2.from_angle(angle)
			result.append({"a": at + ray * 24, "b": at + ray * radius, "r": float(h.get("thickness", 8))})
	elif h.mechanism == "pendulum":
		var angle = sin(t / period * TAU) * float(h.get("swing", 1.0))
		result.append({"center": at + Vector2(sin(angle), cos(angle)) * radius, "r": float(h.get("head_radius", 21))})
	elif state(h, time) == "active":
		var active_time = t - float(h.get("safe_seconds", 1.05)) - float(h.get("warning_seconds", .65))
		var duration = period - float(h.get("safe_seconds", 1.05)) - float(h.get("warning_seconds", .65))
		var transition=maxf(.02,float(h.get("extension_seconds",.18)))
		var extension = minf(clampf(active_time / transition, 0, 1), clampf((duration - active_time) / transition, 0, 1))
		if extension <= .01:return result
		match h.mechanism:
			"press": result.append({"rect": Rect2(at + Vector2(0, -(1-extension)*float(h.h)), Vector2(h.w, h.h))})
			"shutter": result.append({"rect": Rect2(at, Vector2(h.w*extension, h.h))})
			"geyser": result.append({"rect": Rect2(at + Vector2(0, float(h.h)*(1-extension)), Vector2(h.w, float(h.h)*extension))})
			"bloom": result.append({"center": at, "r": float(h.get("head_radius", 42))*extension})
			"sawrail":
				var progress = active_time / maxf(.01, duration)
				result.append({"center": at + Vector2(sin(progress*TAU)*float(h.get("travel", 60)), 0), "r": float(h.get("head_radius", 23))})
			"arc": result.append({"a": at, "b": at + Vector2(h.get("dx", 0), h.get("dy", 144)), "r": float(h.get("thickness", 6))*extension})
	return result

static func segments_near(a: Vector2, b: Vector2, c: Vector2, d: Vector2, distance: float) -> bool:
	if Geometry2D.segment_intersects_segment(a,b,c,d) != null: return true
	return minf(minf(a.distance_to(Geometry2D.get_closest_point_to_segment(a,c,d)), b.distance_to(Geometry2D.get_closest_point_to_segment(b,c,d))), minf(c.distance_to(Geometry2D.get_closest_point_to_segment(c,a,b)), d.distance_to(Geometry2D.get_closest_point_to_segment(d,a,b)))) < distance

static func touches(h: Dictionary, time: float, from_feet: Vector2, to_feet: Vector2) -> bool:
	if maxf(from_feet.x,to_feet.x)<float(h.x)-512 or minf(from_feet.x,to_feet.x)>float(h.x)+512:return false
	for part in parts(h,time):
		# A capsule enclosing the same 20x38 contact body used by ordinary hazards.
		for height in [10, 19, 28]:
			var a = from_feet - Vector2(0,height)
			var b = to_feet - Vector2(0,height)
			if part.has("rect"):
				if YBWorld.segment_hits_rect(a,b,part.rect.grow(10)): return true
			elif part.has("center"):
				if part.center.distance_to(Geometry2D.get_closest_point_to_segment(part.center,a,b)) < part.r + 10: return true
			elif segments_near(a,b,part.a,part.b,part.r+10): return true
	return false

static func draw(n: Node2D, h: Dictionary, time: float) -> void:
	var at = Vector2(h.x,h.y)
	var mode = str(h.mechanism)
	var status = state(h,time)
	var tint = Color(str(h.get("color", "a68c65")))
	if mode == "windmill":
		for part in parts(h,time):
			var normal = (part.b-part.a).normalized().orthogonal()
			var sail = PackedVector2Array([part.a-normal*part.r,part.b-normal*part.r,part.b+normal*part.r,part.a+normal*part.r])
			n.draw_line(part.a,part.b,INK,part.r*2+5,true)
			n.draw_colored_polygon(sail,tint.lightened(.15))
			n.draw_line(part.a+normal*part.r,part.b+normal*part.r,EDGE,2,true)
			n.draw_line(part.a-normal*(part.r-2),part.b-normal*(part.r-2),tint.darkened(.3),2,true)
			for i in range(1,5):
				var cross: Vector2 = part.a.lerp(part.b,i/5.0)
				n.draw_line(cross-normal*part.r,cross+normal*part.r,INK,2,true)
		n.draw_circle(at,22,INK,true,-1,true);n.draw_circle(at,15,tint,true,-1,true);n.draw_circle(at,6,EDGE,true,-1,true)
	elif mode == "pendulum":
		var bob: Vector2 = parts(h,time)[0].center
		n.draw_line(at,bob,INK,7,true);n.draw_line(at,bob,tint,3,true)
		n.draw_circle(at,10,INK,true,-1,true);n.draw_circle(at,5,EDGE,true,-1,true)
		draw_wheel(n,bob,float(h.get("head_radius",21)),time,tint)
	else:
		var extent = Vector2(float(h.get("w",72)),float(h.get("h",144)))
		var foot = at+Vector2(extent.x*.5,extent.y) if mode in ["press","shutter","geyser"] else at
		var lamp = EDGE if status=="warning" else (DANGER if status=="active" else Color("7ec7ae"))
		if mode in ["press","shutter","geyser"]:
			n.draw_rect(Rect2(at,extent),Color(1,.79,.48,.07),false,1)
			if mode == "press" and status != "active":
				n.draw_rect(Rect2(at-Vector2(0,28),Vector2(extent.x,24)),INK)
				n.draw_line(at-Vector2(0,4),at+Vector2(extent.x,-4),tint,4)
			if mode != "geyser":
				n.draw_line(at-Vector2(7,12),at+Vector2(-7,extent.y),INK,6)
				n.draw_line(at+Vector2(extent.x+7,-12),at+extent+Vector2(7,0),INK,6)
			n.draw_rect(Rect2(foot-Vector2(extent.x*.5+8,2),Vector2(extent.x+16,10)),INK)
			n.draw_line(foot-Vector2(extent.x*.5,0),foot+Vector2(extent.x*.5,0),lamp,3)
		elif mode == "arc":
			var end = at+Vector2(h.get("dx",0),h.get("dy",144))
			n.draw_circle(at,12,INK,true,-1,true);n.draw_circle(end,12,INK,true,-1,true)
			n.draw_circle(at,7,lamp,true,-1,true);n.draw_circle(end,7,lamp,true,-1,true)
			if status=="warning":n.draw_line(at,end,Color(1,.76,.4,.5),2,true)
		elif mode == "sawrail":
			var travel = float(h.get("travel",60))
			n.draw_line(at-Vector2(travel,0),at+Vector2(travel,0),INK,6,true)
			n.draw_line(at-Vector2(travel,0),at+Vector2(travel,0),tint,2,true)
		else:
			n.draw_circle(at,9,INK,true,-1,true);n.draw_circle(at,5,lamp,true,-1,true)
		if status == "warning":
			n.draw_arc(foot,17,0,TAU,20,EDGE,2,true)
		for part in parts(h,time):
			if part.has("rect"):
				var rect: Rect2 = part.rect
				if mode=="geyser":
					n.draw_rect(rect,Color(tint,.4));n.draw_line(Vector2(rect.get_center().x,rect.position.y),Vector2(rect.get_center().x,rect.end.y),EDGE,6,true)
					for i in 5:
						var y = rect.end.y-fposmod(time*240+i*37,maxf(1,rect.size.y))
						n.draw_line(Vector2(rect.position.x+6,y),Vector2(rect.end.x-6,y-9),Color(EDGE,.65),2,true)
				else:
					n.draw_rect(rect,INK);n.draw_rect(rect.grow(-3),tint);n.draw_rect(rect.grow(-7),tint.darkened(.23))
					n.draw_line(Vector2(rect.position.x,rect.end.y),rect.end,EDGE,4)
					if rect.size.x>18 and rect.size.y>24:
						for corner in [rect.position+Vector2(9,9),Vector2(rect.end.x-9,rect.position.y+9),rect.end-Vector2(9,9),Vector2(rect.position.x+9,rect.end.y-9)]:
							n.draw_rect(Rect2(corner-Vector2(2,2),Vector2(4,4)),EDGE)
						n.draw_line(rect.position+Vector2(9,16),rect.end-Vector2(9,16),tint.lightened(.15),2)
			elif part.has("center"):
				if mode=="bloom":draw_bloom(n,part.center,part.r,time)
				else:draw_wheel(n,part.center,part.r,time,tint)
			else:
				n.draw_line(part.a,part.b,Color(.5,.8,1,.24),18,true);n.draw_line(part.a,part.b,EDGE,part.r*2,true);n.draw_line(part.a,part.b,Color.WHITE,2,true)

static func draw_wheel(n: Node2D, at: Vector2, radius: float, time: float, tint: Color) -> void:
	var outline = PackedVector2Array()
	for i in 24: outline.append(at+Vector2.from_angle(i*TAU/24+time*2)*radius*(1 if i%2==0 else .72))
	if radius < 1:return
	outline.append(outline[0]);n.draw_colored_polygon(outline,INK);n.draw_polyline(outline,EDGE,2,true)
	for i in 5:n.draw_line(at,at+Vector2.from_angle(i*TAU/5+time*2)*radius*.6,tint,3,true)
	n.draw_circle(at,5,EDGE,true,-1,true)

static func draw_bloom(n: Node2D, at: Vector2, radius: float, time: float) -> void:
	if radius<1:return
	var ring=PackedVector2Array()
	for i in 24:
		var angle=i*TAU/24+sin(time*.8)*.07
		ring.append(at+Vector2.from_angle(angle)*radius*(1 if i%3==0 else .64))
	n.draw_colored_polygon(ring,INK)
	for i in 8:
		var ray=Vector2.from_angle(i*TAU/8+sin(time*.8)*.07)
		var side=ray.orthogonal()
		var petal=PackedVector2Array([at+ray*radius*.2-side*radius*.13,at+ray*radius*.92,at+ray*radius*.2+side*radius*.13])
		n.draw_colored_polygon(petal,Color("b26980"))
		n.draw_line(at+ray*radius*.5,at+ray*radius*.96,EDGE,2)
	n.draw_circle(at,radius*.25,Color("456b53"))
	n.draw_circle(at,radius*.12,EDGE)

static func draw_mount(n: Node2D, h: Dictionary, floor_y: float) -> void:
	# Mounts belong behind the player and terrain; only the turning sails hurt.
	var at=Vector2(h.x,h.y);var foot=Vector2(h.x,floor_y)
	var wood=Color("655c45");var light=Color("998c68")
	for side in [-1,1]:
		var a=at+Vector2(side*10,8);var b=foot+Vector2(side*34,3)
		n.draw_line(a,b,INK,13);n.draw_line(a,b,wood,9);n.draw_line(a+Vector2(-2,0),b+Vector2(-2,0),light,2)
		n.draw_rect(Rect2(b-Vector2(9,3),Vector2(18,6)),INK)
	var middle=at.lerp(foot,.62)
	n.draw_line(middle-Vector2(24,0),middle+Vector2(24,0),wood,7)
	n.draw_line(at+Vector2(-13,32),middle+Vector2(24,0),light,3)
