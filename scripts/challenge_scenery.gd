class_name YBChallengeScenery
extends RefCounted
## Original code-native scenery. Every place stores an editable composition.
## Background architecture never owns colliders or uses the terrain's top trim.
const KINDS = ["mill","aqueduct","factory","belfry","ruins","railway","waterfall","glasshouse","clock","sluice","observatory"]

static func errors(art: Variant, regions: Variant) -> PackedStringArray:
	var out: PackedStringArray=[]
	if not art is Dictionary or art.get("renderer","")!="composition" or art.get("revision",0)!=1:
		return PackedStringArray(["Unknown scenery composition version."])
	if not regions is Array or regions.is_empty():return PackedStringArray(["Composed scenery needs named places."])
	for region in regions:
		if not region is Dictionary or not region.get("composition") is Dictionary:
			out.append("A place needs a scenery composition.");continue
		var c: Dictionary=region.composition
		if not c.get("palette") is Array or c.palette.size()!=6 or not c.palette.all(func(v):return v is String and Color.html_is_valid(v)):
			out.append("A composition needs six valid palette colors.")
		if not c.get("ridges") is Array or c.ridges.size()!=3:out.append("A composition needs three landscape layers.")
		else:
			for ridge in c.ridges:
				if not ridge is Array or ridge.size()<3 or ridge.size()>100 or not ridge.all(YBLayoutDocument.point):out.append("Invalid scenery silhouette.")
		if not c.get("structures") is Array or c.structures.size()>20:out.append("Invalid scenery landmarks.")
		else:
			for item in c.structures:
				if not item is Dictionary or item.get("kind","") not in KINDS:out.append("Unknown scenery landmark.");continue
				for key in ["x","y","w","h"]:
					if not YBObstacleRules.numeric(item.get(key)):out.append("Landmark dimensions must be finite.")
				for key in ["w","h"]:
					if YBObstacleRules.numeric(item.get(key)) and (item[key]<=0 or item[key]>2000):out.append("Landmark sizes must be 1–2000.")
		if not c.get("sun") is Array or c.sun.size()!=3 or not c.sun.all(YBObstacleRules.numeric):out.append("Invalid scenery light.")
		for key in ["waterline","seed"]:
			if not YBObstacleRules.numeric(c.get(key)):out.append("Invalid scenery "+key+".")
		if c.get("weather","") not in ["rain","snow","pollen","bubbles"]:out.append("Unknown scenery weather.")
	return out

static func background(n: Node2D, spec: Dictionary, x: float, cam: float, time: float) -> void:
	var regions: Array=spec.journey_regions
	var view=YBMapScenery.selection(regions,x)
	if view.blend<1:plate(n,regions[view.previous].composition,cam,time,1)
	plate(n,regions[view.index].composition,cam,time,view.blend)

static func disk(n: Node2D, at: Vector2, radius: float, tint: Color) -> void:
	for y in range(-int(radius),int(radius),4):
		var half= floorf(sqrt(maxf(0,radius*radius-y*y))/4)*4
		n.draw_rect(Rect2(at+Vector2(-half,y),Vector2(half*2,4)),tint)

