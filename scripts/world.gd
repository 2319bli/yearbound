class_name YBWorld
extends Node2D
signal finished
signal checkpoint_reached
signal sound(id: String)

var spec: Dictionary
var player: YBPlayer
var camera: Camera2D
var platforms: Array[Dictionary] = []
var particles: Array[Dictionary] = []
var projectiles: Array[Dictionary] = []
var collected: Dictionary = {}
var checkpoint := Vector2.ZERO
var checkpoint_index := -1
var elapsed := 0.0
var deaths := 0
var camera_x := 0.0
var camera_y := 0.0
var boss_active := false
var age := 0.0
var respawn_delay := 0.0
var flash := 0.0
var boss_time := 0.0
var boss_spawn_clock := 0.0
var boss_attack := 0
var complete := false
var running := true
var reduced_motion := false
var assist := false
var font: Font
var render_layers: Dictionary = {}
var block_cells: Dictionary = {}

func setup(data: Dictionary, settings: Dictionary) -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	spec = data
	boss_active=spec.has("boss") and not spec.boss.has("arena_x")
	assist = settings.assist
	reduced_motion = settings.reduced_motion
	font = SystemFont.new()
	font.font_names = PackedStringArray(["Avenir Next","Arial"])
	checkpoint = Vector2(spec.spawn[0],spec.spawn[1])
	var geometry: Array = spec.platforms.duplicate(true)
	if spec.has("ground"):
		geometry.append({"x":-80,"y":spec.ground.y,"w":float(spec.length)+160,"h":900-float(spec.ground.y),"kind":"ground","base_ground":true})
	for entry in geometry:
		var body = StaticBody2D.new()
		var collider = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = Vector2(entry.w,entry.h)
		collider.shape = shape
		collider.position = shape.size/2
		body.add_child(collider)
		body.position = Vector2(entry.x,entry.y)
		add_child(body)
		platforms.append({"data":entry,"body":body,"collider":collider,"base":body.position,"crumble":-1.0,"gone":false,"occupied":block_cells})
		if spec.get("grid_size",0)==48 and not entry.get("base_ground",false) and entry.kind!="moving":
			for y in range(int(entry.y)/48,ceili((entry.y+entry.h)/48)):
				for x in range(int(entry.x)/48,ceili((entry.x+entry.w)/48)):
					block_cells[YBLayoutDocument.key(Vector2i(x,y))]=true
	camera = Camera2D.new()
	camera.position = Vector2(640,360)
	add_child(camera)
	player = YBPlayer.new()
	player.swimming.volumes=spec.zones.filter(func(z): return z.type=="water" and z.get("swimmable",false))
	if "charge_dash" in spec.get("abilities",[]):
		player.ability=YBChargeDash.new(YBChargeDashTuning.profile(settings.get("dash_tuning",{})))
		player.ability.feedback.connect(func(id): sound.emit(id))
		player.motion_step.connect(dash_hazard_sweep)
	player.assist = assist
	player.reduced_motion = reduced_motion
	player.z_index = 20
	player.position = checkpoint
	add_child(player)
	# All world content shares the same camera and pixel composite, below the UI.
	for entry in [["backdrop",-20],["scenery",-10],["environment",-5],["terrain",0],["markers",10],["hazards",25],["effects",30],["foreground",35],["signs",40]]:
		var layer=YBWorldLayer.new()
		layer.name=entry[0].capitalize();layer.z_index=entry[1]
		layer.host=self;layer.draw_method=StringName("draw_"+entry[0])
		add_child(layer);render_layers[entry[0]]=layer
	player.jumped.connect(func(): sound.emit("jump"); burst(player.position,Color("fff1bc"),7))
	player.water_crossed.connect(func(_entered): sound.emit("water");burst(Vector2(player.position.x,player.swimming.surface_y),Color("b5e9e5"),8))
	player.landed.connect(func(speed):
		if speed > 230:
			sound.emit("land")
			burst(player.position,Color("dae4ba"),6))

func snapshot() -> Dictionary:
	return {"id":spec.id,"layout_revision":spec.get("layout_revision",1),"checkpoint_index":checkpoint_index,"elapsed":elapsed,"deaths":deaths,"collected":collected.keys(),"boss_time":floorf(boss_time/35)*35}

