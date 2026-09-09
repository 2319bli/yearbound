extends SceneTree
func _initialize() -> void: call_deferred("run")
func frames(count: int) -> void:
	for i in count: await process_frame
func shot(name: String) -> void:
	await frames(3);RenderingServer.force_draw();RenderingServer.force_sync()
	root.get_texture().get_image().save_png(OS.get_environment("YEARBOUND_CAPTURE_DIR").path_join(name+".png"))
func run() -> void:
	var app=load("res://main.tscn").instantiate();root.add_child(app);await frames(6);app.transition=0
	await shot("title")
	app.start_lab();await frames(5);app.world.running=false;app.world.player.active=false;app.transition=0
	await shot("dash-lab")
	for i in app.world.spec.lab_stations.size():
		app.lab_station(i);await frames(2);app.world.running=false;app.world.player.active=false;app.transition=0
		await shot("station-%02d" % [i+1])
	app.lab_station(0);await frames(2)
	app.world.running=false;app.world.player.active=false;app.transition=0
	var dash=app.world.player.ability as YBChargeDash
	dash.charging=true;dash.charge_ratio=.55;dash.charge_time=.44;dash.direction=Vector2(1,-1).normalized();app.world.player.queue_redraw()
	await shot("charging")
	dash.charge_ratio=1;dash.charge_time=.8;app.world.player.queue_redraw();await shot("fully-charged")
	app.world.running=true;app.pause_game();await frames(3);app.transition=0;await shot("tuning")
	app.controls_return="lab_menu";app.change_screen("controls");app.transition=0;await shot("controls")
	root.remove_child(app);app.queue_free();await frames(3);quit()
