extends SceneTree
var app: Node2D
func _initialize() -> void:call_deferred("run")
func frames(n: int) -> void:
	for i in n:await process_frame
func shot(name: String) -> void:
	await frames(3)
	if app.screen=="pause":app.screen="playing"
	app.overlay.queue_redraw()
	RenderingServer.force_draw();RenderingServer.force_sync()
	root.get_texture().get_image().save_png(OS.get_environment("YEARBOUND_CAPTURE_DIR").path_join(name+".png"))
func run() -> void:
	DirAccess.make_dir_recursive_absolute(OS.get_environment("YEARBOUND_CAPTURE_DIR"))
	app=load("res://main.tscn").instantiate();root.add_child(app);await frames(6);app.transition=0;await shot("title")
	app.change_screen("calendar");app.month_index=0;app.transition=0;await shot("june-calendar")
	app.change_screen("settings");app.transition=0;await shot("settings")
	for id in app.stage_order:
		app.start_stage(id);await frames(4);app.world.set_running(false);app.transition=0;app.intro=0;app.world.age=.5
		await shot(id+"-opening")
	for id in ["06-01","06-06","06-08","06-09","06-12","06-18","06-21","06-29","06-30"]:
		for room in 5:
			app.start_stage(id);await frames(3);var w=app.world;w.set_running(false);app.transition=0;app.intro=0
			var route=w.spec.challenge.route.filter(func(p):return p.room==room)
			var at=route[mini(4,route.size()-1)].at
			w.player.position=Vector2(at[0],at[1]);w.camera_x=at[0]-300;w.camera_y=minf(0,at[1]-430);w.camera.position=Vector2(w.camera_x+640,w.camera_y+360)
			if w.june_boss:w.june_boss.enter(room);w.june_boss.attack_clock=0;w.june_boss.update(.016)
			await shot(id+"-room-"+str(room+1))
	app.start_stage("06-30");await frames(3);var w=app.world;w.set_running(false);app.transition=0;app.intro=0
	w.june_boss.enter(4);w.june_boss.phase_time=36;w.june_boss.update(.016);w.june_boss.aftermath=3
	w.player.position=Vector2(w.spec.goal[0]-90,624);w.camera_x=w.spec.length-1280;w.camera.position=Vector2(w.camera_x+640,360);app.toast_time=0;await shot("06-30-aftermath")
	app.open_editor();app.editor.document.load_stage(app.stages["06-18"]);app.editor.sync_fields();app.editor.view=Vector2(3500,-450);app.transition=0;await shot("garden-workshop")
	root.remove_child(app);app.queue_free();await frames(3);quit()