func restore(state: Dictionary) -> void:
	checkpoint_index = clampi(int(state.get("checkpoint_index",-1)),-1,spec.checkpoints.size()-1)
	if checkpoint_index >= 0:
		var c = spec.checkpoints[checkpoint_index]
		checkpoint = Vector2(c[0],c[1])
	elapsed = float(state.get("elapsed",0))
	deaths = int(state.get("deaths",0))
	for i in state.get("collected",[]): collected[int(i)] = true
	boss_time = clampf(float(state.get("boss_time",0)),0,70)
	player.reset_at(checkpoint)
	camera_x = clampf(player.position.x-400,0,maxf(0,float(spec.length)-1280))
	camera_y = clampf(player.position.y-430,float(spec.get("world_top",0)),0)
	if spec.has("boss"): boss_active=not spec.boss.has("arena_x") or player.position.x>=float(spec.boss.arena_x)+48
	camera.position=Vector2(camera_x+640,camera_y+360)

func set_running(value: bool) -> void:
	if not value and running and player and player.ability: player.ability.interrupt(player,"paused")
	running = value
	if player: player.active = value and respawn_delay <= 0 and not complete

func _physics_process(dt: float) -> void:
	if not running or complete: return
	age += dt
	elapsed += dt
	flash = maxf(0,flash-dt*2)
	for i in range(particles.size()-1,-1,-1):
		var particle = particles[i]
		particle.pos += particle.vel*dt
		particle.vel.y += 320*dt
		particle.life -= dt
		if particle.life <= 0: particles.remove_at(i)
	if respawn_delay > 0:
		respawn_delay -= dt
		if respawn_delay <= 0:
			if spec.has("lab_stations"): age=0
			player.reset_at(checkpoint)
			camera_x=clampf(checkpoint.x-400,0,maxf(0,float(spec.length)-1280));camera_y=clampf(checkpoint.y-430,float(spec.get("world_top",0)),0)
			camera.position=Vector2(camera_x+640,camera_y+360)
			player.visible = true
			player.active = true
		queue_redraw()
		return
	player.ice = false
	player.wind = Vector2.ZERO
	for platform in platforms:
		var d = platform.data
		var body: StaticBody2D = platform.body
		var old = body.position
		if d.kind == "moving":
			var axis = Vector2.RIGHT if d.axis == "x" else Vector2.DOWN
			body.position = platform.base + axis*sin(age*float(d.speed))*float(d.distance)
			if player.is_on_floor() and player.velocity.y >= 0 and absf(player.position.y-old.y) < 3 and player.position.x > old.x-10 and player.position.x < old.x+float(d.w)+10:
				player.position += body.position-old
				player.remember_lift((body.position-old)/dt)
		var standing = player.is_on_floor() and player.velocity.y >= 0 and absf(player.position.y-body.position.y) < 4 and player.position.x > body.position.x-8 and player.position.x < body.position.x+float(d.w)+8
		if standing:
			if d.kind == "ice": player.ice = true
			if d.kind == "spring":
				player.bounce(float(d.get("power",850)))
				sound.emit("spring")
				burst(player.position,Color("ffe495"),20)
			if d.kind == "crumble" and platform.crumble < 0: platform.crumble = 0.65 if not assist else 1.1
		if platform.crumble >= 0:
			platform.crumble -= dt
			if platform.crumble <= 0:
				if platform.gone:
					platform.gone = false
					platform.collider.disabled = false
					platform.crumble = -1
				else:
					platform.gone = true
					platform.collider.disabled = true
					platform.crumble = 3.0
					burst(body.position+Vector2(d.w/2,0),Color("d4a45b"),15)
	for zone in spec.zones:
		if zone.type == "water": continue
		var rect = Rect2(zone.x,zone.y,zone.w,zone.h)
		if rect.has_point(player.position-Vector2(0,15)):
			var force = Vector2(zone.force[0],zone.force[1])
			if zone.get("pulse",false): force *= maxf(0,sin(age*1.5))
			player.wind += force
			if zone.type == "updraft" and (not player.ability or not player.ability.controls_motion()): player.velocity.y = maxf(player.velocity.y,-590)
	if player.position.y > 825 or player.position.x < -70: die()
	player.position.x = clampf(player.position.x,-45,float(spec.length)-12)
	for i in spec.motes.size():
		if collected.has(i): continue
		var mote = Vector2(spec.motes[i][0],spec.motes[i][1])
		if player.position.distance_to(mote+Vector2(0,20)) < 35:
			collected[i] = true
			sound.emit("mote")
			burst(mote,Color("ffe8a1"),8)
	for i in spec.checkpoints.size():
		var c = Vector2(spec.checkpoints[i][0],spec.checkpoints[i][1])
		if i > checkpoint_index and player.position.distance_to(c) < 58:
			checkpoint_index = i
			checkpoint = c
			sound.emit("checkpoint")
			burst(c-Vector2(0,48),Color("ffdf89"),22)
			checkpoint_reached.emit()
	for hazard in spec.hazards:
		if hazard.type=="bramble":
			var hitbox=Rect2(player.position-Vector2(10,38),Vector2(20,38))
			if hitbox.intersects(Rect2(hazard.x,hazard.y,hazard.w,hazard.h)): die()
			continue
		var at = hazard_position(hazard)
		if at.distance_to(player.position-Vector2(0,21)) < float(hazard.r)+15: die()
	if spec.has("boss"):
		if not boss_active and player.position.x>=float(spec.boss.get("arena_x",0))+48:
			boss_active=true;boss_spawn_clock=2.0
		if boss_active:
			player.position.x=clampf(player.position.x,float(spec.boss.get("arena_x",0))+24,float(spec.length)-24)
			update_boss(dt)
	else:
		var goal = Vector2(spec.goal[0],spec.goal[1])
		if player.position.distance_to(goal) < 58: win()
	var target = clampf(player.position.x-430+(player.velocity.x*0.15 if not reduced_motion else 0),0,maxf(0,float(spec.length)-1280))
	camera_x = lerpf(camera_x,target,1-exp(-dt*5))
	var vertical_target=clampf(player.position.y-430+clampf(player.velocity.y*.08,-55,70),float(spec.get("world_top",0)),0)
	camera_y=lerpf(camera_y,vertical_target,1-exp(-dt*7))
	if boss_active and spec.has("boss"): camera_x=float(spec.boss.get("arena_x",0));camera_y=0
	camera.position = Vector2(camera_x+640,camera_y+360)
	queue_redraw()

