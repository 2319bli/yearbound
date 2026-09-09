extends SceneTree
func _initialize() -> void: call_deferred("run")
func frames(n: int) -> void:
	for i in n: await process_frame
func shot(name: String) -> void:
	await frames(4);RenderingServer.force_draw();RenderingServer.force_sync()
	root.get_texture().get_image().save_png(OS.get_environment("YEARBOUND_CAPTURE_DIR").path_join(name+".png"))
func run() -> void:
	var app=load("res://main.tscn").instantiate();root.add_child(app);await frames(5)
	app.open_editor();await frames(5)
	app.editor.document.load_stage(JSON.parse_string(FileAccess.get_file_as_string("res://content/workshop_starter.json")));app.editor.sync_fields();app.transition=0
	await shot("Workshop")
	app.editor.playtest();await frames(15);app.screen="playing";app.transition=0;app.world.set_running(false)
	await shot("Workshop-playtest")
	app.return_to_editor();await frames(5)
	await shot("Workshop-return")
	root.remove_child(app);app.queue_free();await frames(3);quit()
