extends SceneTree
var failures=0
func _initialize() -> void: call_deferred("run")
func frames(n: int) -> void:
	for i in n: await physics_frame
func check(ok: bool, text: String) -> void:
	if ok: print("PASS: ",text)
	else: failures+=1;push_error(text)
func run() -> void:
	var app=load("res://main.tscn").instantiate();root.add_child(app);await frames(2)
	app.start_stage("06-01");await frames(30)
	var p=app.world.player
	var ledge=app.world.platforms[0].data
	p.reset_at(Vector2(ledge.x+ledge.w-12,ledge.y));await frames(4)
	p.velocity=Vector2(340,0);Input.action_press("right");await frames(7)
	check(not p.is_on_floor(),"coyote test has left the ledge")
	Input.action_press("jump");await frames(2)
	check(p.velocity.y < -350,"coyote jump fires after leaving a ledge")
	Input.action_release("jump");Input.action_release("right")
	p.reset_at(Vector2(200,app.world.spec.ground.y-20));p.velocity.y=150;p.coyote=0;await frames(1)
	Input.action_press("jump");await frames(9)
	check(p.velocity.y < -400,"buffered jump fires on landing")
	Input.action_release("jump")
	app.start_stage("06-15");await frames(3);p=app.world.player
	var spring=app.world.platforms.filter(func(item): return item.data.kind=="spring")[0]
	p.reset_at(spring.body.position+Vector2(spring.data.w/2,-25));p.velocity.y=200;await frames(17)
	check(p.velocity.y < -500,"bellflower platform launches player")
	app.start_stage("10-12");await frames(3);p=app.world.player
	var leaf=app.world.platforms.filter(func(item): return item.data.kind=="crumble")[0]
	p.reset_at(leaf.body.position+Vector2(leaf.data.w/2,-10));await frames(48)
	check(leaf.gone,"leaf platform crumbles after contact")
	await frames(235)
	check(not leaf.gone,"leaf platform regenerates")
	app.start_stage("01-18");await frames(3);p=app.world.player
	p.reset_at(Vector2(850,app.world.spec.ground.y));await frames(4)
	p.velocity.x=300;await frames(10)
	check(p.ice and p.velocity.x>250,"ice preserves momentum when input releases")
	app.start_stage("03-09");await frames(3);p=app.world.player
	p.reset_at(Vector2(1000,510));await frames(30)
	check(p.velocity.y<0 and p.position.y<490,"waterfall updraft lifts without an attack ability")
	app.world.checkpoint_index=0;app.save_run();app.save_run()
	var path=app.store.PATH
	var broken=FileAccess.open(path,FileAccess.WRITE);broken.store_string("{broken");broken.close()
	var recovered=YBSave.new()
	check(recovered.data.has("run"),"corrupt primary save recovers from backup")
	recovered.persist();recovered=null
	root.remove_child(app);app.queue_free();await frames(3)
	print("MECHANIC TEST COMPLETE: ",failures," failures")
	call_deferred("quit",1 if failures else 0)