func hazard_position(h: Dictionary) -> Vector2:
	var at = Vector2(h.x,h.y)
	if h.type == "icicle":
		var cycle = fposmod(age+float(h.get("phase",0)),float(h.period))
		at.y = -100 if cycle < 1.35 else 140+pow(cycle-1.35,2)*820
	else:
		var axis = Vector2.RIGHT if h.get("axis","y") == "x" else Vector2.DOWN
		at += axis*sin(age*float(h.get("speed",1)))*float(h.get("distance",0))
	return at

func die() -> void:
	if respawn_delay > 0 or complete: return
	if player.ability: player.ability.cancel_charge(player)
	deaths += 1
	respawn_delay = 0.38
	flash = 0.5
	burst(player.position-Vector2(0,20),Color("fff2cf"),28)
	player.active = false
	player.visible = false
	player.velocity = Vector2.ZERO
	sound.emit("death")
	if spec.has("boss"):
		boss_time = floorf(boss_time/35)*35
		projectiles.clear()
		boss_spawn_clock = 1.5

func win() -> void:
	if complete: return
	if player.ability: player.ability.interrupt(player,"completed")
	complete = true
	player.active = false
	sound.emit("complete")
	finished.emit()

# A dash never grants invulnerability. Sweep the actor's path so thin hazards
# cannot be skipped between physics samples at a custom high launch speed.
func dash_hazard_sweep(from: Vector2, to: Vector2) -> void:
	if respawn_delay>0 or complete: return
	var a=from-Vector2(0,19);var b=to-Vector2(0,19)
	for hazard in spec.hazards:
		if hazard.type=="bramble":
			var rect=Rect2(hazard.x-10,hazard.y-19,hazard.w+20,hazard.h+38)
			if segment_hits_rect(a,b,rect): die();return
		else:
			var at=hazard_position(hazard)
			if Geometry2D.get_closest_point_to_segment(at,a,b).distance_to(at)<float(hazard.r)+15: die();return
static func segment_hits_rect(a: Vector2, b: Vector2, rect: Rect2) -> bool:
	var lo=0.0;var hi=1.0;var delta=b-a
	for axis in 2:
		if absf(delta[axis])<.0001:
			if a[axis]<rect.position[axis] or a[axis]>rect.end[axis]: return false
		else:
			var t0=(rect.position[axis]-a[axis])/delta[axis];var t1=(rect.end[axis]-a[axis])/delta[axis]
			lo=maxf(lo,minf(t0,t1));hi=minf(hi,maxf(t0,t1))
			if lo>hi: return false
	return true

