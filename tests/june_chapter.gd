extends SceneTree
var failures=0
func _initialize() -> void:call_deferred("run")
func frames(n: int) -> void:
	for i in n:await physics_frame
func check(ok: bool, message: String) -> void:
	if ok:print("PASS: ",message)
	else:failures+=1;push_error(message)
func run() -> void:
	var app=load("res://main.tscn").instantiate();root.add_child(app);await frames(4)
	check(app.stage_order.slice(0,30)==Array(range(1,31)).map(func(day):return "06-%02d"%day),"June contains every date in chapter order")
	check(app.stage_order.size()==41,"all eleven other-month samples are retained")
	for day in range(1,31):
		var id="06-%02d"%day;var s=app.stages[id]
		check(s.journey_regions.size()==5 and s.challenge.rooms.size()==5,id+" contains five connected places")
		var places={}
		for region in s.journey_regions:places[region.place]=true
		check(places.size()>=2 or day==30,id+" changes scenery within its journey")
		check(s.challenge.spike_placements>=50,id+" has at least 50 physical spike entries")
		var doc=YBLayoutDocument.new();doc.load_stage(s);var compiled=doc.compile()
		check(YBLayoutDocument.errors(compiled,true).is_empty(),id+" supports workshop playtest")
		check(compiled.journey_regions==s.journey_regions and compiled.secret_areas==s.secret_areas,id+" preserves place and secret metadata")
	check(app.stages["06-08"].journey_regions.map(func(r):return r.light)==["afternoon","sunset","dusk","night","night"],"Lanterns progresses from afternoon to deep-blue night")
	check(app.stages["06-12"].goal[1]<-1000,"Orchard Climb carries its altitude into later places")
	check(app.stages["06-18"].secret_areas.size()>=3,"Garden Maze contains optional side chambers")
	var route=app.stages["06-18"].challenge.route;var reversals=0
	for i in range(1,route.size()):
		if route[i].at[0]<route[i-1].at[0]-100:reversals+=1
	check(reversals>=4,"Garden Maze returns along earlier space instead of only travelling right")
	check(not YBLayoutDocument.blank().has("journey_regions") and not YBLayoutDocument.blank().has("secret_areas"),"blank days do not inherit another day’s places or secrets")
	app.start_stage("06-30");await frames(4);var w=app.world;var boss=w.june_boss
	check(boss!=null and boss.phase==0 and w.boss_active,"the keeper begins in its introduction arena")
	w.set_running(false);var frozen=boss.phase_time;await frames(10);check(boss.phase_time==frozen,"pause freezes the boss phase")
	w.set_running(true)
	for i in 5:
		boss.enter(i);w.player.reset_at(w.checkpoint);await frames(3)
		var cp=w.checkpoint;var state=w.snapshot();w.restore(state);await frames(3)
		check(boss.phase==i and w.checkpoint==cp,"phase "+str(i+1)+" resumes at its own arena checkpoint")
		if i!=2:
			w.player.reset_at(Vector2(boss.data().to_x+30,624));boss.update(.016)
			check(boss.phase==i and w.player.position.x<boss.data().to_x,"an unfinished survival phase cannot be skipped through its exit")
		w.player.reset_at(cp);boss.phase_time=1.5;var deaths=w.deaths;w.die();await frames(28)
		check(w.deaths==deaths+1 and boss.phase==i and w.checkpoint==cp and boss.phase_time<1,"death preserves completed phases and restarts the current arena")
		boss.enter(i);w.player.reset_at(cp);boss.attack_clock=0;boss.update(.016)
		check(not w.projectiles.is_empty() and w.projectiles[0].delay>=.7,"phase "+str(i+1)+" telegraphs its incoming hazards")
		if i==2:
			boss.chase_time=8;var before=w.deaths;w.player.reset_at(cp);boss.update(.016);check(w.deaths==before+1,"the advancing storm enforces movement during the chase");await frames(28)
		boss.enter(i);boss.phase_time=float(boss.data().duration);boss.cleared=true;w.projectiles.clear()
		if i<4:
			w.player.reset_at(Vector2(boss.data().to_x+25,624));boss.update(.016)
			check(boss.phase==i+1,"cleared arena "+str(i+1)+" connects physically to the next")
		else:
			boss.update(.016);check(boss.defeated and w.boss_time==w.spec.boss.duration and not w.complete,"the final phase reveals an aftermath before completion")
			w.player.reset_at(Vector2(w.spec.goal[0],w.spec.goal[1]));boss.update(.016);check(w.complete,"the aftermath gate completes June")
	root.remove_child(app);app.queue_free();await frames(3)
	print("JUNE CHAPTER TEST COMPLETE: ",failures," failures");quit(1 if failures else 0)
