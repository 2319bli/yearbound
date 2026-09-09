class_name YBChargeDash
extends YBPlayerAbility

var tuning: YBChargeDashTuning
var charging=false
var dashing=false
var carrying=false
var charge_time=0.0
var charge_ratio=0.0
var power=0.0
var dash_left=0.0
var cooldown_left=0.0
var exit_control_left=0.0
var air_used=0
var wait_for_release=false
var full_announced=false
var direction=Vector2.RIGHT
var last_ratio=0.0
var last_force=0.0
var last_velocity=Vector2.ZERO
var launch_position=Vector2.ZERO
var last_displacement=Vector2.ZERO
var dash_displacement=Vector2.ZERO
var measurement_left=0.0
var trail: Array[Vector2]=[]
var previous_floor_snap=6.0
var ground_launch=false
var dash_elapsed=0.0
var medium_recovery=0.0

func _init(profile: YBChargeDashTuning=null) -> void:
	tuning=profile if profile else YBChargeDashTuning.profile()
func aim(p: CharacterBody2D) -> Vector2:
	var raw=Vector2(Input.get_axis("left","right"),Input.get_axis("aim_up","aim_down"))
	return raw.normalized() if raw.length()>tuning.aim_deadzone else Vector2(p.facing,0)
func available(grounded: bool) -> bool:
	return cooldown_left<=0 and not dashing and (grounded or (tuning.airborne_charging and (tuning.air_launches==0 or air_used<tuning.air_launches)))
func before_motion(p: CharacterBody2D, dt: float, grounded: bool) -> bool:
	cooldown_left=maxf(0,cooldown_left-dt)
	exit_control_left=maxf(0,exit_control_left-dt)
	if wait_for_release:
		if not Input.is_action_pressed("ability"): wait_for_release=false
	elif Input.is_action_just_pressed("ability") and available(grounded):
		charging=true;charge_time=0;charge_ratio=0;full_announced=false
	if charging:
		if not grounded and not tuning.airborne_charging:
			interrupt(p,"airborne charging disabled")
		else:
			direction=aim(p)
			if Input.is_action_pressed("ability"):
				charge_time=minf(tuning.charge_duration,charge_time+dt)
				charge_ratio=clampf(charge_time/tuning.charge_duration,0,1)
				if charge_ratio>=1 and not full_announced: full_announced=true;feedback.emit("charge_full")
			else:
				# State transition, rather than a one-frame edge: input release may
				# arrive between render and physics ticks. Pauses/resets cancel explicitly.
				if launch(p,grounded): return true
	if not dashing: return false
	if dash_left<=.00001:
		finish(p,"complete");return false
	dash_left-=dt
	dash_elapsed+=dt
	# The release vector is committed. Only a small perpendicular correction remains.
	var stick=Vector2(Input.get_axis("left","right"),Input.get_axis("aim_up","aim_down")).limit_length()
	var correction=stick-direction*stick.dot(direction)
	p.velocity+=correction*p.tuning.air_acceleration*lerpf(tuning.short_dash_control,tuning.long_dash_control,power)*dt
	p.velocity.y+=p.tuning.fall_gravity*tuning.dash_gravity*dt
	p.velocity=p.velocity.limit_length(tuning.maximum_launch_speed)
	# A ground jump can interrupt a horizontal dash; it inherits horizontal speed.
	if (grounded or (ground_launch and dash_elapsed<=p.tuning.coyote_time)) and p.buffer>0 and absf(direction.y)<0.25:
		finish(p,"jump cancel");p._jump()
	return true
func launch(p: CharacterBody2D, grounded: bool) -> bool:
	charging=false;power=pow(charge_ratio,tuning.charge_curve);direction=aim(p)
	ground_launch=grounded;dash_elapsed=0
	var jump_cancel=grounded and p.buffer>0 and absf(direction.y)<.25
	previous_floor_snap=p.floor_snap_length;p.floor_snap_length=0
	# Avoid colliding with the vertical lip of a same-height landing through
	# CharacterBody2D's contact margin. Clearance is swept and dash-only.
	var clearance=Vector2(0,-tuning.ground_clearance)
	if grounded and absf(direction.y)<.1 and not p.test_move(p.global_transform,clearance): p.position+=clearance
	var force=lerpf(tuning.minimum_force,tuning.maximum_force,power)
	var launch_direction=(direction/maxf(absf(direction.x),absf(direction.y))).lerp(direction,tuning.diagonal_normalization)
	var incoming: Vector2=p.velocity
	if p.lift_memory>0: incoming+=p.lift_velocity
	var parallel=direction*maxf(0,incoming.dot(direction))*tuning.forward_momentum
	var perpendicular=(incoming-direction*incoming.dot(direction))*tuning.cross_momentum
	perpendicular=perpendicular.limit_length(tuning.cross_momentum_limit)
	p.velocity=(launch_direction*Vector2(tuning.horizontal_force,tuning.vertical_force)*force+parallel+perpendicular).limit_length(tuning.maximum_launch_speed)
	p.normal_jump=false;p.spring_flight=false;p.jump_hold=0;p.coyote=0;p.buffer=0;p.lift_memory=0;p.lift_velocity=Vector2.ZERO
	if not grounded or direction.y<-.1: air_used+=1
	dashing=true;carrying=false;dash_left=lerpf(tuning.short_duration,tuning.long_duration,power)
	last_ratio=charge_ratio;last_force=force;last_velocity=p.velocity;launch_position=p.position
	last_displacement=Vector2.ZERO;dash_displacement=Vector2.ZERO;measurement_left=1.25;trail.clear()
	charge_time=0;charge_ratio=0
	feedback.emit("dash");launched.emit(direction,power,p.velocity)
	if jump_cancel:
		finish(p,"jump cancel");p._jump()
	return jump_cancel
