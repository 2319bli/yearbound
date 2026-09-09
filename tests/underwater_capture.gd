extends SceneTree
func _initialize() -> void: call_deferred("run")
func frames(n: int) -> void:
	for i in n: await process_frame
func shot(name: String) -> void:
	await frames(4);RenderingServer.force_draw();RenderingServer.force_sync()
	root.get_texture().get_image().save_png(OS.get_environment("YEARBOUND_CAPTURE_DIR").path_join(name+".png"))
func run() -> void:
	var app=load("res://main.tscn").instantiate();root.add_child(app);await frames(10)
	app.transition=0;await shot("title")
	app.start_stage("11-19");await frames(8);app.world.set_running(false);app.transition=0;app.intro=0
	await shot("november-start")
	var w=app.world
	for index in 3:
		w.player.position=Vector2([1320,3630,6160][index],[385,330,440][index]);w.player.velocity=Vector2(130,0)
		w.player.swimming.sample(w.player,0)
		w.camera_x=[900,3120,5650][index];w.camera.position=Vector2(w.camera_x+640,360);w.age=6
		await shot("november-"+str(index+1))
	app.start_stage("06-01");await frames(4);app.world.set_running(false);app.transition=0;app.intro=0;await shot("june-regression")
	root.remove_child(app);app.queue_free();await frames(3);quit()