static func plate(n: Node2D, c: Dictionary, cam: float, time: float, alpha: float) -> void:
	var p: Array[Color]=[]
	for hex in c.palette:p.append(Color(str(hex),alpha))
	for y in range(-64,800,8):
		n.draw_rect(Rect2(-100,y,1500,8),p[0].lerp(p[1],clampf(float(y)/650,0,1)))
	var sun=Vector2(c.sun[0],c.sun[1]);var glow=p[5];glow.a=alpha*.1
	disk(n,sun,float(c.sun[2])+24,glow);disk(n,sun,float(c.sun[2]),p[5].lerp(p[1],.25))
	if c.get("moon",false):disk(n,sun+Vector2(16,-9),float(c.sun[2])*.86,p[0])
	# Broken cloud bands retain the source's pixel vocabulary and soft distance.
	for j in 8:
		var xx=fposmod(j*223+float(c.seed)*19-cam*.015-time*1.2,1570)-190
		var yy=42+fposmod(j*53+float(c.seed)*3,195)
		for band in 3:n.draw_rect(Rect2(xx+band*18,yy+band*8,120-band*24,8),Color(p[1],alpha*.24))
	for i in 3:
		var points=PackedVector2Array([Vector2(-220,800)])
		for pair in c.ridges[i]:points.append(Vector2(pair[0]-fposmod(cam*(.012+i*.006),35),pair[1]))
		points.append(Vector2(1500,800));n.draw_colored_polygon(points,p[2+i].lerp(p[1],.28-i*.06))
	for item in c.structures:
		var at=Vector2(item.x-fposmod(cam*.028,52),item.y)
		landmark(n,item.kind,at,Vector2(item.w,item.h),p,time,alpha)
	var line=float(c.waterline)
	if c.weather in ["bubbles","rain"] or c.style in ["aqueduct","waterfall","sluice"]:
		n.draw_rect(Rect2(-100,line,1500,300),Color(p[2].lerp(p[0],.4),alpha*.66))
		for j in 52:
			var xx=fposmod(j*173+float(c.seed)*9+sin(time*.3+j)*14-cam*.06,1400)-60
			var yy=line+9+fposmod(j*29,210)
			n.draw_rect(Rect2(xx,yy,10+(j%5)*14,2),Color(p[1],alpha*(.08+(j%4)*.025)))
	if c.foliage:
		for j in 15:
			var xx=fposmod(j*119+float(c.seed)*17-cam*.09,1490)-110
			var yy=510+(j%4)*26;var hh=30+(j*37+int(c.seed))%87
			n.draw_rect(Rect2(xx,yy-hh,5,hh),Color(p[4],alpha*.5))
			for t in 5:
				var sx=xx-30+(t%3)*19;var sy=yy-hh-10-(t/3)*16
				n.draw_rect(Rect2(sx,sy,34,22),Color(p[3].lerp(p[2],float(t%2)*.25),alpha*.55))
	for j in 65:
		var xx=fposmod(j*97+float(c.seed)*13-cam*.08,1380)-50
		var yy=fposmod(j*61+time*(25 if c.weather=="snow" else (-24 if c.weather=="bubbles" else 130)),760)-20
		if c.weather=="rain":n.draw_line(Vector2(xx,yy),Vector2(xx-3,yy+15),Color(p[1],alpha*.19),1)
		elif c.weather=="bubbles":n.draw_circle(Vector2(xx+sin(time+j)*5,yy),2+j%3,Color(p[1],alpha*.14),false,1)
		else:n.draw_rect(Rect2(xx+sin(time*.4+j)*10,yy,2,2),Color(p[1],alpha*.4))

