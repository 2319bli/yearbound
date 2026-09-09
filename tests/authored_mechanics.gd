extends SceneTree
var failures=0
func _initialize() -> void:call_deferred("run")
func frames(n: int) -> void:
	for i in n:await physics_frame
func check(ok: bool, message: String) -> void:
	if ok:print("PASS: ",message)
	else:failures+=1;push_error(message)
func run() -> void:
	var track={"motion_path":[[0,0],[192,0],[192,-144],[0,-144]],"motion_seconds":8}
	check(YBPlatformMotion.offset(track,0)==Vector2.ZERO and YBPlatformMotion.offset(track,2)==Vector2(192,0) and YBPlatformMotion.offset(track,4)==Vector2(192,-144),"authored tracks reach their corners at predictable times")
	check(YBPlatformMotion.offset(track,1)==Vector2(96,0) and YBPlatformMotion.offset(track,8)==Vector2.ZERO,"tracks move continuously and loop without a jump")
	var storm={"type":"storm","period":4.0,"active_seconds":.6,"warning_seconds":.9,"phase":0.0}
	check(not YBStageHazards.active(storm,1) and not YBStageHazards.warning(storm,1),"storm recovery is visibly and physically safe")
	check(YBStageHazards.warning(storm,3) and not YBStageHazards.active(storm,3),"the warning interval is safe")
	check(YBStageHazards.active(storm,3.8) and not YBStageHazards.active(storm,4.1),"lightning only hurts during its strike")
	var ice={"type":"icicle","x":100,"y":-480,"r":16,"local":true,"period":5,"warning_seconds":1.5}
	check(YBStageHazards.position(ice,1).y==-550 and YBStageHazards.position(ice,2).y>-480,"falling ice is anchored to its authored elevation")
	var app=load("res://main.tscn").instantiate();root.add_child(app);await frames(4)
	app.start_stage("06-05");await frames(3);var w=app.world
	var p=w.platforms.filter(func(v):return v.data.has("motion_path"))[0]
	w.player.reset_at(p.body.position+Vector2(p.data.w*.5,0));await frames(4);var before=w.player.position
	await frames(15);check(w.player.position.x>before.x+15 and w.player.is_on_floor(),"the track carries a standing player")
	w.set_running(false);before=p.body.position;var age=w.age;await frames(20)
	check(p.body.position==before and w.age==age,"pause freezes platform and hazard timing")
	app.start_stage("08-23");await frames(3);w=app.world
	p=w.platforms.filter(func(v):return v.data.get("track_id","")=="08-23-11")[0]
	w.age=4.95;await frames(1);w.player.reset_at(p.body.position+Vector2(p.data.w*.5,0));await frames(4)
	await frames(60)
	check(w.player.is_on_floor() and absf(w.player.position.x-p.body.position.x-p.data.w*.5)<16 and w.deaths==0,"a fast diagonal ferry carries the rider without requiring running to catch up")
	app.start_stage("10-12");await frames(3);w=app.world
	var h=w.spec.hazards.filter(func(v):return v.type=="storm")[0]
	w.age=.2;w.player.reset_at(Vector2(h.x+24,624));await frames(3)
	check(w.deaths==0,"a dark lightning lane can be crossed safely")
	w.age=h.period-h.active_seconds*.5;await frames(3)
	check(w.deaths==1,"contact with active lightning triggers a normal checkpoint retry")
	await frames(30);check(w.player.visible and w.player.position.x<200,"the retry returns to a safe entrance")
	w.age=h.period-.1;var count=w.deaths;w.dash_hazard_sweep(Vector2(h.x-40,624),Vector2(h.x+90,624))
	check(w.deaths==count+1,"a dash cannot tunnel through active lightning")
	app.start_stage("06-03");await frames(3);w=app.world
	var z=w.spec.zones.filter(func(v):return v.type=="updraft")[0]
	var start_y=z.y+z.h-100
	w.player.reset_at(Vector2(z.x+z.w*.5,start_y));await frames(30)
	check(w.player.velocity.y<0 and w.player.position.y<start_y-40,"kite thermals physically lift the player without changing dash tuning")
	root.remove_child(app);app.queue_free();await frames(3)
	print("AUTHORED MECHANICS TEST COMPLETE: ",failures," failures");quit(1 if failures else 0)
