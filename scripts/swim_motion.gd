class_name YBSwimMotion
extends RefCounted
## Actual actor/volume overlap selects swimming; decorative water is opt-in.
var tuning: YBSwimTuning = preload("res://content/swimming.tres")
var volumes: Array = []
var submerged := false
var immersion := 0.0
var surface_y := 0.0
var dry_floor_snap := 6.0

func sample(p: CharacterBody2D, dt: float) -> void:
	immersion=0
	var actor=Rect2(p.position-Vector2(12,42),Vector2(24,42))
	for zone in volumes:
		var volume=Rect2(zone.x,zone.y,zone.w,zone.h)
		var overlap=actor.intersection(volume)
		var fraction=overlap.get_area()/actor.get_area()
		if fraction>immersion:
			immersion=fraction;surface_y=volume.position.y
	var was_wet=submerged
	submerged=immersion>tuning.exit_fraction if was_wet else immersion>=tuning.enter_fraction
	if submerged and not was_wet:
		if p.floor_snap_length>0: dry_floor_snap=p.floor_snap_length
		p.velocity*=tuning.entry_momentum
		p.normal_jump=false;p.jump_hold=0;p.coyote=0;p.buffer=0;p.spring_flight=false
		p.lift_memory=0;p.lift_velocity=Vector2.ZERO
		p.water_crossed.emit(true)
	elif was_wet and not submerged:
		p.floor_snap_length=0 if p.ability and p.ability.controls_motion() else dry_floor_snap
		# Holding jump gives a small, deliberate breach at the surface.
		if p.position.y-21<surface_y and Input.is_action_pressed("jump"):
			p.velocity.y=minf(p.velocity.y,-tuning.surface_launch_speed)
		p.water_crossed.emit(false)
	if submerged: p.floor_snap_length=0
	if p.ability: p.ability.recover_in_medium(p,dt,tuning.dash_refill_time if submerged else 0.0)

func move(p: CharacterBody2D, dt: float, control: float) -> void:
	var stick=Vector2(Input.get_axis("left","right"),Input.get_axis("aim_up","aim_down"))
	# Down takes precedence over jump so diving never fights a held jump button.
	if Input.is_action_pressed("jump") and stick.y<=0: stick.y=-1
	stick=stick.limit_length()
	var target=stick*Vector2(tuning.horizontal_speed,tuning.vertical_speed)
	if absf(stick.y)<0.1:
		# Buoyancy approaches a stable waterline instead of repeatedly entering/exiting.
		target.y=-tuning.buoyant_rise_speed*clampf((immersion-.65)/.35,0,1)
	var response=(tuning.swim_response if stick.length()>.1 else tuning.idle_drag)*maxf(.1,control)
	# Exact linear-drag integration. Current force has a finite terminal drift.
	target+=p.wind/response
	p.velocity=target+(p.velocity-target)*exp(-response*dt)
	p.buffer=0;p.coyote=0;p.jump_hold=0;p.normal_jump=false

func drag_dash(p: CharacterBody2D, dt: float) -> void:
	p.velocity*=exp(-tuning.dash_drag*dt)

func reset(p: CharacterBody2D) -> void:
	if submerged: p.floor_snap_length=dry_floor_snap
	submerged=false;immersion=0
