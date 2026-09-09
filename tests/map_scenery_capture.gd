extends SceneTree
var app: Node2D
func _initialize() -> void: call_deferred("run")
func frames(count: int) -> void:
	for i in count: await process_frame
func shot(name: String) -> void:
	app.screen = "playing" if app.world else app.screen
	app.overlay.queue_redraw(); app.background.queue_redraw()
	await frames(3)
	RenderingServer.force_draw(); RenderingServer.force_sync()
	root.get_texture().get_image().save_png(OS.get_environment("YEARBOUND_CAPTURE_DIR").path_join(name + ".png"))
func run() -> void:
	DirAccess.make_dir_recursive_absolute(OS.get_environment("YEARBOUND_CAPTURE_DIR"))
	app = load("res://main.tscn").instantiate(); root.add_child(app); await frames(5)
	app.transition = 0; await shot("title")
	var selected = OS.get_environment("YEARBOUND_CAPTURE_IDS").split(",", false)
	for id in app.stage_order:
		if not selected.is_empty() and id not in selected: continue
		app.start_stage(id); await frames(3)
		app.world.set_running(false); app.transition = 0; app.intro = 0; app.toast_time = 0
		await shot(id + "-opening")
		if id not in ["06-01", "06-06", "06-08", "06-09", "06-15", "06-18", "06-20", "06-21", "06-22", "06-29", "06-30", "11-19", "03-09"]: continue
		var w = app.world
		for index in w.spec.journey_regions.size():
			var region = w.spec.journey_regions[index]
			var route = w.spec.challenge.route.filter(func(p): return p.room == index)
			var at = route[mini(5, route.size() - 1)].at
			w.player.position = Vector2(at[0], at[1]); w.camera_x = clampf(at[0] - 300, 0, w.spec.length - 1280)
			w.camera_y = minf(0, at[1] - 430); w.camera.position = Vector2(w.camera_x + 640, w.camera_y + 360)
			if w.june_boss: w.june_boss.enter(index); w.june_boss.attack_clock = 0; w.june_boss.update(.016)
			await shot(id + "-place-" + str(index + 1))
		if w.june_boss:
			w.june_boss.phase_time = 36; w.june_boss.update(.016); w.june_boss.aftermath = 3
			w.player.position = Vector2(w.spec.goal[0] - 90, 624); w.camera_x = w.spec.length - 1280
			w.camera_y = 0; w.camera.position = Vector2(w.camera_x + 640, 360)
			await shot(id + "-aftermath")
	root.remove_child(app); app.queue_free(); await frames(3)
	print("MAP SCENERY CAPTURE COMPLETE")
	quit()
