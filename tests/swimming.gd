extends SceneTree
var failures=0
var arena: Node2D
var p: YBPlayer
func _initialize() -> void: call_deferred("run")
func frames(n: int) -> void:
	for i in n: await physics_frame
func check(ok: bool, message: String) -> void:
	if ok: print("PASS: ",message)
	else: failures+=1;push_error(message)
func release() -> void:
	for action in YBControls.ACTIONS: Input.action_release(action)
func surface(at: Vector2,size: Vector2) -> void:
	var body=StaticBody2D.new();body.position=at
	var collider=CollisionShape2D.new();var shape=RectangleShape2D.new();shape.size=size;collider.shape=shape;collider.position=size/2
	body.add_child(collider);arena.add_child(body)
func fixture(wet: bool=true) -> void:
	release()
	if arena: root.remove_child(arena);arena.queue_free();await frames(2)
	arena=Node2D.new();root.add_child(arena)
	surface(Vector2(-500,624),Vector2(6000,96))
	p=YBPlayer.new();p.ability=YBChargeDash.new();p.position=Vector2(200,400)
	if wet: p.swimming.volumes=[{"x":-500,"y":144,"w":6000,"h":624}]
	arena.add_child(p);await frames(4)
func dash_burst(wet: bool) -> float:
	await fixture(wet)
	# Fix the start before release to compare water resistance without incoming speed.
	p.active=false
	Input.action_press("ability");p.ability.charging=true;p.ability.charge_ratio=1
	p.position=Vector2(200,400);p.velocity=Vector2.ZERO
	Input.action_release("ability");p.active=true
	await frames(2)
	for i in 30:
		await frames(1)
		if not p.ability.dashing: break
	return p.ability.dash_displacement.x
