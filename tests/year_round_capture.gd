extends SceneTree
func _initialize() -> void: call_deferred("run")
func frames(n: int) -> void:
	for i in n: await process_frame
func shot(name: String) -> void:
	await frames(3);RenderingServer.force_draw();RenderingServer.force_sync()
	root.get_texture().get_image().save_png(OS.get_environment("YEARBOUND_CAPTURE_DIR").path_join(name+".png"))
func run() -> void:
	var app=load("res://main.tscn").instantiate();root.add_child(app);await frames(8);app.transition=0
	await shot("title");app.change_screen("calendar");app.transition=0;await shot("calendar")
	for id in ["07-16","08-23","09-14","11-19","12-08","02-17","04-11","05-24"]:
		app.start_stage(id);await frames(3);app.world.set_running(false);app.transition=0;app.intro=0
		await shot(id)
		app.world.player.position=Vector2(1512,624);app.world.camera_x=1080;app.world.camera.position=Vector2(1720,360)
		for hazard in app.world.spec.hazards:
			if hazard.type=="bramble" and hazard.x<app.world.player.position.x+12 and hazard.x+hazard.w>app.world.player.position.x-12: app.world.player.position.x=hazard.x-40
		for platform in app.world.platforms:
			var at=platform.body.position
			if at.x<app.world.player.position.x and at.x+platform.data.w>app.world.player.position.x: app.world.player.position.y=minf(app.world.player.position.y,at.y)
		await shot(id+"-landmark")
	app.start_lab();app.lab_station(16);await frames(3);app.world.set_running(false);app.transition=0
	await shot("extended-course");app.pause_game();app.transition=0;await shot("extended-stations")
	root.remove_child(app);app.queue_free();await frames(3);quit()