func update_boss(dt: float) -> void:
	if respawn_delay > 0: return
	boss_time += dt
	if boss_time >= float(spec.boss.duration):
		win()
		return
	var origin=float(spec.boss.get("arena_x",0))
	var phase = mini(2,int(boss_time/35))
	boss_spawn_clock -= dt
	if boss_spawn_clock <= 0:
		boss_attack += 1
		boss_spawn_clock = [2.3,1.85,1.45][phase] * (1.3 if assist else 1.0)
		var target_x = clampf(player.position.x,origin+60,origin+1220)
		projectiles.append({"pos":Vector2(target_x,-40),"vel":Vector2(0,360+phase*55),"delay":0.9 if not assist else 1.3,"r":19.0,"kind":"rain"})
		if phase >= 1:
			var side = -1 if boss_attack%2 else 1
			projectiles.append({"pos":Vector2(origin+(-30 if side == 1 else 1310),574 if boss_attack%3 else 445),"vel":Vector2(side*(310+phase*30),0),"delay":1.0,"r":18.0,"kind":"sweep"})
		if phase == 2 and boss_attack%2 == 0:
			projectiles.append({"pos":Vector2(clampf(target_x+180,origin+50,origin+1230),-40),"vel":Vector2(0,430),"delay":1.1,"r":19.0,"kind":"rain"})
	for i in range(projectiles.size()-1,-1,-1):
		var projectile = projectiles[i]
		projectile.delay -= dt
		if projectile.delay > 0: continue
		projectile.pos += projectile.vel*dt
		if projectile.pos.distance_to(player.position-Vector2(0,21)) < projectile.r+13:
			die()
			return
		if projectile.pos.y > 760 or projectile.pos.x < origin-100 or projectile.pos.x > origin+1380: projectiles.remove_at(i)

func burst(at: Vector2, tint: Color, count: int) -> void:
	if reduced_motion: count = mini(count,4)
	for i in count:
		var angle = randf()*TAU
		particles.append({"pos":at,"vel":Vector2(cos(angle),sin(angle))*randf_range(35,170),"life":randf_range(0.25,0.65),"color":tint})

func draw_backdrop(n: Node2D) -> void:
	if spec.has("ground") or spec.get("grid_size",0)==48: return
	var season: String = spec.season
	# Depth-shaded water with narrow, broken reflections.
	var water=Color("558c91") if season!="winter" else Color("87afb9")
	for band in 26:
		n.draw_rect(Rect2(camera_x-80,641+band*4,1440,5),Color(water.darkened(band*0.016),0.80+band*0.003))
	for i in 55:
		var x=camera_x-50+fposmod(i*87.7+age*17,1390)
		var y=644+fposmod(i*31.3,91)
		var points=PackedVector2Array()
		for j in 8: points.append(Vector2(x+j*4,y+sin(age*1.1+j*0.55+i)*1.6))
		n.draw_polyline(points,Color(0.83,0.87,0.82,0.11+YBLandscape.hash_value(i)*0.18),0.7,true)

func draw_scenery(n: Node2D) -> void:
	YBScenery.stage_layer(n,spec,platforms,0 if reduced_motion else age,camera_x,"back")
	if spec.get("grid_size",0)==48: return
	for platform in platforms:
		if platform.gone or platform.body.position.x+float(platform.data.w)<camera_x-100 or platform.body.position.x>camera_x+1380: continue
		if platform.data.get("base_ground",false): continue
		YBScenery.edge_plants(n,platform,spec,age)
		var d: Dictionary=platform.data
		var at: Vector2=platform.body.position
		if d.kind=="wood":
			for x in [17,float(d.w)-23]:
				var foot=float(spec.ground.y)-at.y if spec.has("ground") else float(d.h)+38
				n.draw_line(at+Vector2(x,d.h-2),at+Vector2(x,foot),Color("506858"),6)
				n.draw_line(at+Vector2(x-10,d.h+1),at+Vector2(x,d.h+22),Color("71806a"),3)
		if not YBScenery.active(spec) and d.kind=="ground":
			if spec.season!="winter": YBLandscape.grass(n,at,float(d.w),spec.season,age,float(d.x))
			if int(d.w)>370 and int(d.x)%3==0: YBLandscape.tree(n,at+Vector2(d.w-65,0),.75,spec.season,Color.WHITE)

