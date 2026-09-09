extends SceneTree
var failures=0
var arena: Node2D
var p: YBPlayer
var dash: YBChargeDash
func _initialize() -> void: call_deferred("run")
func frames(count: int) -> void:
	for i in count: await physics_frame
func check(ok: bool, message: String) -> void:
	if ok: print("PASS: ",message)
	else: failures+=1;push_error(message)
func release() -> void:
	for action in YBControls.ACTIONS: Input.action_release(action)
func surface(at: Vector2, size: Vector2) -> void:
	var body=StaticBody2D.new();body.position=at
	var shape=CollisionShape2D.new();var rect=RectangleShape2D.new();rect.size=size;shape.shape=rect;shape.position=size*.5;body.add_child(shape);arena.add_child(body)
func fixture() -> void:
	release()
	if arena: root.remove_child(arena);arena.queue_free();await frames(2)
	arena=Node2D.new();root.add_child(arena);surface(Vector2(-1000,624),Vector2(6000,96))
	p=YBPlayer.new();dash=YBChargeDash.new();p.ability=dash;p.position=Vector2(200,624);arena.add_child(p);await frames(5)
func hold(count: int, aim: Vector2=Vector2.ZERO) -> void:
	Input.action_press("ability");await frames(count)
	if aim.x!=0: Input.action_press("right" if aim.x>0 else "left")
	if aim.y!=0: Input.action_press("aim_down" if aim.y>0 else "aim_up")
	Input.action_release("ability");await frames(1)
func measure(count: int) -> Dictionary:
	await fixture();await hold(count)
	var velocity=dash.last_velocity
	for i in 80:
		await frames(1)
		if not dash.dashing: break
	var result={"charge":dash.last_ratio,"force":dash.last_force,"velocity":velocity,"burst":dash.dash_displacement.x}
	await frames(12);result["after"]=p.position.x-dash.launch_position.x
	return result
func run() -> void:
	YBControls.apply({})
	var short=await measure(3);var middle=await measure(24);var full=await measure(54);var capped=await measure(120)
	print("MEASURE standing short=",short," medium=",middle," long=",full," held_past_cap=",capped)
	check(short.burst>30 and short.burst<100,"short charge produces a compact correction")
	check(middle.burst>short.burst+25 and full.burst>middle.burst+50,"charge produces smoothly increasing usable distances")
	check(absf(capped.burst-full.burst)<1 and absf(capped.force-full.force)<1,"holding beyond maximum cannot increase launch power")
	await fixture();Input.action_press("ability");await frames(60)
	check(dash.charging and not dash.dashing and dash.charge_ratio==1,"full charge waits for release without auto-launching")
	var counter=[0];dash.feedback.connect(func(id): if id=="charge_full": counter[0]+=1)
	await frames(60);check(counter[0]==0,"maximum feedback does not repeat while held")
	await fixture();Input.action_press("right");Input.action_press("ability");await frames(12)
	check(p.velocity.x>=330 and p.position.x>230,"charging retains ground acceleration and movement")
	Input.action_release("right");Input.action_press("aim_up");Input.action_release("ability");await frames(2)
	check(dash.last_velocity.y<0 and dash.direction==Vector2.UP,"launch uses direction held at release")
	await fixture();p.reset_at(Vector2(200,380));await frames(1);await hold(3,Vector2.DOWN)
	check(dash.last_velocity.y>500 and dash.direction==Vector2.DOWN,"downward launch works while airborne")
	await fixture();dash.tuning.forward_momentum=0;dash.tuning.cross_momentum=0;await hold(24,Vector2(1,-1))
	var expected=Vector2(1,-1).normalized()*Vector2(1.5,1)*dash.last_force
	check(dash.last_velocity.distance_to(expected)<1,"diagonal normalization precedes the requested 1.5 horizontal multiplier")
	for vector in [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN,Vector2(1,1),Vector2(-1,1),Vector2(1,-1),Vector2(-1,-1)]:
		await fixture();dash.tuning.forward_momentum=0;dash.tuning.cross_momentum=0;p.reset_at(Vector2(200,300));await frames(2);await hold(3,vector)
		check(dash.last_force>0 and dash.last_velocity.normalized().distance_to((vector*Vector2(1.5,1)).normalized())<.001,"release supports scaled direction "+str(vector))
	await fixture();p.reset_at(Vector2(200,200));await frames(1);await hold(3)
	check(dash.dashing and dash.air_used==1,"airborne charging consumes one configurable air launch")
	await frames(10);Input.action_press("ability");await frames(2)
	check(not dash.charging,"air budget prevents unintended infinite flight")
	Input.action_release("ability");await frames(60)
	check(p.is_on_floor() and dash.air_used==0,"landing restores the air budget")
	await fixture();dash.tuning.airborne_charging=false;p.reset_at(Vector2(200,300));await frames(1);Input.action_press("ability");await frames(2)
	check(not dash.charging,"airborne charging can be disabled in tuning")
	await fixture();dash.tuning.air_launches=0;p.reset_at(Vector2(200,100));await frames(1);await hold(3);await frames(15);Input.action_press("ability");await frames(2)
	check(dash.charging,"air limit zero enables repeat launches for experiments")
	await fixture();Input.action_press("right");await frames(12);await hold(24)
	check(dash.last_velocity.x>middle.velocity.x+100,"running momentum contributes to a launch")
	for i in 30:
		await frames(1)
		if not dash.dashing: break
	check(p.velocity.x>340,"excess horizontal momentum survives the dash exit")
	Input.action_release("right");Input.action_press("left");await frames(13)
	check(p.velocity.x<0,"reverse input brakes the stronger dash and reverses within 0.22 seconds")
	await fixture();Input.action_press("ability");await frames(54);Input.action_press("jump");Input.action_release("ability");await frames(3)
	check(p.velocity.y<0 and p.velocity.x>340 and not dash.dashing,"same-tick ground jump and dash release preserve the jump and excess momentum")
	await fixture();p.remember_lift(Vector2(100,-100));await hold(3)
	check(dash.last_velocity.x>short.velocity.x+25 and dash.last_velocity.y<0,"recent moving-platform velocity contributes once to a dash")
	check(p.lift_memory==0,"launch consumes the stored platform momentum")
	await fixture();surface(Vector2(500,150),Vector2(48,474));await frames(2);await hold(54)
	await frames(30)
	check(p.position.x<=488.1 and not dash.dashing,"solid walls stop even a full charge without tunnelling")
	await fixture();surface(Vector2(0,280),Vector2(600,48));await frames(2);await hold(54,Vector2.UP);await frames(20)
	check(p.position.y>=370 and not dash.dashing,"ceiling impact ends an upward dash")
	await fixture();Input.action_press("ability");await frames(15);dash.interrupt(p,"pause");p.active=false;Input.action_release("ability");await frames(5);p.active=true;await frames(2)
	check(not dash.charging and not dash.dashing and dash.last_force==0,"releasing while paused cannot launch on resume")
	Input.action_press("ability");await frames(5);p.reset_at(Vector2(200,624));await frames(2);Input.action_release("ability");await frames(2)
	check(not dash.charging and not dash.dashing and dash.air_used==0,"checkpoint reset cancels held charge and clears dash state")
	await fixture();await hold(3);await frames(1);p.bounce(840)
	check(not dash.dashing and p.spring_flight and p.velocity.y==-840,"a spring interrupts the dash through the ability interface")
	release();root.remove_child(arena);arena.queue_free();p=null;dash=null;await frames(3)
	print("CHARGE DASH TEST COMPLETE: ",failures," failures");call_deferred("quit",1 if failures else 0)
