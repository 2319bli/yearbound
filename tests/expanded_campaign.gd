extends SceneTree
var failures=0
func _initialize() -> void: call_deferred("run")
func frames(n: int) -> void:
	for i in n: await physics_frame
func check(ok: bool, message: String) -> void:
	if ok: print("PASS: ",message)
	else: failures+=1;push_error(message)
func run() -> void:
	var app=load("res://main.tscn").instantiate();root.add_child(app);await frames(3)
	for id in app.stage_order:
		app.start_stage(id);await frames(5);var w=app.world;var s=w.spec
		check(s.length>=s.challenge.original_length*2,id+" is at least twice as long")
		check(s.hazards.filter(func(h): return h.type=="bramble").size()>=50,id+" has at least 50 independent spike placements")
		check(s.challenge.vertical_travel>=864 and s.world_top<0,id+" has substantial vertical traversal")
		check(w.deaths==0 and (w.player.is_on_floor() or w.player.swimming.submerged),id+" starts safely")
		var doc=YBLayoutDocument.new();doc.load_stage(s);var compiled=doc.compile()
		check(YBLayoutDocument.errors(compiled,true).is_empty(),id+" validates and compiles for taller workshop layouts")
		check(compiled.challenge==s.challenge and compiled.abilities==s.abilities and compiled.world_top==s.world_top,id+" editor preserves vertical route and ability metadata")
		for cp in s.checkpoints:
			w.player.reset_at(Vector2(cp[0],cp[1]));await frames(5)
			check(w.deaths==0 and (w.player.is_on_floor() or w.player.swimming.submerged),id+" has a safe checkpoint at "+str(cp))
		var high=s.challenge.rooms[3].end
		if s.has("boss"): w.boss_active=false
		w.player.reset_at(Vector2(high[0],high[1]));await frames(45)
		check(w.camera_y < -250 and w.camera.position.y<110,id+" camera follows the high route")
		w.die();await frames(30)
		check(absf(w.camera_y-clampf(w.checkpoint.y-430,s.world_top,0))<80,id+" respawn returns the vertical camera with the player")
	app.start_stage("06-30");await frames(20)
	check(not app.world.boss_active and app.world.boss_time==0,"boss timer waits while the player crosses the expanded approach")
	var b=app.world;var arena=float(b.spec.boss.arena_x)
	b.player.reset_at(Vector2(arena+96,624));await frames(5)
	check(b.boss_active and b.boss_time>0 and absf(b.camera_x-arena)<1,"boss activates in its final arena with the camera correctly offset")
	b.boss_time=35.2;b.die();await frames(30)
	check(b.boss_time>=35 and b.boss_time<36 and b.player.position.x>=arena,"boss phase and arena checkpoint survive a retry")
	b.boss_time=104.99;b.projectiles.clear();await frames(3)
	check(b.complete,"offset boss arena still completes through survival")
	app.start_stage("06-01");await frames(5);var wind_world=app.world
	wind_world.spec.zones=[{"type":"updraft","x":0,"y":-1536,"w":1000,"h":2200,"force":[0,0]}]
	Input.action_press("ability");await frames(54);Input.action_press("aim_up");Input.action_release("ability");await frames(3)
	check(wind_world.player.ability.controls_motion() and wind_world.player.velocity.y < -800,"an updraft does not clip an active charge dash to its normal float speed")
	Input.action_release("aim_up")
	app.open_editor();await frames(3);var e=app.editor;var d=e.document
	d.load_stage(YBLayoutDocument.blank());e.sync_fields()
	check("charge_dash" in d.stage.abilities,"new layouts enable charge dash by default")
	e.action("dash");check(not "charge_dash" in d.stage.abilities,"workshop toggle disables dash")
	d.undo();check("charge_dash" in d.stage.abilities,"undo restores dash availability")
	var height_index=e.fields.height.get_item_index(31);e.fields.height.select(height_index);e.fields.height.item_selected.emit(height_index)
	check(d.row_count()==31 and d.stage.editor_version==2,"height dropdown expands the canvas upward and exports the current editor format")
	d.begin_edit();d.paint(Vector2i(12,-5),"stone");d.paint(Vector2i(13,-5),"spikes_right");d.end_edit()
	var c=d.compile();check(c.platforms.any(func(p): return p.y==-240) and c.hazards.any(func(h): return h.direction=="right"),"negative-row blocks and wall spikes compile")
	check(not d.resize_height(15).is_empty(),"shrinking refuses to delete upper content")
	var path=OS.get_environment("YEARBOUND_SAVE_DIR").path_join("vertical.json")
	e.save_to(path);check(YBLayoutDocument.same(YBLayoutDocument.read_layout(path).stage,c),"export/reopen preserves dash, height and spike direction")
	e.playtest();await frames(3);check(app.world.player.ability is YBChargeDash,"workshop playtest creates the actual charge dash ability")
	Input.action_press("ability");await frames(20);check(app.world.player.ability.charge_ratio>0,"charge builds during workshop playtest")
	Input.action_press("aim_up");Input.action_release("ability");await frames(3);check(app.world.player.velocity.y < -450,"releasing launches vertically in the workshop")
	app.return_to_editor();check(not Input.is_action_pressed("aim_up") and not Input.is_action_pressed("ability"),"returning from playtest clears held aim and dash")
	root.remove_child(app);app.queue_free();await frames(3)
	print("EXPANDED CAMPAIGN TEST COMPLETE: ",failures," failures");quit(1 if failures else 0)