func draw_terrain(n: Node2D) -> void:
	if spec.has("ground"): YBTerrainArt.ground(n,spec,camera_x)
	for platform in platforms:
		if platform.data.get("base_ground",false): continue
		if platform.body.position.x+float(platform.data.w) < camera_x-70 or platform.body.position.x > camera_x+1360: continue
		draw_platform(n,platform)

func draw_markers(n: Node2D) -> void:
	for i in spec.motes.size():
		if collected.has(i): continue
		var at = Vector2(spec.motes[i][0],spec.motes[i][1])+Vector2(0,sin(age*2.6+i)*4)
		if at.x < camera_x-30 or at.x > camera_x+1310: continue
		n.draw_circle(at,11,Color(1,0.9,0.5,0.08),true,-1,true)
		n.draw_circle(at,6,Color(1,0.91,0.57,0.14),true,-1,true)
		n.draw_colored_polygon(PackedVector2Array([at+Vector2(0,-5),at+Vector2(3,0),at+Vector2(0,5),at+Vector2(-3,0)]),Color("fff1ae"))
	for i in spec.checkpoints.size():
		var at = Vector2(spec.checkpoints[i][0],spec.checkpoints[i][1])
		n.draw_line(at,at-Vector2(0,67),Color("405850"),5,true)
		n.draw_line(at-Vector2(0,65),at+Vector2(19,-65),Color("405850"),4,true)
		var tint = Color("ffdf86") if i <= checkpoint_index else Color("c3c6a3")
		if i <= checkpoint_index: n.draw_circle(at+Vector2(18,-48),27,Color(1,0.86,0.45,0.12),true,-1,true)
		n.draw_style_box(box(Color("314e50"),5),Rect2(at+Vector2(9,-61),Vector2(18,25)))
		n.draw_rect(Rect2(at+Vector2(13,-57),Vector2(10,17)),tint)
	if not spec.has("boss"):
		var at = Vector2(spec.goal[0],spec.goal[1])
		YBLandscape.gate(n,at,age)

func draw_hazards(n: Node2D) -> void:
	for h in spec.hazards:
		if h.type=="bramble":
			if h.x+h.w<camera_x-32 or h.x>camera_x+1312 or h.y+h.h<camera_y-32 or h.y>camera_y+752: continue
			YBTerrainArt.bramble(n,Rect2(h.x,h.y,h.w,h.h),spec.season,h.get("direction","up"))
			continue
		var at = hazard_position(h)
		if h.type == "icicle":
			var cycle = fposmod(age+float(h.get("phase",0)),float(h.period))
			if cycle < 1.35:
				n.draw_line(Vector2(h.x,240),Vector2(h.x,555),Color(1,0.71,0.39,0.25+sin(age*12)*0.12),2,true)
				n.draw_circle(Vector2(h.x,260),7,Color("ffc987"),true,-1,true)
			n.draw_colored_polygon(PackedVector2Array([at+Vector2(-13,-24),at+Vector2(13,-24),at+Vector2(0,23)]),Color("eaffff"))
			n.draw_line(at+Vector2(-13,-24),at+Vector2(0,23),Color("427e9e"),3,true)
		else:
			n.draw_circle(at,float(h.r)+7,Color(1,0.85,0.5,0.13),true,-1,true)
			var poly = PackedVector2Array()
			for j in 16:
				var radius = float(h.r)*(1 if j%2==0 else 0.55)
				poly.append(at+Vector2.from_angle(j*TAU/16+age*2)*radius)
			n.draw_colored_polygon(poly,Color("553e48"))
			n.draw_circle(at,7,Color("eda66b"),true,-1,true)
	if spec.has("boss") and boss_active: draw_boss(n)

func draw_foreground(n: Node2D) -> void:
	YBScenery.stage_layer(n,spec,platforms,0 if reduced_motion else age,camera_x,"front")
	if YBScenery.active(spec): YBScenery.near_frame(n,camera_x,age)

func draw_signs(n: Node2D) -> void:
	for entry in spec.signs:
		if absf(float(entry.x)-player.position.x) < 380:
			var alpha = clampf(1-absf(float(entry.x)-player.position.x)/400,0,1)
			var lines = entry.text.split("\n")
			for i in lines.size():
				var w = font.get_string_size(lines[i],HORIZONTAL_ALIGNMENT_LEFT,-1,16).x
				n.draw_style_box(box(Color(0.12,0.24,0.27,alpha*0.78),7),Rect2(entry.x-w/2-12,entry.y+i*27-19,w+24,25))
				n.draw_string(font,Vector2(entry.x-w/2,entry.y+i*27),lines[i],HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color(1,0.96,0.82,alpha))

