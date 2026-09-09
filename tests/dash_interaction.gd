extends SceneTree
# Run --headless --fixed-fps 60 for reproducible engine input: real desktop
# focus changes intentionally pause gameplay and release held keys.
# Use year_round_capture.gd separately for native-renderer verification.
var failures=0
func _initialize() -> void: call_deferred("run")
func frames(n: int) -> void:
	# Native render rate is uncapped and can greatly exceed the physics rate.
	# Hold input for simulated gameplay ticks, then let audio/UI observe the result.
	for i in n: await physics_frame
	await process_frame
	await process_frame
func check(ok: bool, message: String) -> void:
	if ok: print("PASS: ",message)
	else: failures+=1;push_error(message)
func key(code: Key, pressed: bool) -> void:
	var event=InputEventKey.new();event.keycode=code;event.physical_keycode=code;event.pressed=pressed;Input.parse_input_event(event);await frames(2)
func click(at: Vector2) -> void:
	Input.warp_mouse(at);await frames(2)
	var motion=InputEventMouseMotion.new();motion.position=at;motion.global_position=at;root.push_input(motion,true)
	for down in [true,false]:
		var event=InputEventMouseButton.new();event.position=at;event.global_position=at;event.button_index=MOUSE_BUTTON_LEFT;event.pressed=down;root.push_input(event,true);await frames(2)
func run() -> void:
	var app=load("res://main.tscn").instantiate();root.add_child(app);await frames(12);app.transition=0;RenderingServer.force_draw();RenderingServer.force_sync();await frames(3)
	await click(Vector2(990,198));check(app.lab_test and app.screen=="playing","native title button opens Dash Lab")
	if not app.lab_test:
		print("CLICK DIAGNOSTIC mouse=",root.get_mouse_position()," window=",DisplayServer.window_get_size()," viewport=",root.get_visible_rect()," screen=",app.screen," buttons=",app.buttons)
		RenderingServer.force_draw();RenderingServer.force_sync();root.get_texture().get_image().save_png(OS.get_environment("YEARBOUND_SAVE_DIR").path_join("click-failure.png"))
		quit(1);return
	await key(KEY_C,true);await frames(55)
	var dash=app.world.player.ability as YBChargeDash
	check(dash.charging and dash.charge_ratio>.5 and app.audio.charge_hum.playing,"held keyboard binding charges and starts the rising audio cue")
	var high_pitch=app.audio.charge_hum.pitch_scale
	await frames(50)
	if dash.charge_ratio!=1: print("CHARGE DIAGNOSTIC screen=",app.screen," active=",app.world.player.active," charge=",dash.charge_ratio," input=",Input.is_action_pressed("ability")," position=",app.world.player.position," dead=",app.world.deaths," last_launch=",dash.last_force," focus=",DisplayServer.window_is_focused())
	check(dash.charge_ratio==1 and app.audio.charge_hum.pitch_scale>=high_pitch,"native charge reaches its cap and intensifies the cue")
	await key(KEY_I,true);await key(KEY_C,false)
	check(dash.last_force>1000 and dash.direction==Vector2.UP,"IJKL aim launches upward on keyboard release")
	check(not app.audio.charge_hum.playing,"release stops the charge hum")
	await key(KEY_I,false);await key(KEY_ESCAPE,true);await key(KEY_ESCAPE,false)
	check(app.screen=="lab_menu" and app.lab_panel.visible,"Escape opens the native tuning panel")
	await click(Vector2(354,620));check(app.screen=="controls","lab controls button opens rebindings")
	await click(Vector2(492,454));await key(KEY_V,true);await key(KEY_V,false)
	check(YBControls.labels(app.store.data.settings.bindings,"ability")=="V","native binding capture replaces Shift/C with V")
	await click(Vector2(1144,80));await frames(2);await click(Vector2(178,190));await frames(4)
	await key(KEY_C,true);await frames(5);check(not dash.charging,"old keyboard dash binding no longer triggers the ability");await key(KEY_C,false)
	await key(KEY_V,true);await frames(8);check(dash.charging,"new keyboard dash binding controls actual gameplay");await key(KEY_V,false)
	await key(KEY_ESCAPE,true);await key(KEY_ESCAPE,false)
	app.lab_panel.update_value("charge_duration",.7)
	# Exercise the dialog and selection callback inside Godot for automation;
	# an OS-modal save panel must be dismissed by an actual OS selection.
	var native_default=app.lab_panel.export_dialog.use_native_dialog
	app.lab_panel.export_dialog.use_native_dialog=false
	app.lab_panel.export_profile();await frames(4)
	check(native_default and app.lab_panel.export_dialog.visible and app.lab_panel.export_dialog.current_file=="yearbound-charge-dash.json","profile dialog opens with the correct filename; production uses the native dialog")
	var path=OS.get_environment("YEARBOUND_SAVE_DIR").path_join("native-dash-profile.json")
	app.lab_panel.export_dialog.hide();app.lab_panel.export_dialog.file_selected.emit(path);await frames(3)
	var exported=JSON.parse_string(FileAccess.get_file_as_string(path))
	check(exported is Dictionary and exported.mechanic=="charge_dash" and exported.values.charge_duration==.7,"export selection writes the complete tuning profile")
	app.lab_panel.reset_defaults();app.activate("controls_reset")
	app.lab_station(16);await frames(2);app.pause_game();await frames(5)
	check(app.lab_panel.stations_scroll.scroll_vertical>0,"station list scrolls to the selected extended course")
	var last=app.lab_panel.station_buttons[16]
	await click(last.get_global_rect().get_center())
	check(app.screen=="playing" and app.world.checkpoint_index==16,"the last extended station can be selected with the mouse")
	app.activate("title");app.change_screen("calendar");await frames(3)
	await click(Vector2(1128,659));check(app.selected=="05-24","calendar's second shortcut row selects the May sample")
	await click(Vector2(996,499));await frames(3)
	check(app.screen=="playing" and app.world.spec.id=="05-24" and app.world.player.ability.tuning.horizontal_force==1.5,"calendar launches a new monthly sample with original charge dash settings plus horizontal 1.5")
	root.remove_child(app);app.queue_free();await frames(3)
	print("DASH INTERACTION TEST COMPLETE: ",failures," failures");quit(1 if failures else 0)