func finish(p: CharacterBody2D, reason: String) -> void:
	if not dashing: return
	dashing=false;dash_left=0;cooldown_left=tuning.cooldown
	p.floor_snap_length=previous_floor_snap
	exit_control_left=tuning.exit_control_duration
	p.velocity*=tuning.exit_momentum
	carrying=absf(p.velocity.x)>p.tuning.run_speed
	dash_displacement=p.position-launch_position
	ended.emit(reason)
func horizontal_control(grounded: bool) -> float:
	if charging: return tuning.charge_ground_control if grounded else tuning.charge_air_control
	return tuning.exit_air_control if (carrying or exit_control_left>0) and not grounded else 1.0
func after_base_motion(p: CharacterBody2D, previous: Vector2, axis: float, grounded: bool, dt: float) -> void:
	if not carrying: return
	if absf(previous.x)<=p.tuning.run_speed: carrying=false;return
	var braking=tuning.carry_decay if axis*previous.x>0 else (tuning.carry_braking if axis==0 else tuning.reversal_braking)
	var control=1.0 if grounded else tuning.exit_air_control
	p.velocity.x=move_toward(previous.x,axis*p.tuning.run_speed,braking*control*dt)+p.wind.x*dt
func after_motion(p: CharacterBody2D, dt: float, was_grounded: bool) -> void:
	if measurement_left>0:
		last_displacement=p.position-launch_position;measurement_left-=dt
	if dashing:
		trail.push_front(p.position);if trail.size()>5: trail.pop_back()
		for i in p.get_slide_collision_count():
			if p.get_slide_collision(i).get_normal().dot(direction)<-.2:
				finish(p,"collision");break
	elif not trail.is_empty(): trail.pop_back()
	if p.is_on_floor() and not was_grounded:
		if tuning.landing_resets: air_used=0
		if tuning.landing_resets_cooldown: cooldown_left=0
func controls_motion() -> bool: return dashing
func recover_in_medium(_p: CharacterBody2D, dt: float, refill_time: float) -> void:
	if refill_time<=0 or charging or dashing:
		medium_recovery=0;return
	medium_recovery+=dt
	if medium_recovery>=refill_time and cooldown_left<=0: air_used=0
func interrupt(p: CharacterBody2D, reason: String) -> void:
	charging=false;charge_time=0;charge_ratio=0;full_announced=false;wait_for_release=true
	if dashing: finish(p,reason)
	trail.clear()
func cancel_charge(p: CharacterBody2D) -> void:
	interrupt(p,"reset");dashing=false;carrying=false;dash_left=0;cooldown_left=0;exit_control_left=0;air_used=0;measurement_left=0;medium_recovery=0
func draw_feedback(p: Node2D) -> void:
	if not p.reduced_motion:
		for i in trail.size():
			p.draw_line(trail[i]-p.position-Vector2(0,30),trail[i]-p.position-Vector2(0,10),Color(.7,.91,.87,.18*(1-float(i)/5)),5)
	if not charging: return
	var center=Vector2(0,-23)
	var tint=Color("ffe3a0") if charge_ratio>=1 else Color("bce7df")
	p.draw_arc(center,27,-PI*.5,PI*1.5,32,Color(.15,.28,.29,.55),2)
	p.draw_arc(center,27,-PI*.5,-PI*.5+maxf(.02,charge_ratio)*TAU,32,tint,2)
	var aim_line=(direction*Vector2(tuning.horizontal_force,tuning.vertical_force)).normalized()
	var arrow=center+aim_line*35
	p.draw_line(arrow-aim_line*5,arrow+aim_line*7,tint,2)
	for side in [-1,1]: p.draw_line(arrow+aim_line*7,arrow+aim_line.orthogonal()*side*4,tint,2)
	if charge_ratio>=1:
		p.draw_rect(Rect2(-9,-58,18,3),tint)
	elif not p.reduced_motion:
		for i in 3:
			var point=center+Vector2.from_angle(p.animation_time*1.5+i*TAU/3)*(29-charge_ratio*4)
			p.draw_rect(Rect2(point.round(),Vector2(2,2)),Color(tint,.65))