func draw_environment(n: Node2D) -> void:
	for zone in spec.zones:
		if zone.x+zone.w>=camera_x-80 and zone.x<=camera_x+1360: draw_zone(n,zone)

func draw_effects(n: Node2D) -> void:
	for particle in particles: n.draw_circle(particle.pos,maxf(1,particle.life*5),Color(particle.color,minf(1,particle.life*2)),true,-1,true)
	n.draw_set_transform(Vector2(camera_x,camera_y))
	var scene=str(spec.get("ambience",{}).get("month_scene",""))
	var rain_floor=780.0
	for zone in player.swimming.volumes:
		if zone.x<=camera_x and zone.x+zone.w>=camera_x+1280: rain_floor=minf(rain_floor,zone.y)
	if YBMonthScenery.scenes.has(scene): YBMonthScenery.weather(n,scene,camera_x,age if not reduced_motion else 0,rain_floor)
	else: YBLandscape.foreground(n,spec.season,camera_x,age if not reduced_motion else 0)
	n.draw_set_transform(Vector2.ZERO)
	YBWaterArt.foreground(n,player.swimming.volumes,camera_x,age if not reduced_motion else 0,player)

func draw_platform(n: Node2D, p: Dictionary) -> void:
	YBTerrainArt.platform(n,p,spec,age,camera_x)
	if spec.get("grid_size",0)!=48: YBScenery.front_details(n,p,spec,age)

func draw_zone(n: Node2D, z: Dictionary) -> void:
	if z.type=="water":
		if z.get("swimmable",false): YBWaterArt.volume(n,z,camera_x,age if not reduced_motion else 0)
		return
	if z.type=="updraft":
		# Water falls at the far edge; curved spray reveals the rising air beside it.
		for i in 18:
			var x=float(z.x)+float(z.w)-27+i*1.4
			var line=PackedVector2Array()
			for j in 21: line.append(Vector2(x+sin(j*0.9+age*2+i)*1.2,float(z.y)+j*float(z.h)/20))
			n.draw_polyline(line,Color(0.84,0.91,0.88,0.2+YBLandscape.hash_value(i)*0.33),1.3,true)
		for j in 23:
			var x=z.x+15+fposmod(j*39,float(z.w)-35)
			var y=z.y+fposmod(j*73-age*125,float(z.h))
			n.draw_polyline(PackedVector2Array([Vector2(x-7,y+6),Vector2(x-2,y+1),Vector2(x+3,y),Vector2(x+9,y+3)]),Color(0.85,0.94,0.87,0.40),0.9,true)
		for i in 7: n.draw_circle(Vector2(z.x+z.w-15-i*10,z.y+z.h-8),12+i*2,Color(0.78,0.86,0.83,0.035),true,-1,true)
	elif z.type=="current":
		if not z.get("submerged",false):
			for band in 8: n.draw_rect(Rect2(z.x,z.y+band*float(z.h)/8,z.w,float(z.h)/8+1),Color(0.36,0.55,0.56,0.24+band*0.035))
		for i in 28:
			var direction=signf(z.force[0])
			var x=z.x+fposmod(i*37+age*100*direction,float(z.w))
			var y=z.y+3+fposmod(i*8.9,float(z.h)-5)
			n.draw_line(Vector2(x,y),Vector2(minf(x+19,z.x+z.w),y-1),Color(0.86,0.93,0.90,0.45),0.8,true)
	elif z.type=="wind":
		for i in 14:
			var x=z.x+fposmod(i*83-age*110,float(z.w))
			var y=z.y+fposmod(i*59,float(z.h))
			n.draw_line(Vector2(x,y),Vector2(x+28,y-3),Color(0.88,0.9,0.80,0.12+maxf(0,sin(age*1.5))*0.25),1,true)

