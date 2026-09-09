extends SceneTree
# Real CharacterBody2D/collision tests. Run with --fixed-fps 60.
var failures := 0
var arena: Node2D
var p: YBPlayer
var landing_tick := -1
var jump_tick := -2
func _initialize() -> void: call_deferred("run")
func frames(count: int) -> void:
	for i in count: await physics_frame
func check(ok: bool, message: String) -> void:
	if ok: print("PASS: ",message)
	else: failures+=1;push_error(message)
func release_inputs() -> void:
	for action in ["left","right","jump","ability"]: Input.action_release(action)
func surface(at: Vector2, size: Vector2) -> StaticBody2D:
	var body=StaticBody2D.new()
	var shape=CollisionShape2D.new()
	var rect=RectangleShape2D.new();rect.size=size;shape.shape=rect;shape.position=size*.5
	body.add_child(shape);body.position=at;arena.add_child(body)
	return body
func fixture() -> void:
	release_inputs()
	if is_instance_valid(arena):
		root.remove_child(arena);arena.queue_free();await frames(2)
	arena=Node2D.new();root.add_child(arena)
	surface(Vector2(-500,600),Vector2(3000,100))
	p=YBPlayer.new();p.position=Vector2(200,600);arena.add_child(p)
	p.landed.connect(func(_speed): landing_tick=Engine.get_physics_frames())
	p.jumped.connect(func(): jump_tick=Engine.get_physics_frames())
	await frames(5)
func jump_measure(held_frames: int) -> Dictionary:
	await fixture()
	var start_y=p.position.y
	var minimum=start_y
	var apex_frame=0
	var duration=0
	Input.action_press("jump")
	for i in 100:
		await frames(1)
		if i==held_frames: Input.action_release("jump")
		if p.position.y<minimum: minimum=p.position.y;apex_frame=i
		if i>4 and p.is_on_floor(): duration=i;break
	Input.action_release("jump")
	return {"height":start_y-minimum,"apex_seconds":apex_frame/60.0,"air_seconds":duration/60.0}
func run() -> void:
	for action in ["left","right","jump","ability"]:
		if not InputMap.has_action(action): InputMap.add_action(action)
	await fixture()
	Input.action_press("right");await frames(8)
	check(p.velocity.x>=330,"ground movement reaches full speed within 0.12 seconds")
	Input.action_release("right");var stop_start=p.position.x;await frames(8)
	var ground_drift=p.position.x-stop_start
	check(absf(p.velocity.x)<1 and ground_drift<19,"ground release stops within 19 logical pixels")
	Input.action_press("right");await frames(8);Input.action_release("right");Input.action_press("left");await frames(6)
	check(p.velocity.x<0,"ground direction reversal responds within a tenth of a second")
	await fixture();p.reset_at(Vector2(200,350));p.velocity.x=340;stop_start=p.position.x;await frames(12)
	var air_drift=p.position.x-stop_start
	check(absf(p.velocity.x)<1 and air_drift<30,"air release stops within 30 logical pixels")
	await fixture();p.reset_at(Vector2(200,350));p.velocity.x=340;Input.action_press("left");await frames(9)
	check(p.velocity.x<0,"air reversal responds without a long slide")
	var short_jump=await jump_measure(1)
	var medium_jump=await jump_measure(5)
	var full_jump=await jump_measure(50)
	print("MEASURE jump tap=",short_jump," medium=",medium_jump," full=",full_jump," ground_drift=",ground_drift," air_drift=",air_drift)
	check(short_jump.height>30 and short_jump.height<65,"tap jump gives a usable short hop")
	check(medium_jump.height>short_jump.height+10 and full_jump.height>medium_jump.height+10,"jump height responds progressively to hold duration")
	check(full_jump.height>=108 and full_jump.height<=128,"full jump preserves the sample stages' required rises")
	check(full_jump.air_seconds<0.72,"full jump returns promptly instead of floating")
	await fixture()
	p.reset_at(Vector2(200,582));p.velocity.y=100;await frames(1)
	landing_tick=-1;jump_tick=-2
	Input.action_press("jump");await frames(10)
	check(landing_tick==jump_tick,"buffered jump fires on the exact landing physics tick")
	await fixture();p.reset_at(Vector2(200,330));Input.action_press("jump");await frames(1);Input.action_release("jump");await frames(45)
	check(p.is_on_floor() and absf(p.velocity.y)<1,"expired air input cannot cause an unexpected landing jump")
	await fixture()
	# A six-pixel head overlap at the outer corner should slide clear.
	surface(Vector2(300,460),Vector2(120,24));await frames(2)
	p.reset_at(Vector2(294,530));p.velocity=Vector2(-50,-340);await frames(3)
	check(p.position.x<289 and p.velocity.y<0,"near-miss head corner is corrected without cancelling ascent")
	await fixture();surface(Vector2(100,460),Vector2(400,24));await frames(2)
	p.reset_at(Vector2(280,530));p.velocity.y=-340;Input.action_press("jump");await frames(8)
	check(p.position.y>=526 and p.velocity.y>=0,"a full ceiling blocks the jump and clears upward sustain")
	await fixture()
	surface(Vector2(100,350),Vector2(100,250));surface(Vector2(230,350),Vector2(100,250));surface(Vector2(200,450),Vector2(30,24));await frames(2)
	p.reset_at(Vector2(215,520));p.velocity.y=-300;await frames(5)
	check(p.position.x>=212 and p.position.x<=218 and p.position.y>=516,"corner correction cannot push through narrow side walls")
	await fixture();p.remember_lift(Vector2(80,-100));p.remember_lift(Vector2.ZERO);Input.action_press("jump");await frames(2)
	check(p.velocity.y < -550 and p.velocity.x>0,"recent lift momentum boosts a jump after the lift stops")
	await fixture();p.remember_lift(Vector2(100,-100));await frames(10);Input.action_press("jump");await frames(2)
	check(p.velocity.y > -510 and absf(p.velocity.x)<1,"stored lift momentum expires")
	p.bounce(840);p.wind=Vector2(60,-300);p.reset_at(Vector2(200,600))
	check(not p.spring_flight and p.spring_lock==0 and p.lift_memory==0 and p.wind==Vector2.ZERO and p.jump_hold==0,"checkpoint reset clears launch, wind and buffered movement state")
	await frames(5);p.assist=true;Input.action_release("jump");await frames(1);Input.action_press("jump");await frames(2)
	check(p.velocity.y < -500,"gentle journey still supplies its larger jump")
	var frozen=p.position;p.active=false;await frames(10)
	check(p.position==frozen,"pause freezes the controller and its timers")
	release_inputs();root.remove_child(arena);arena.queue_free();p=null;await frames(3)
	print("CONTROLLER TEST COMPLETE: ",failures," failures")
	call_deferred("quit",1 if failures else 0)
