extends SceneTree
var failures=0
func _initialize() -> void:call_deferred("run")
func frames(n: int) -> void:
	for i in n:await physics_frame
func check(ok: bool, message: String) -> void:
	if ok:print("PASS: ",message)
	else:failures+=1;push_error(message)
func run() -> void:
	var app=load("res://main.tscn").instantiate();root.add_child(app);await frames(3)
	var identities={}
	for id in app.stage_order:
		app.start_stage(id);await frames(5);var w=app.world;var s=w.spec
		check(w.deaths==0 and (w.player.is_on_floor() or w.player.swimming.submerged),id+" starts safely")
		check(not identities.has(s.design.identity),id+" has its own gameplay identity");identities[s.design.identity]=true
		check(s.hazards.filter(func(h):return h.type=="bramble").size()>=50,id+" retains at least 50 actual spike placements")
		var doc=YBLayoutDocument.new();doc.load_stage(s);var compiled=doc.compile()
		check(YBLayoutDocument.errors(compiled,true).is_empty(),id+" compiles for workshop playtesting")
		check(compiled.design==s.design and compiled.zones==s.zones and compiled.hazards==s.hazards,id+" round-trips environment timing and design metadata")
		check(compiled.platforms.filter(func(p):return p.has("motion_path")).size()==s.platforms.filter(func(p):return p.has("motion_path")).size(),id+" keeps its moving-platform tracks in the workshop")
		Input.action_press("right");await frames(150);Input.action_release("right")
		check(w.deaths>0 or w.player.position.x<750,id+" requires a gameplay decision in the first screen")
		app.start_stage(id);await frames(3);w=app.world
		for cp in s.checkpoints:
			w.player.reset_at(Vector2(cp[0],cp[1]));await frames(4)
			check(w.deaths==0 and (w.player.is_on_floor() or w.player.swimming.submerged),id+" checkpoint is safe at "+str(cp))
		var high=s.challenge.route[0].at
		for node in s.challenge.route:
			if node.at[1]<high[1]:high=node.at
		w.boss_active=false;w.player.reset_at(Vector2(high[0],high[1]));w.player.active=false;await frames(35)
		check(absf(w.camera_y-minf(0,float(high[1])-430))<110,id+" camera follows its highest route")
		w.restore({"layout_revision":-1,"checkpoint_index":3,"collected":[0],"boss_time":70});await frames(2)
		check(w.checkpoint_index==-1 and w.checkpoint==Vector2(s.spawn[0],s.spawn[1]) and w.collected.is_empty(),id+" old layout resumes at the new entrance without stale collectibles")
	root.remove_child(app);app.queue_free();await frames(3)
	print("AUTHORED CAMPAIGN TEST COMPLETE: ",failures," failures");quit(1 if failures else 0)