func draw_boss(n: Node2D) -> void:
	var origin=float(spec.boss.get("arena_x",0))
	var at = Vector2(origin+640+sin(age*0.6)*180,165+sin(age*1.2)*18)
	var bird=YBLandscape.texture("res://art/squallkeeper.png")
	if bird:
		var width=344.0
		var height=width*float(bird.get_height())/bird.get_width()
		var stretch=1+sin(age*2.1)*0.035
		n.draw_texture_rect(bird,Rect2(at-Vector2(width/2,height*0.46),Vector2(width,height*stretch)),false)
	else: draw_bird_fallback(n,at)
	for projectile in projectiles:
		var pos: Vector2 = projectile.pos
		if projectile.delay > 0:
			if projectile.kind == "rain":
				n.draw_rect(Rect2(pos.x-22,265,44,335),Color(1,0.7,0.25,0.09+sin(age*14)*0.04))
				n.draw_line(Vector2(pos.x,280),Vector2(pos.x,598),Color(1,0.77,0.39,0.6),2,true)
				n.draw_circle(Vector2(pos.x,582),8,Color("ffd08d"),true,-1,true)
			else:
				n.draw_line(Vector2(origin,pos.y),Vector2(origin+1280,pos.y),Color(1,0.76,0.4,0.35),2,true)
		else:
			n.draw_circle(pos,projectile.r+6,Color(1,0.7,0.35,0.15),true,-1,true)
			n.draw_circle(pos,projectile.r,Color("eda65c"),true,-1,true)
			n.draw_circle(pos,projectile.r-6,Color("fff1b0"),true,-1,true)

func draw_bird_fallback(n: Node2D, at: Vector2) -> void:
	# A long-winged storm raptor, with layered flight feathers and restrained anatomy.
	for side in [-1,1]:
		var flap=sin(age*2.1)*15
		n.draw_colored_polygon(PackedVector2Array([at+Vector2(side*7,8),at+Vector2(side*60,-28+flap),at+Vector2(side*137,-24+flap),at+Vector2(side*162,-2+flap),at+Vector2(side*91,21),at+Vector2(side*25,29)]),Color("747e7b"))
		for j in 14:
			var root=at+Vector2(side*(32+j*8),-13+sin(j*0.3)*-10+flap)
			var tip=root+Vector2(side*(12+j*1.0),28+sin(j*0.21)*20-flap*0.4)
			n.draw_colored_polygon(PackedVector2Array([root+Vector2(-side*6,0),root+Vector2(side*4,-3),tip+Vector2(side*2,0),tip+Vector2(-side*2,5)]),Color("c3c7b9").darkened(float(j%4)*0.075))
			n.draw_line(root,tip,Color(0.3,0.35,0.34,0.4),0.8,true)
		n.draw_polyline(PackedVector2Array([at+Vector2(side*11,-2),at+Vector2(side*61,-26+flap),at+Vector2(side*128,-23+flap)]),Color("cdd0c0"),3,true)
	for j in 5:
		var x=(j-2)*4
		n.draw_colored_polygon(PackedVector2Array([at+Vector2(x-3,19),at+Vector2(x+3,19),at+Vector2(x*1.8+3,53-absf(x)*0.4),at+Vector2(x*1.8-3,55-absf(x)*0.4)]),Color("84918b").lightened(j*0.028))
	n.draw_colored_polygon(PackedVector2Array([at+Vector2(-10,-11),at+Vector2(-18,9),at+Vector2(-10,33),at+Vector2(8,35),at+Vector2(17,9),at+Vector2(11,-14)]),Color("c4c7b7"))
	for i in 18:
		var pos=at+Vector2((YBLandscape.hash_value(i)-0.5)*22,YBLandscape.hash_value(i+4)*27)
		n.draw_line(pos,pos+Vector2(-1,4),Color("86928a"),1,true)
	n.draw_circle(at+Vector2(0,-15),12,Color("d0d0bf"),true,-1,true)
	n.draw_line(at+Vector2(-9,-17),at+Vector2(-3,-15),Color("5e665e"),2,true)
	n.draw_line(at+Vector2(9,-17),at+Vector2(3,-15),Color("5e665e"),2,true)
	n.draw_circle(at+Vector2(-5,-14),1.6,Color("c8a261"),true,-1,true)
	n.draw_circle(at+Vector2(5,-14),1.6,Color("c8a261"),true,-1,true)
	n.draw_colored_polygon(PackedVector2Array([at+Vector2(-3,-12),at+Vector2(4,-12),at+Vector2(2,-2),at+Vector2(-1,-4)]),Color("6a6957"))

static func box(fill: Color, radius: int) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = fill
	style.corner_radius_top_left = radius;style.corner_radius_top_right = radius;style.corner_radius_bottom_left = radius;style.corner_radius_bottom_right = radius
	return style
