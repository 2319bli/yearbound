extends SceneTree
var app: Node2D
var failures: Array[String] = []
func check(ok: bool, message: String) -> void:
	if not ok: failures.append(message);push_error(message)
	else: print("PASS: "+message)
func frames(count: int) -> void:
	for i in count: await physics_frame
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	app=load("res://main.tscn").instantiate();root.add_child(app)
	await frames(4)
	check(app.calendar.days.size()==365,"365 calendar dates")
	var bosses=0
	for day in app.calendar.days:
		if day.boss: bosses+=1
	check(bosses==12,"12 month-end boss slots")
	for id in app.stage_order:
		app.start_stage(id)
		await frames(45)
		check(app.world.player.is_on_floor() or app.world.player.swimming.submerged,id+" spawn settles on terrain or in physical water")
		check(app.world.deaths==0,id+" spawn is safe")
		check(ResourceLoader.exists(app.stages[id].music),id+" audio loads")
		app.pause_game()
		var before=app.world.elapsed
		await frames(8)
		check(app.world.elapsed==before,id+" pause stops the stage clock")
		app.resume_game()
	app.start_stage("06-01");await frames(30)
	var p=app.world.player
	Input.action_press("right");await frames(15)
	check(p.velocity.x>290,"acceleration reaches running speed")
	Input.action_release("right");await frames(14)
	check(absf(p.velocity.x)<1,"ground braking stops precisely")
	var floor_y=p.position.y
	Input.action_press("jump");await frames(21)
	var full_height=floor_y-p.position.y
	check(full_height>100,"full jump reaches intended apex")
	Input.action_release("jump");await frames(60)
	Input.action_press("jump");await frames(3);Input.action_release("jump");await frames(9)
	var short_height=floor_y-p.position.y
	check(short_height<full_height-25,"released jump is substantially lower")
	await frames(60)
	app.world.checkpoint=Vector2(200,floor_y);p.position=Vector2(750,900)
	await frames(50)
	check(app.world.deaths==1 and p.position.distance_to(Vector2(200,floor_y))<8,"death returns to checkpoint")
	app.world.checkpoint_index=0;app.world.collected[2]=true;app.save_run()
	var loaded=YBSave.new()
	check(loaded.data.has("run") and loaded.data.run.collected.has(2.0),"checkpoint and collectibles survive save reload")
	app.start_stage("06-30");await frames(20)
	app.world.player.reset_at(Vector2(app.world.spec.boss.get("arena_x",0)+96,624));await frames(5)
	app.world.boss_time=35.1;app.world.die();await frames(40)
	check(app.world.boss_time>=35 and app.world.boss_time<36,"boss death preserves completed phase")
	app.world.boss_time=104.99;app.world.projectiles.clear();await frames(3)
	check(app.screen=="complete","boss survival triggers completion screen")
	check(app.store.data.results.has("06-30"),"completion records a date result")
	for id in ["06-01","06-15","10-12","01-18","03-09"]:
		app.start_stage(id);await frames(3)
		app.world.player.position=Vector2(app.stages[id].goal[0],app.stages[id].goal[1])
		await frames(2)
		check(app.screen=="complete",id+" goal completes stage")
	print("SMOKE TEST COMPLETE: ",failures.size()," failures")
	root.remove_child(app);app.queue_free();app=null;loaded=null
	await frames(3)
	call_deferred("quit",1 if not failures.is_empty() else 0)
