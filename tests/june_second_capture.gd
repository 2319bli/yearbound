extends SceneTree
func _initialize() -> void: call_deferred("run")
func frames(n: int) -> void:
	for i in n: await process_frame
func shot(name: String) -> void:
	await frames(3);RenderingServer.force_draw();RenderingServer.force_sync()
	root.get_texture().get_image().save_png(OS.get_environment("YEARBOUND_CAPTURE_DIR").path_join(name+".png"))
func run() -> void:
	var app=load("res://main.tscn").instantiate();root.add_child(app);await frames(8);app.transition=0;await shot("title")
	for day in range(9,18):
		var id="06-%02d"%day;app.start_stage(id);await frames(4);app.world.set_running(false);app.transition=0;app.intro=0
		await shot(id+"-opening")
		var w=app.world;var cp=w.spec.checkpoints[0]
		w.player.position=Vector2(cp[0],cp[1]);w.player.velocity=Vector2.ZERO
		w.camera_x=maxf(0,cp[0]-400);w.camera.position=Vector2(w.camera_x+640,360);w.age=7
		await shot(id+"-landmark")
	app.change_screen("calendar");app.selected="06-17";app.align_month();app.transition=0;await shot("calendar-june")
	app.open_editor();await frames(3);app.editor.document.load_stage(app.stages["06-09"]);app.editor.sync_fields();app.transition=0;await shot("workshop-glasshouse")
	root.remove_child(app);app.queue_free();await frames(3);quit()
