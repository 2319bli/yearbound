extends SceneTree
## Structural/runtime integration only. No traversal, route search or survivability test.
var failures=0
func _initialize() -> void:call_deferred("run")
func frames(count: int) -> void:
	for i in count:await process_frame
func check(ok: bool,message: String) -> void:
	if not ok:failures+=1;push_error(message)
func run() -> void:
	var app=load("res://main.tscn").instantiate();root.add_child(app);await frames(3)
	check(app.stage_order.size()==51 and app.challenge_order.size()==132 and app.stages.size()==183,"51 calendar days plus 132 monthly stages")
	var months={};var families={}
	for id in app.stage_order+app.challenge_order:
		var s: Dictionary=app.stages[id]
		check(s.difficulty.get("reachability_tested",false),id+" carries the current route-verification metadata")
		var problems=YBLayoutDocument.errors(s,false)
		check(problems.is_empty(),id+" validates: "+str(problems))
		var doc=YBLayoutDocument.new();doc.load_stage(s);var compiled=doc.compile()
		check(compiled.hazards==s.hazards and compiled.scenery==s.scenery and compiled.journey_regions==s.journey_regions,id+" retains hazards and scenery through workshop compilation")
		var seen={}
		for h in s.hazards:
			if h.type!="mechanism":continue
			check(not seen.has(h.id),id+" has a duplicate mechanism ID");seen[h.id]=true;families[h.mechanism]=h
		if id in app.challenge_order:
			var month=int(s.monthly_challenge.month);months[month]=months.get(month,0)+1
			check(s.journey_regions.size()==4,id+" has four named places")
			check(ResourceLoader.exists(s.music),id+" has an imported score")
		# Only instantiate and pause. No player movement is submitted.
		app.start_stage(id);app.world.set_running(false);await frames(1)
		check(app.world.spec.id==id and app.world.player.ability is YBChargeDash,id+" loads with the existing charge dash")
		if id.begins_with("11"):
			check(not app.world.player.swimming.volumes.is_empty(),id+" creates physical swimming volumes")
		if int(s.get("monthly_challenge",{}).get("number",0))==11:print("Loaded month ",id.substr(0,2)," · 11 challenges")
	check(months.size()==12 and months.values().all(func(count):return count==11),"all twelve months contain eleven additions")
	for kind in families:
		var h: Dictionary=families[kind].duplicate(true);h.phase=0
		if kind not in ["windmill","pendulum"]:
			check(YBObstacles.parts(h,float(h.safe_seconds)*.5).is_empty(),kind+" open interval has no hitbox")
			check(YBObstacles.parts(h,float(h.safe_seconds)+float(h.warning_seconds)*.5).is_empty(),kind+" warning interval has no hitbox")
		var at=.4 if kind in ["windmill","pendulum"] else float(h.safe_seconds)+float(h.warning_seconds)+.15
		check(not YBObstacles.parts(h,at).is_empty(),kind+" active interval supplies geometry")
	app.selected="06-X01";app.activate("challenges");await frames(2)
	check(app.screen=="challenges" and app.buttons.any(func(b):return b.id=="day:06-X11"),"monthly browser exposes all eleven cards")
	app.change_month(1);check(app.selected=="07-X01","month navigation selects the next collection")
	app.activate("play");app.world.set_running(false);await frames(1)
	check(app.world.spec.id=="07-X01","challenge browser launches selected content")
	app.save_run();var saved=app.world.snapshot();app.start_stage("07-X01",true);app.world.set_running(false)
	check(app.world.snapshot().id==saved.id,"challenge run restores using its own save ID")
	app.activate("next_stage");app.world.set_running(false);check(app.world.spec.id=="07-X02","next challenge stays in challenge order")
	app.activate("calendar");check(app.screen=="calendar" and app.selected in app.stage_order,"calendar navigation returns to a real date")
	app.open_editor();await frames(2)
	check(app.editor.sample_ids.size()==183,"workshop can copy all stages")
	app.editor.document.load_stage(app.stages["11-X11"]);app.editor.sync_fields()
	await frames(3)
	check(app.editor.fields.day.disabled and app.editor.fields.month.disabled,"challenge identity remains stable in workshop")
	var path=OS.get_environment("YEARBOUND_SAVE_DIR").path_join("challenge-roundtrip.json")
	check(app.editor.save_to(path),"challenge layout export succeeds")
	var loaded=YBLayoutDocument.read_layout(path)
	check(loaded.has("stage") and loaded.stage.id=="11-X11" and loaded.stage.scenery.renderer=="composition","challenge file reopens with scenery")
	app.editor.document.load_stage(YBLayoutDocument.blank());app.editor.sync_fields()
	check(not app.editor.fields.day.disabled and not app.editor.fields.month.disabled,"calendar date controls return for an ordinary layout")
	app.start_lab();app.world.set_running(false)
	check(app.lab_test and app.world.spec.length==44160,"17-station lab remains available")
	root.remove_child(app);app.queue_free();await frames(2)
	print("CHALLENGE CONTENT: ",failures," failures. Structural integration checks complete.")
	quit(1 if failures else 0)
