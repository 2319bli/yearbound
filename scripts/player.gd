class_name YBPlayer
extends CharacterBody2D

signal jumped
signal landed(speed: float)
signal motion_step(from: Vector2, to: Vector2)
signal water_crossed(entered: bool)
@export var tuning: YBMovementTuning = preload("res://content/movement.tres")
var ability: YBPlayerAbility
var swimming := YBSwimMotion.new()
var facing := 1.0
var coyote := 0.0
var buffer := 0.0
var squash := 0.0
var ice := false
var wind := Vector2.ZERO
var active := true
var assist := false
var spring_lock := 0.0
var spring_flight := false
var jump_hold := 0.0
var jump_launch_speed := 0.0
var normal_jump := false
var lift_velocity := Vector2.ZERO
var lift_memory := 0.0
var reset_floor_frames := 0
var animation_time := 0.0
var reduced_motion := false

func _ready() -> void:
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(24, 42)
	shape.shape = rect
	shape.position.y = -21
	add_child(shape)
	floor_snap_length = 6
	floor_stop_on_slope = true

func _physics_process(dt: float) -> void:
	if not active: return
	animation_time += dt
	swimming.sample(self,dt)
	var grounded = is_on_floor() and velocity.y >= 0 and reset_floor_frames == 0
	reset_floor_frames = maxi(0, reset_floor_frames - 1)
	coyote = tuning.coyote_time if grounded else maxf(0, coyote - dt)
	buffer = maxf(0, buffer - dt)
	jump_hold = maxf(0, jump_hold - dt)
	spring_lock = maxf(0, spring_lock - dt)
	lift_memory = maxf(0, lift_memory - dt)
	if lift_memory <= 0: lift_velocity = Vector2.ZERO
	if Input.is_action_just_pressed("jump"): buffer = tuning.jump_buffer_time
	var axis = Input.get_axis("left", "right")
	if absf(axis) <= 0.1: axis = 0
	else: facing = signf(axis)
	var ability_motion=ability.before_motion(self,dt,grounded and not swimming.submerged) if ability else false
	if swimming.submerged:
		if ability_motion: swimming.drag_dash(self,dt)
		else: swimming.move(self,dt,ability.horizontal_control(false) if ability else 1.0)
	elif not ability_motion:
		var previous=velocity
		_move_horizontal(axis, grounded, dt, ability.horizontal_control(grounded) if ability else 1.0)
		_move_vertical(grounded, dt)
		if ability: ability.after_base_motion(self,previous,axis,grounded,dt)
		if buffer > 0 and coyote > 0: _jump()
	if not swimming.submerged and (not ability or not ability.controls_motion()): _correct_jump_corner(dt)
	var impact = velocity.y
	var motion_start=position
	move_and_slide()
	if ability: ability.after_motion(self,dt,grounded)
	if not swimming.volumes.is_empty():
		floor_snap_length=0 if swimming.submerged or (ability and ability.controls_motion()) else swimming.dry_floor_snap
	motion_step.emit(motion_start,position)
	if is_on_ceiling():
		jump_hold = 0
		normal_jump = false
	if is_on_floor():
		spring_flight = false
		normal_jump = false
		if not grounded:
			squash = clampf(impact / 2800.0, 0.06, 0.22)
			landed.emit(impact)
		# Consume the landing buffer on this tick, without a grounded dead frame.
		if buffer > 0 and not swimming.submerged: _jump()
	squash = move_toward(squash, 0, dt * 1.8)
	queue_redraw()

func _move_horizontal(axis: float, grounded: bool, dt: float, control_scale: float=1.0) -> void:
	var acceleration = tuning.ground_acceleration if grounded else tuning.air_acceleration
	var braking = tuning.ground_braking if grounded else tuning.air_braking
	if ice and grounded:
		acceleration = tuning.ice_acceleration
		braking = tuning.ice_braking
	elif axis * velocity.x < 0:
		acceleration *= tuning.turn_multiplier
	velocity.x = move_toward(velocity.x, axis * tuning.run_speed, (acceleration if axis != 0 else braking) * dt * control_scale)
	velocity.x = clampf(velocity.x + wind.x * dt, -480, 480)

func _move_vertical(grounded: bool, dt: float) -> void:
	var gravity = tuning.rise_gravity if velocity.y < 0 else tuning.fall_gravity
	var terminal = tuning.max_fall_speed
	if spring_flight:
		gravity = tuning.spring_rise_gravity if velocity.y < 0 else tuning.spring_fall_gravity
		terminal = tuning.spring_max_fall_speed
	elif normal_jump and Input.is_action_pressed("jump") and absf(velocity.y) < tuning.apex_speed:
		gravity *= tuning.apex_gravity_multiplier
	velocity.y = minf(terminal, velocity.y + (gravity + wind.y) * dt)
	if normal_jump and jump_hold > 0 and Input.is_action_pressed("jump"):
		velocity.y = minf(velocity.y, -jump_launch_speed)
	if not Input.is_action_pressed("jump"): jump_hold = 0
	if grounded: normal_jump = false

func _jump() -> void:
	jump_launch_speed = tuning.assist_jump_speed if assist else tuning.jump_speed
	velocity.y = -jump_launch_speed
	# Only useful/upward lift momentum is inherited, and only once per take-off.
	if lift_memory > 0:
		velocity.x = clampf(velocity.x + lift_velocity.x, -480, 480)
		velocity.y += minf(0, lift_velocity.y)
		jump_launch_speed = -velocity.y
	lift_velocity = Vector2.ZERO
	lift_memory = 0
	coyote = 0
	buffer = 0
	jump_hold = tuning.jump_hold_time if Input.is_action_pressed("jump") else 0
	normal_jump = true
	spring_flight = false
	squash = -0.14
	jumped.emit()

