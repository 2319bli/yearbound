class_name YBJourneyScenery
extends RefCounted
## A journey changes place and light while keeping collision surfaces crisp.
const PLATES={"field":"06-10","river":"06-11","marsh":"06-02","orchard":"06-12","forest":"06-14","hedge":"06-10","sunflowers":"06-07","station":"06-05","mill":"06-06","machinery":"06-06","windmill":"06-15","barn":"06-16","garden":"06-13","glasshouse":"06-09","tunnel":"06-14","ridge":"06-03","village":"06-08","flowers":"06-13","bridge":"06-11","fountain":"06-17","grass":"06-10"}
const LIGHT={"morning":"f2f1d5","day":"ffffff","midsummer":"fff6c5","afternoon":"f3cb9f","sunset":"d99084","shade":"9cbea9","interior":"91a899","dusk":"7588ac","night":"384f80","twilight":"617290"}
static func index_at(regions: Array, x: float) -> int:
	for i in range(regions.size()-1,-1,-1):
		if x>=float(regions[i].x):return i
	return 0
static func background(n: Node2D, regions: Array, player_x: float, cam: float, time: float, calm: float=0) -> void:
	var i=index_at(regions,player_x);var current=regions[i]
	var blend=clampf((player_x-float(current.x))/300,0,1) if i else 1.0
	if blend<1:plate(n,regions[i-1],cam,time,1)
	plate(n,current,cam,time,blend)
	if calm>0:plate(n,{"place":"ridge","light":"afternoon"},cam,time,calm)
static func plate(n: Node2D, region: Dictionary, cam: float, time: float, alpha: float) -> void:
	var place=str(region.place);var light=str(region.get("light","day"));var tint=Color(LIGHT.get(light,"ffffff"));tint.a=alpha
	var plate_id="06-10" if place=="village" and light in ["day","morning"] else str(PLATES.get(place,"06-10"))
	var texture=YBLandscape.texture("res://art/june/"+plate_id+".png")
	if texture:n.draw_texture_rect(texture,Rect2(-130-sin(cam*.00012)*90,-42,1536,864),false,tint)
	else:n.draw_rect(Rect2(0,0,1280,720),Color("72b4cd")*tint)
	if light in ["night","twilight","dusk"]:
		for j in 38:
			var x=fposmod(j*137.3-cam*.025,1280);var y=22+fposmod(j*j*17.9,290)
			n.draw_rect(Rect2(x,y,2,2),Color(.9,.95,1,alpha*(.35+.2*sin(time*.5+j))))
		n.draw_circle(Vector2(1050,102),24,Color(.8,.89,.96,.65*alpha))
	elif light=="midsummer":
		n.draw_circle(Vector2(1010,118),90,Color(1,.95,.63,.12*alpha));n.draw_circle(Vector2(1010,118),59,Color(1,.96,.72,.7*alpha))
	if place in ["glasshouse","machinery","tunnel","barn"] and light=="interior":
		n.draw_rect(Rect2(0,0,1280,720),Color(.12,.23,.22,.5*alpha))
		for j in 7:
			var x=fposmod(j*235-cam*.18,1650)-180
			n.draw_rect(Rect2(x,0,22,720),Color(.27,.36,.3,.55*alpha))
			n.draw_rect(Rect2(x+27,45,176,230),Color(.78,.87,.64,.12*alpha))
			for k in 4:n.draw_line(Vector2(x+27,45+k*58),Vector2(x+203,45+k*58),Color(.42,.52,.4,.45*alpha),4)
			n.draw_colored_polygon(PackedVector2Array([Vector2(x+203,250),Vector2(x+125,270),Vector2(x-80,650),Vector2(x+35,650)]),Color(.91,.91,.61,.045*alpha))
	if place in ["forest","hedge","sunflowers","grass"]:
		for j in 11:
			var x=fposmod(j*147-cam*.35,1620)-140;var h=210+YBLandscape.hash_value(j)*220
			n.draw_rect(Rect2(x,0,16,h),Color(.13,.26,.22,.1*alpha))
	if place in ["river","marsh","fountain","bridge"]:
		for j in 32:
			var x=fposmod(j*91-time*21-cam*.22,1390)-50;var y=490+(j%9)*13
			n.draw_line(Vector2(x,y),Vector2(x+18+j%4*9,y),Color(.76,.94,.9,.2*alpha),2)
static func foreground_places(n: Node2D, spec: Dictionary, cam: Vector2, player: Vector2, time: float) -> void:
	# These details belong to the rear scenery pass, never above player/hazards.
	for region in spec.get("journey_regions",[]):
		if region.x+region.w<cam.x-150 or region.x>cam.x+1450:continue
		var ground=624+float(region.y)
		if region.place in ["grass","hedge","sunflowers"]:
			for j in range(int(maxf(region.x,cam.x-100)/32),int(minf(region.x+region.w,cam.x+1400)/32)):
				var x=j*32.0;var h=(65 if region.place=="grass" else 30)+YBLandscape.hash_value(j)*55
				n.draw_line(Vector2(x,ground),Vector2(x+sin(time+j)*6,ground-h),Color("779565"),3)
		if region.get("lanterns",false):
			for j in range(3,int(region.w/48),9):
				var x=region.x+j*48;var y=ground-115
				n.draw_line(Vector2(x,ground),Vector2(x,y-12),Color("728f7d"),4)
				n.draw_circle(Vector2(x+12,y),40,Color(1,.72,.3,.08));n.draw_rect(Rect2(x+7,y-8,11,16),Color("edc884"))
	for secret in spec.get("secret_areas",[]):
		var data=secret.rect;var rect=Rect2(data[0],data[1],data[2],data[3])
		if not rect.intersects(Rect2(cam-Vector2(100,100),Vector2(1480,920))):continue
		var fade=clampf(player.distance_to(rect.get_center())/240-.2,.12,.85)
		for j in range(0,int(rect.size.x),16):
			var x=rect.position.x+j;var h=rect.size.y*(.65+YBLandscape.hash_value(j)*.3)
			n.draw_line(Vector2(x,rect.position.y),Vector2(x+3,rect.position.y+h),Color(.28,.45,.3,fade),4)
			for k in 6:n.draw_rect(Rect2(x-5,rect.position.y+k*h/6,13,7),Color(.42,.59,.37,fade))
