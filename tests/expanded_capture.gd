extends SceneTree
var app: Node2D
func _initialize() -> void: call_deferred("run")
func frames(n: int) -> void:
	for i in n: await process_frame
func shot(name: String) -> void:
	await frames(3)
	if app.screen=="pause": app.screen="playing"
	RenderingServer.force_draw();RenderingServer.force_sync()
	root.get_texture().get_image().save_png(OS.get_environment("YEARBOUND_CAPTURE_DIR").path_join(name+".png"))
func pose(app: Node2D,id: String, room: int, point: int=0) -> void:
	app.start_stage(id);await frames(4);var w=app.world;w.set_running(false);app.transition=0;app.intro=0
	var locations=w.spec.challenge.route.filter(func(p): return p.room==room)
	var at=locations[mini(point,locations.size()-1)].at
	w.player.position=Vector2(at[0],at[1]);w.player.velocity=Vector2.ZERO;w.player.swimming.sample(w.player,0)
	w.camera_x=clampf(at[0]-280,0,w.spec.length-1280);w.camera_y=clampf(at[1]-430,w.spec.world_top,0);w.camera.position=Vector2(w.camera_x+640,w.camera_y+360);w.age=9
func run() -> void:
	app=load("res://main.tscn").instantiate();root.add_child(app);await frames(8);app.transition=0;await shot("title")
	for item in [["06-01",0,0],["06-09",3,1],["06-12",1,1],["06-16",0,1],["10-12",2,1],["11-19",3,0],["01-18",3,1],["03-09",1,1],["06-30",3,1]]:
		await pose(app,item[0],item[1],item[2]);await shot(item[0]+"-vertical")
	app.start_stage("06-30");await frames(3);var w=app.world;w.player.reset_at(Vector2(w.spec.boss.arena_x+96,624));await frames(4);w.set_running(false);app.transition=0;app.intro=0;await shot("boss-arena")
	app.open_editor();await frames(4);app.editor.document.load_stage(app.stages["06-09"]);app.editor.sync_fields()
	app.editor.view=Vector2(app.stages["06-09"].challenge.rooms[3].from_x-200,-1000);app.editor.clamp_view();app.transition=0;await shot("workshop-height-and-dash")
	app.editor.action("spike_direction");await shot("workshop-wall-spikes")
	root.remove_child(app);app.queue_free();await frames(3);quit()
