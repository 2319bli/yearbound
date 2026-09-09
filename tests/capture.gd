extends SceneTree
func _initialize() -> void: call_deferred("run")
func frame_wait(count: int) -> void:
	for i in count: await process_frame
func shot(name: String) -> void:
	await frame_wait(3)
	# Explicitly draw for readback even if macOS has occluded the test window.
	RenderingServer.force_draw()
	RenderingServer.force_sync()
	root.get_texture().get_image().save_png(OS.get_environment("YEARBOUND_CAPTURE_DIR").path_join(name+".png"))
func run() -> void:
	var app=load("res://main.tscn").instantiate();root.add_child(app)
	await frame_wait(8);app.transition=0
	await shot("title")
	app.change_screen("calendar");app.transition=0
	await shot("calendar")
	for id in app.stage_order:
		app.start_stage(id);await frame_wait(10)
		if id=="06-01":
			app.screen="playing";app.world.set_running(false);app.transition=0;app.intro=0
			await shot("06-01-opening")
		if id != "06-30":
			var best=app.world.platforms[0]
			var score=INF
			for platform in app.world.platforms:
				if platform.data.kind in ["moving","spring","crumble"]: continue
				var distance=absf(platform.body.position.x+float(platform.data.w)*0.5-1570)
				if distance<score: best=platform;score=distance
			app.world.player.position=best.body.position+Vector2(minf(100,float(best.data.w)*0.4),0)
			app.world.player.velocity=Vector2.ZERO
			app.world.camera_x=maxf(0,app.world.player.position.x-450)
			app.world.camera.position=Vector2(app.world.camera_x+640,360)
		app.screen="playing";app.world.queue_redraw();app.world.set_running(false);app.transition=0;app.intro=0
		await shot(id)
	app.change_screen("settings");app.transition=0
	await shot("settings")
	root.remove_child(app);app.queue_free();await frame_wait(2)
	quit()
