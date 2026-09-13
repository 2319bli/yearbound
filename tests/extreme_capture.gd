extends SceneTree
## Render-only samples; relocation is for screenshots, never route evidence.
var app: Node2D
func _initialize() -> void:call_deferred("run")
func frames(count: int) -> void:
	for i in count:await process_frame
func shot(name: String) -> void:
	app.transition=0;app.intro=0;app.toast_time=0
	app.overlay.queue_redraw();app.background.queue_redraw();await frames(3)
	RenderingServer.force_draw();RenderingServer.force_sync()
	root.get_texture().get_image().save_png(OS.get_environment("YEARBOUND_CAPTURE_DIR").path_join(name+".png"))
func run() -> void:
	DirAccess.make_dir_recursive_absolute(OS.get_environment("YEARBOUND_CAPTURE_DIR"))
	app=load("res://main.tscn").instantiate();root.add_child(app);await frames(4)
	await shot("title")
	app.activate("challenges");await frames(2);await shot("monthly-browser")
	for id in ["06-01","06-15","06-30","06-X01","07-X02","08-X03","09-X04","10-X05","11-X06","12-X07","01-X08","02-X09","03-X10","04-X11","05-X01"]:
		app.start_stage(id);app.world.set_running(false);await frames(2)
		var w=app.world
		var p=w.spec.platforms[mini(2,w.spec.platforms.size()-1)]
		w.player.position=Vector2(p.x+24,p.y);w.camera_x=clampf(p.x-330,0,w.spec.length-1280)
		w.camera_y=clampf(p.y-430,w.spec.world_top,0);w.camera.position=Vector2(w.camera_x+640,w.camera_y+360);w.age=.82
		for layer in w.render_layers.values():layer.queue_redraw()
		await shot(id)
	app.selected="11-X06";app.activate("challenges");await frames(2);await shot("november-browser")
	app.open_editor();await frames(2)
	app.editor.document.load_stage(app.stages["06-X01"]);app.editor.sync_fields();app.editor.view=Vector2(180,-192)
	await shot("challenge-workshop")
	root.remove_child(app);app.queue_free();await frames(2)
	print("EXTREME RENDER CAPTURE COMPLETE. No traversal attempted.");quit()
