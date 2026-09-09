extends SceneTree
func _initialize() -> void: call_deferred("run")
func frames(n: int) -> void:
	for i in n: await process_frame
func shot(name: String) -> void:
	await frames(3);RenderingServer.force_draw();RenderingServer.force_sync()
	root.get_texture().get_image().save_png(OS.get_environment("YEARBOUND_CAPTURE_DIR").path_join(name+".png"))
func run() -> void:
	var app=load("res://main.tscn").instantiate();root.add_child(app);await frames(5)
	for day in range(2,9):
		var id="06-%02d" % day
		app.start_stage(id);await frames(3);app.world.set_running(false)
		app.world.player.position=Vector2(2568,624);app.world.player.velocity=Vector2.ZERO
		app.world.camera_x=2300;app.world.camera.position=Vector2(2940,360)
		app.world.age=9;app.transition=0;app.intro=0
		await shot(id+"-landmark")
	app.change_screen("calendar");app.selected="06-04";app.align_month();app.transition=0;await shot("calendar-june")
	app.open_editor();await frames(3)
	app.editor.document.load_stage(app.stages["06-08"]);app.editor.sync_fields();app.transition=0
	await shot("workshop-june")
	root.remove_child(app);app.queue_free();await frames(2);quit()
