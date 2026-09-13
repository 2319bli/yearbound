extends SceneTree
var failures=0
func _initialize() -> void:call_deferred("run")
func frames(count: int) -> void:
	for i in count:await physics_frame
func check(ok: bool, message: String) -> void:
	if ok:print("PASS: ",message)
	else:failures+=1;push_error(message)
func run() -> void:
	var app=load("res://main.tscn").instantiate();root.add_child(app);await frames(4)
	check(app.stage_order.size()==51,"the calendar exposes the original 41 dates plus ten new stages")
	var kinds={};var new_days=["07-02","08-06","09-22","10-25","11-07","12-21","01-06","02-25","03-21","04-23"]
	for id in app.stage_order:
		var s=app.stages[id];var machines=s.hazards.filter(func(h):return h.type=="mechanism")
		check(machines.size()>=3,id+" contains actual moving or timed mechanisms")
		var ids={}
		for h in machines:
			check(YBObstacleRules.errors(h).is_empty(),id+" mechanism data validates "+str(YBObstacleRules.errors(h)))
			check(not ids.has(h.id),id+" obstacle identifiers are unique")
			ids[h.id]=true;kinds[h.mechanism]=h
		var doc=YBLayoutDocument.new();doc.load_stage(s);var compiled=doc.compile()
		check(YBLayoutDocument.errors(compiled,true).is_empty(),id+" is valid for workshop playtest "+str(YBLayoutDocument.errors(compiled,true)))
		check(compiled.hazards==s.hazards,id+" workshop round trip retains every mechanism and timing parameter")
		if id in new_days:
			check(s.journey_regions.size()==4 and s.scenery.atlas=="res://art/maps/"+id+".png",id+" has four places and its own background art")
			check(s.music=="res://audio/"+id+"_sketch.wav",id+" has a distinct temporary score")
			check(s.challenge.vertical_travel>=192,id+" requires substantial vertical movement")
	check(kinds.size()==8,"all eight mechanism families appear in the campaign")
	for kind in kinds:
		var h=kinds[kind].duplicate(true);h.x=500;h.y=350;h.phase=0
		if kind not in ["windmill","pendulum"]:
			check(YBObstacles.state(h,.2)=="open" and YBObstacles.parts(h,.2).is_empty(),kind+" open state is harmless")
			check(YBObstacles.state(h,h.safe_seconds+.2)=="warning" and YBObstacles.parts(h,h.safe_seconds+.2).is_empty(),kind+" warning is visible before it becomes lethal")
		if kind=="shutter":
			for step in 40:
				for part in YBObstacles.parts(h,step*float(h.period)/40):
					check(part.rect.position.x>=h.x and part.rect.end.x<=h.x+h.w,"shutter extension stays inside its marked gate")
		var t=1.0 if kind in ["windmill","pendulum"] else h.period-.4
		var parts=YBObstacles.parts(h,t);check(not parts.is_empty(),kind+" supplies active collision geometry")
		var part=parts[0];var center: Vector2=part.rect.get_center() if part.has("rect") else (part.center if part.has("center") else part.a.lerp(part.b,.65))
		var feet=center+Vector2(0,19)
		check(YBObstacles.touches(h,t,feet,feet),kind+" visible geometry has lethal contact")
		check(YBObstacles.touches(h,t,feet-Vector2(400,0),feet+Vector2(400,0)),kind+" cannot be skipped by a fast horizontal dash")
		check(YBObstacles.touches(h,t,feet-Vector2(0,400),feet+Vector2(0,400)),kind+" cannot be skipped by a fast vertical dash")
		check(not YBObstacles.touches(h,t,feet+Vector2(2000,2000),feet+Vector2(2100,2000)),kind+" leaves distant safe space untouched")
		app.start_stage("06-01");await frames(3);var w=app.world
		w.spec.hazards=[h];w.age=t;var deaths=w.deaths
		w.dash_hazard_sweep(feet-Vector2(400,0),feet+Vector2(400,0))
		check(w.deaths==deaths+1,kind+" is wired into the real world's swept collision")
		w.set_running(false);var age=w.age;await frames(4)
		check(w.age==age,kind+" freezes with the pause menu")
	var malformed=kinds.values()[0].duplicate(true);malformed.mechanism="missing"
	check(not YBObstacleRules.errors(malformed).is_empty(),"unknown mechanisms are rejected")
	malformed=kinds.values()[0].duplicate(true);malformed.period=0
	check(not YBObstacleRules.errors(malformed).is_empty(),"zero-length timing cycles are rejected")
	app.start_stage("11-07");await frames(5)
	check(app.world.player.swimming.submerged,"the new November stage starts physically underwater")
	root.remove_child(app);app.queue_free();await frames(3)
	print("OBSTACLE TEST COMPLETE: ",failures," failures");quit(1 if failures else 0)