func _correct_jump_corner(dt: float) -> void:
	if velocity.y >= 0: return
	var rise = Vector2(0, velocity.y * dt)
	if not test_move(global_transform, rise): return
	# Try a small lateral escape only if both the side path and rise are empty.
	# This cannot climb walls or move through a full ceiling / narrow shaft.
	var first = 1 if velocity.x >= 0 else -1
	for distance in range(1, tuning.corner_correction + 1):
		for side in [first, -first]:
			if absf(velocity.x) > 1 and side != first: continue
			var offset = Vector2(side * distance, 0)
			if test_move(global_transform, offset): continue
			var shifted = global_transform
			shifted.origin += offset
			if not test_move(shifted, rise):
				global_position += offset
				return

func remember_lift(speed: Vector2) -> void:
	if speed.length() < 1: return
	lift_velocity = Vector2(clampf(speed.x, -tuning.lift_horizontal_limit, tuning.lift_horizontal_limit), clampf(speed.y, -tuning.lift_vertical_limit, 0))
	lift_memory = tuning.lift_memory_time

func bounce(power: float) -> void:
	if ability: ability.interrupt(self,"spring")
	velocity.y = -power
	spring_lock = 0.35
	spring_flight = true
	normal_jump = false
	jump_hold = 0
	coyote = 0
	buffer = 0
	lift_velocity = Vector2.ZERO
	lift_memory = 0
	squash = -0.2
	jumped.emit()

func reset_at(at: Vector2) -> void:
	if ability and ability.has_method("cancel_charge"): ability.cancel_charge(self)
	swimming.reset(self)
	position = at
	velocity = Vector2.ZERO
	coyote = 0
	buffer = 0
	jump_hold = 0
	spring_lock = 0
	spring_flight = false
	normal_jump = false
	lift_velocity = Vector2.ZERO
	lift_memory = 0
	wind = Vector2.ZERO
	ice = false
	squash = 0
	reset_floor_frames = 1

func _draw() -> void:
	var time=animation_time
	var stride=minf(absf(velocity.x)/tuning.run_speed,1.0)
	var phase=time*13.5
	var moving=is_on_floor()
	if swimming.submerged:
		phase=time*5.5;stride=.55;moving=true
	var lift=sin(phase*2)*stride*0.65 if moving else -0.5
	# Adult proportions: articulated legs, a fitted waxed coat, a small hood and pack.
	var stretch=0.0 if reduced_motion else squash
	var swim_tilt=clampf(velocity.x/900,-.22,.22) if swimming.submerged else 0.0
	draw_set_transform(Vector2(0,lift),swim_tilt,Vector2(facing*(1+stretch*.45),1-stretch))
	var hip=Vector2(0,-17)
	var rear_foot=Vector2(-sin(phase)*7*stride if moving else -7,0 if moving else -5)
	var front_foot=Vector2(sin(phase)*7*stride if moving else 8,0 if moving else -3)
	var rear_knee=hip.lerp(rear_foot,0.58)+Vector2(2,-absf(cos(phase))*stride*2)
	var front_knee=hip.lerp(front_foot,0.52)+Vector2(-2,-absf(sin(phase))*stride*2)
	draw_polyline(PackedVector2Array([hip+Vector2(-2,0),rear_knee,rear_foot]),Color("343a38"),4.2,true)
	draw_line(rear_foot+Vector2(-2,-1),rear_foot+Vector2(4,-1),Color("282e2b"),3.6,true)
	draw_polyline(PackedVector2Array([hip+Vector2(2,0),front_knee,front_foot]),Color("55594a"),4.3,true)
	draw_line(front_foot+Vector2(-2,-1),front_foot+Vector2(4,-1),Color("35382f"),3.6,true)
	draw_colored_polygon(PackedVector2Array([Vector2(-6,-31),Vector2(4,-31),Vector2(7,-17),Vector2(-6,-15)]),Color("dcc493"))
	draw_colored_polygon(PackedVector2Array([Vector2(-6,-31),Vector2(-1,-29),Vector2(-1,-17),Vector2(-6,-15)]),Color("7f7656"))
	draw_line(Vector2(3,-28),Vector2(5,-19),Color("d0bd93"),1,true)
	draw_style_box(_pack_style(),Rect2(-10,-29,5,12))
	var elbow=Vector2(3,-25)+Vector2(-sin(phase)*stride*3,0)
	var hand=Vector2(4,-20)+Vector2(-sin(phase)*stride*5,0) if moving else Vector2(9,-27)
	draw_polyline(PackedVector2Array([Vector2(1,-30),elbow,hand]),Color("968766"),3.6,true)
	draw_circle(hand,1.7,Color("b99d7c"),true,-1,true)
	draw_circle(Vector2(-0.5,-36),6.5,Color("2c423b"),true,-1,true)
	draw_circle(Vector2(-0.5,-36),5.5,Color("7f7050"),true,-1,true)
	draw_colored_polygon(PackedVector2Array([Vector2(1,-40),Vector2(4,-39),Vector2(4,-36),Vector2(6,-35),Vector2(4,-34),Vector2(4,-32),Vector2(0,-32)]),Color("f0d7a8"))
	draw_line(Vector2(-4,-31),Vector2(4,-31),Color("ae6440"),2.7,true)
	draw_polyline(PackedVector2Array([Vector2(-4,-31),Vector2(-11,-29+sin(time*7)*1.2),Vector2(-17,-30+sin(time*7-1)*2)]),Color("a76443"),2.6,true)
	draw_set_transform(Vector2.ZERO)
	if ability: ability.draw_feedback(self)

func _pack_style() -> StyleBoxFlat:
	var style=StyleBoxFlat.new()
	style.bg_color=Color("605c48")
	style.set_corner_radius_all(2)
	return style
