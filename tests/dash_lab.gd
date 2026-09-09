extends SceneTree
var failures=0
func _initialize() -> void: call_deferred("run")
func frames(count: int) -> void:
	for i in count: await physics_frame
func check(ok: bool, message: String) -> void:
	if ok: print("PASS: ",message)
	else: failures+=1;push_error(message)
func run() -> void:
	var app=load("res://main.tscn").instantiate();root.add_child(app);await frames(3)
	var campaign=app.store.data.duplicate(true)
	app.start_lab();await frames(4)
	check(app.lab_test and app.world.player.ability is YBChargeDash,"dedicated lab enables the modular ability")
	var safe=YBChargeDashTuning.profile({"charge_duration":0,"minimum_force":1200,"maximum_force":-1})
	check(safe.charge_duration>0 and safe.maximum_force>=safe.minimum_force,"tuning rejects unsafe durations and inverted force ranges")
	var broken=app.stages["06-01"].duplicate(true);broken.abilities=42
	check(not YBLayoutDocument.errors(broken).is_empty(),"malformed ability metadata is rejected before world setup")
	for i in app.world.spec.lab_stations.size():
		app.lab_station(i);await frames(4)
		check(app.world.player.is_on_floor() and app.world.deaths==0,"station %02d has a safe supported start" % [i+1])
	app.save_run();check(app.store.data==campaign,"lab attempts never replace campaign progress")
	app.pause_game();await frames(2)
	check(app.screen=="lab_menu" and app.lab_panel.visible,"pause opens stations and tuning")
	app.lab_panel.update_value("charge_duration",.65)
	check(app.world.player.ability.tuning.charge_duration==.65,"lab tuning changes the live ability profile")
	var save=YBSave.new();check(save.data.settings.dash_tuning.charge_duration==.65,"tuning survives save reload")
	app.controls_return="lab_menu";app.change_screen("controls");app.activate("bind:ability:key")
	var key=InputEventKey.new();key.pressed=true;key.keycode=KEY_V;key.physical_keycode=KEY_V;root.push_input(key,true);await frames(2)
	check(app.binding_action.is_empty() and YBControls.labels(app.store.data.settings.bindings,"ability")=="V","input capture rebinds the dash from an actual key event")
	var conflict=YBControls.rebind(app.store.data.settings.bindings,"ability",false,YBControls.key(KEY_SPACE))
	check(conflict.has("error"),"binding conflicts are explicit and do not overwrite another action")
	var custom=YBControls.rebind(app.store.data.settings.bindings,"ability",true,YBControls.axis(JOY_AXIS_TRIGGER_RIGHT,1))
	check(custom.has("bindings"),"controller trigger can bind charge dash")
	YBControls.apply(custom.bindings)
	var motion=InputEventJoypadMotion.new();motion.axis=JOY_AXIS_TRIGGER_RIGHT;motion.axis_value=.8
	check(InputMap.event_is_action(motion,"ability"),"rebound analog trigger resolves to the gameplay action")
	var migrated=YBSave.new();check(YBControls.labels(migrated.data.settings.bindings,"ability")=="V","custom controls persist across reload")
	app.activate("controls_reset");app.lab_panel.reset_defaults();app.lab_station(0);await frames(3)
	app.world.win();await frames(2);check(app.screen=="lab_menu","finishing the lab returns to station selection")
	app.resume_game();await frames(3);check(app.screen=="playing" and not app.world.complete and app.world.player.active,"resume after lab completion starts a fresh attempt")
	var p=app.world.player;var dash=p.ability as YBChargeDash
	p.reset_at(Vector2(400,624));await frames(2)
	app.world.spec=app.world.spec.duplicate(true);app.world.spec.hazards=[{"type":"bramble","x":425,"y":585,"w":2,"h":39}]
	dash.tuning.minimum_force=3000;dash.tuning.maximum_force=3000;dash.tuning.maximum_launch_speed=3000
	Input.action_press("ability");await frames(2);Input.action_release("ability");await frames(3)
	check(app.world.deaths==1,"swept dash collision catches a two-pixel hazard between frames")
	check(not dash.charging and not dash.dashing,"death immediately clears dash feedback and motion")
	app.start_stage("06-01");await frames(3)
	check(app.world.player.ability is YBChargeDash and not app.lab_test,"campaign stages now enable the modular charge dash")
	root.remove_child(app);app.queue_free();await frames(3)
	print("DASH LAB TEST COMPLETE: ",failures," failures");call_deferred("quit",1 if failures else 0)