func run() -> void:
	YBControls.apply({})
	await fixture();var start=p.position
	await frames(60)
	check(p.swimming.submerged and p.position.y<start.y-15 and p.position.y>start.y-30,"idle buoyancy gives a gentle rise rather than terrestrial gravity")
	Input.action_press("right");await frames(60)
	check(p.velocity.x>205 and p.velocity.x<215,"swimming has a controlled 210 px/s horizontal terminal speed")
	Input.action_release("right");start=p.position;await frames(45)
	check(absf(p.velocity.x)<14 and p.position.x-start.x<60,"water drag dissipates released momentum without an instant stop")
	await fixture();Input.action_press("aim_up");await frames(45)
	check(p.velocity.y < -180 and p.position.y<300,"up action swims upward freely")
	Input.action_release("aim_up");Input.action_press("aim_down");await frames(30)
	check(p.velocity.y>160,"down input reverses ascent and dives")
	Input.action_press("jump");await frames(5)
	check(p.velocity.y>160,"down takes precedence over held jump")
	Input.action_release("aim_down");await frames(40)
	check(p.velocity.y < -175,"held jump swims upward without requiring a floor")
	await fixture();Input.action_press("right");Input.action_press("aim_down");await frames(35)
	check(p.velocity.length()<215 and p.velocity.x<160,"diagonal swimming is normalized")
	await fixture()
	var key_event=InputEventKey.new();key_event.physical_keycode=KEY_I;key_event.pressed=true;Input.parse_input_event(key_event);await frames(25)
	check(p.velocity.y < -160,"IJKL upward swimming works through real keyboard events")
	key_event.pressed=false;Input.parse_input_event(key_event)
	YBControls.apply({"aim_down":[YBControls.key(KEY_V)]});await fixture()
	key_event=InputEventKey.new();key_event.physical_keycode=KEY_V;key_event.pressed=true;Input.parse_input_event(key_event);await frames(25)
	check(p.velocity.y>160,"rebound vertical input controls diving")
	key_event.pressed=false;Input.parse_input_event(key_event);YBControls.apply({})
	await fixture();var stick_event=InputEventJoypadMotion.new();stick_event.axis=JOY_AXIS_LEFT_Y;stick_event.axis_value=-1;Input.parse_input_event(stick_event);await frames(25)
	check(p.velocity.y < -160,"controller stick events drive upward swimming")
	stick_event.axis_value=0;Input.parse_input_event(stick_event)
	await fixture();p.wind=Vector2(300,0);await frames(60)
	check(p.velocity.x>70 and p.velocity.x<85,"currents produce finite physical drift against drag")
	await fixture();p.reset_at(Vector2(200,180));p.velocity=Vector2.ZERO;await frames(400)
	check(p.swimming.submerged and p.position.y>169 and p.position.y<176,"buoyancy settles at the surface without state flicker")
	Input.action_press("jump");var crossed=false
	for i in 80:
		await frames(1)
		if not p.swimming.submerged: crossed=true;break
	check(crossed and p.velocity.y<0,"holding jump breaches the real water surface")
	release();await frames(110)
	check(p.swimming.submerged,"falling back into a volume restores water physics")
	await fixture();surface(Vector2(340,144),Vector2(48,480));Input.action_press("right");await frames(100)
	check(p.position.x<329,"solid walls block swimming")
	await fixture();surface(Vector2(80,240),Vector2(500,48));Input.action_press("aim_up");await frames(100)
	check(p.position.y>=329,"swimming cannot tunnel through a ceiling")
	var dry=await dash_burst(false);var wet=await dash_burst(true)
	print("MEASURE dash dry=",dry," water=",wet)
	check(wet<dry*.85 and wet>dry*.5,"the original dash is resisted by water, not replaced with boosted settings")
	check(p.ability.tuning.horizontal_force==1.5 and p.ability.tuning.maximum_force==1180,"swimming retains the agreed original dash profile")
	check(p.ability.air_used==1,"water dash spends the existing air allowance")
	await frames(50)
	check(p.ability.air_used==0 and p.ability.available(false),"dash refills after a short swimming recovery without touching the floor")
	Input.action_press("ability");await frames(12);var at=p.position;var charge=p.ability.charge_ratio
	p.active=false;await frames(30)
	check(p.position==at and p.ability.charge_ratio==charge,"pause freezes swimming, charge and recovery timers")
	p.reset_at(Vector2(200,90));p.active=true;release();await frames(1)
	check(not p.swimming.submerged and p.floor_snap_length==6 and p.ability.air_used==0,"reset clears water state and restores normal floor snap")
	root.remove_child(arena);arena.queue_free();arena=null;await frames(3)
	var app=load("res://main.tscn").instantiate();root.add_child(app);await frames(3)
	app.start_stage("11-19");await frames(8)
	var w=app.world
	check(w.player.swimming.submerged,"November starts physically submerged")
	await frames(55)
	check(app.audio.water_filter.cutoff_hz<1500,"submersion smoothly muffles the music")
	var doc=YBLayoutDocument.new();doc.load_stage(w.spec)
	check(YBLayoutDocument.same(doc.compile().zones,w.spec.zones),"workshop round-trip retains physical water and currents")
	for index in w.spec.checkpoints.size():
		w.restore({"checkpoint_index":index,"deaths":2,"elapsed":32});await frames(6)
		check(w.player.swimming.submerged and w.deaths==2 and w.respawn_delay<=0,"underwater checkpoint restores safely")
	w.die();await frames(35)
	check(w.player.active and w.player.swimming.submerged and w.player.ability.air_used==0,"death restores swimming and dash at the saved lantern")
	app.start_stage("06-01");await frames(5)
	check(w!=app.world and app.world.player.swimming.volumes.is_empty() and not app.world.player.swimming.submerged,"June's decorative streams do not change land physics")
	await frames(55);check(app.audio.water_filter.cutoff_hz>20000,"leaving water restores the normal music filter")
	app.start_stage("11-19");await frames(4);w=app.world
	# Input-driven waypoints through every alternating over/under passage.
	var points=[Vector2(360,480),Vector2(760,450),Vector2(850,330),Vector2(1230,330),Vector2(1480,540),Vector2(2010,540),Vector2(2070,480),Vector2(2350,480),Vector2(2430,560),Vector2(2520,606),Vector2(2820,420),Vector2(2940,310),Vector2(3340,310),Vector2(3660,310),Vector2(3720,565),Vector2(4100,565),Vector2(4260,550),Vector2(4340,280),Vector2(4740,280),Vector2(5000,550),Vector2(5112,605),Vector2(5350,545),Vector2(5890,545),Vector2(5920,210),Vector2(6260,210),Vector2(6670,275),Vector2(6800,540),Vector2(7220,540),Vector2(7512,608)]
	var reached=0
	for target in points:
		for tick in 360:
			var delta=target-w.player.position
			if delta.length()<23 or w.complete: break
			Input.action_release("left");Input.action_release("right");Input.action_release("aim_up");Input.action_release("aim_down")
			if absf(delta.x)>5: Input.action_press("right" if delta.x>0 else "left",clampf(absf(delta.x)/70,.15,1))
			if absf(delta.y)>5: Input.action_press("aim_down" if delta.y>0 else "aim_up",clampf(absf(delta.y)/70,.15,1))
			await frames(1)
		if w.player.position.distance_to(target)>=24 and not w.complete:
			print("ROUTE blocked target=",target," at=",w.player.position," deaths=",w.deaths);break
		reached+=1
	release()
	print("ROUTE underwater waypoints=",reached,"/",points.size()," complete=",w.complete," deaths=",w.deaths)
	check(reached==points.size() and w.checkpoint_index==1 and w.deaths==0,"November's original passages still reach both opening checkpoints without deaths; expanded chambers are verified separately")
	root.remove_child(app);app.queue_free();await frames(3)
	print("SWIMMING TEST COMPLETE: ",failures," failures");quit(1 if failures else 0)