static func landmark(n: Node2D, kind: String, at: Vector2, size: Vector2, p: Array[Color], time: float, alpha: float) -> void:
	var x=at.x;var y=at.y;var w=size.x;var h=size.y
	var stone=p[3].lerp(p[2],.35);var shade=p[4].lerp(p[2],.3);var edge=p[2].lerp(p[1],.2)
	match kind:
		"mill":
			n.draw_colored_polygon(PackedVector2Array([Vector2(x,y),Vector2(x+w,y),Vector2(x+w*.68,y-h),Vector2(x+w*.3,y-h)]),stone)
			n.draw_colored_polygon(PackedVector2Array([Vector2(x+w*.22,y-h),Vector2(x+w*.5,y-h-35),Vector2(x+w*.77,y-h)]),shade)
			var hub=Vector2(x+w*.5,y-h*.76)
			for i in 4:
				var ray=Vector2.from_angle(time*.14+i*TAU/4);var normal=ray.orthogonal()
				n.draw_colored_polygon(PackedVector2Array([hub+ray*12,hub+ray*h*.55,hub+ray*h*.55+normal*14,hub+ray*12+normal*6]),edge)
			n.draw_circle(hub,6,shade)
		"aqueduct","railway":
			for j in 4:
				var xx=x+j*w*.6
				n.draw_rect(Rect2(xx,y-h,w*.22,h),stone)
				n.draw_colored_polygon(PackedVector2Array([Vector2(xx,y-h),Vector2(xx+w*.75,y-h),Vector2(xx+w*.75,y-h+40),Vector2(xx+w*.45,y-h+18),Vector2(xx+w*.2,y-h+40)]),stone)
				n.draw_rect(Rect2(xx-3,y-h-11,w*.66,9),edge)
				if kind=="railway":
					n.draw_rect(Rect2(xx,y-h-31,w*.58,18),shade)
					for t in 3:n.draw_rect(Rect2(xx+7+t*14,y-h-27,8,6),edge)
		"factory","sluice":
			n.draw_rect(Rect2(x,y-h*.65,w,h*.65),stone)
			for j in 3:
				n.draw_rect(Rect2(x+10+j*w*.32,y-h,w*.12,h),shade)
				n.draw_rect(Rect2(x+7+j*w*.32,y-h-6,w*.12+6,8),edge)
				n.draw_rect(Rect2(x+15+j*w*.27,y-h*.51,w*.12,h*.27),p[2])
			if kind=="sluice":
				for j in 7:n.draw_rect(Rect2(x+w*.7+j*5,y-h*.48,2,h*.6),Color(p[1],alpha*.3))
		"belfry","clock":
			n.draw_rect(Rect2(x+w*.23,y-h,w*.54,h),stone)
			n.draw_rect(Rect2(x+w*.17,y-h,w*.66,12),edge)
			n.draw_colored_polygon(PackedVector2Array([Vector2(x+w*.16,y-h),Vector2(x+w*.5,y-h-50),Vector2(x+w*.84,y-h)]),shade)
			var center=Vector2(x+w*.5,y-h*.78)
			if kind=="clock":
				disk(n,center,w*.17,edge);n.draw_line(center,center+Vector2(0,-w*.12),shade,3);n.draw_line(center,center+Vector2(w*.1,5),shade,3)
			else:
				n.draw_rect(Rect2(center-Vector2(w*.14,18),Vector2(w*.28,42)),shade)
				n.draw_colored_polygon(PackedVector2Array([center+Vector2(-w*.1,17),center+Vector2(w*.1,17),center+Vector2(5,-5),center+Vector2(-5,-5)]),edge)
			for j in 4:n.draw_rect(Rect2(x+w*.4,y-32-j*28,w*.18,13),shade)
		"ruins":
			for j in 5:
				var hh=h*(.5+float(j%3)*.2);var xx=x+j*w*.35
				n.draw_rect(Rect2(xx,y-hh,w*.18,hh),stone)
				n.draw_rect(Rect2(xx-5,y-hh,w*.18+10,12),edge)
				for t in 4:n.draw_rect(Rect2(xx+3,y-hh+t*hh/4,w*.12,2),shade)
		"waterfall":
			n.draw_colored_polygon(PackedVector2Array([Vector2(x-30,y),Vector2(x,y-h),Vector2(x+w,y-h-35),Vector2(x+w+45,y)]),stone)
			for j in 9:
				n.draw_rect(Rect2(x+w*.3+j*4,y-h-15,3,h+75),Color(p[1],alpha*(.22+(j%3)*.12)))
				var yy=y-h+fposmod(time*42+j*37,h)
				n.draw_rect(Rect2(x+w*.3+j*4,yy,3,17),Color(p[1],alpha*.6))
		"glasshouse":
			var roof=PackedVector2Array([Vector2(x,y),Vector2(x,y-h*.65),Vector2(x+w*.5,y-h),Vector2(x+w,y-h*.65),Vector2(x+w,y)])
			n.draw_colored_polygon(roof,Color(p[2],alpha*.5));roof.append(roof[0]);n.draw_polyline(roof,edge,4)
			for j in 6:n.draw_line(Vector2(x+j*w/5,y),Vector2(x+j*w/5,y-h*.65),stone,3)
			for j in 3:n.draw_line(Vector2(x,y-j*h*.21),Vector2(x+w,y-j*h*.21),stone,3)
		"observatory":
			n.draw_rect(Rect2(x,y-h*.65,w,h*.65),stone);disk(n,Vector2(x+w*.5,y-h*.65),w*.5,shade)
			n.draw_rect(Rect2(x,y-h*.65,w,w*.5),stone)
			n.draw_line(Vector2(x+w*.5,y-h*.82),Vector2(x+w*.95,y-h*1.05),edge,12)
			n.draw_rect(Rect2(x-6,y-h*.55,w+12,8),edge)
	# Small masonry details give the structures scale without terrain-like trims.
	for j in 6:
		var yy=y-18-j*23
		if yy<y-h*.5:break
		n.draw_rect(Rect2(x+w*.35,yy,w*.1,3),Color(shade,alpha*.5))
