extends SceneTree
var failures=0
const NEW_DAYS=["07-16","08-23","09-14","11-19","12-08","02-17","04-11","05-24"]
func _initialize() -> void: call_deferred("run")
func frames(n: int) -> void:
	for i in n: await physics_frame
func check(ok: bool, message: String) -> void:
	if ok: print("PASS: ",message)
	else: failures+=1;push_error(message)
func run() -> void:
	var store=YBSave.new();store.data.settings.dash_tuning={"horizontal_force":2.0,"maximum_force":2100,"charge_duration":.1,"air_launches":0};store.data["dash_profile_revision"]=1
	store.data.last_stage="05-24";store.data.results={"06-01":{"complete":true}};store.data["run"]={"id":"05-24","checkpoint_index":1};store.data.settings.music=.35
	store.data.settings.bindings={"ability":[{"kind":"key","code":KEY_V}]};store.persist()
	var migrated=YBSave.new()
	check(migrated.data.settings.dash_tuning.is_empty() and migrated.data.dash_profile_revision==2,"saved custom tuning resets to the original profile with horizontal 1.5")
	check(migrated.data.last_stage=="05-24" and YBLayoutDocument.same(migrated.data.results,store.data.results) and YBLayoutDocument.same(migrated.data.run,store.data.run),"reset preserves campaign progress and checkpoints")
	check(YBLayoutDocument.same(migrated.data.settings.bindings,store.data.settings.bindings) and is_equal_approx(migrated.data.settings.music,.35),"reset preserves bindings and unrelated settings")
	check(YBSave.new().data.settings.dash_tuning.is_empty(),"default reset is persisted immediately")
	migrated.data.settings.dash_tuning={"horizontal_force":1.25};migrated.persist()
	check(YBSave.new().data.settings.dash_tuning.horizontal_force==1.25,"future lab adjustments survive subsequent launches")
	migrated.data.settings.dash_tuning={};migrated.data.settings.bindings={};migrated.persist()
	var app=load("res://main.tscn").instantiate();root.add_child(app);await frames(3)
	var months={};var music={};var identities={}
	check(YBChargeDashTuning.profile().horizontal_force==1.5,"the sole changed default is horizontal multiplier 1.5")
	for id in app.stage_order:
		months[id.substr(0,2)]=true;app.start_stage(id);await frames(5)
		check(app.world.player.ability is YBChargeDash and app.world.player.ability.tuning.values()==YBChargeDashTuning.profile().values(),id+" uses the original profile with only horizontal 1.5")
		check((app.world.player.is_on_floor() or app.world.player.swimming.submerged) and app.world.deaths==0,id+" has a safe start")
		if id in NEW_DAYS:
			var spec=app.world.spec;music[spec.music]=true;identities[spec.identity.key]=true
			check(ResourceLoader.exists(spec.music) and app.audio.music.stream.get_length()>25,id+" loads its own score sketch")
			var doc=YBLayoutDocument.new();doc.load_stage(spec)
			var compiled=doc.compile()
			check(YBLayoutDocument.errors(compiled,true).is_empty() and compiled.ambience==spec.ambience and compiled.abilities==spec.abilities,id+" survives workshop round-trip with scenery and dash")
			for checkpoint in spec.checkpoints:
				app.world.player.reset_at(Vector2(checkpoint[0],checkpoint[1]));await frames(5)
				check((app.world.player.is_on_floor() or app.world.player.swimming.submerged) and app.world.deaths==0,id+" checkpoint is safe and clear")
	check(months.size()==12 and app.stage_order.size()==41,"41 playable days cover all twelve months")
	check(music.size()==8 and identities.size()==8,"new samples each have an independent identity and music reference")
	app.save_run();var before=app.store.data.duplicate(true);app.start_lab();await frames(3)
	check(app.world.spec.length==44160 and app.world.spec.lab_stations.size()==17,"lab has more than doubled with six extended courses")
	for i in range(11,17):
		app.lab_station(i);await frames(5)
		check((app.world.player.is_on_floor() or app.world.player.swimming.submerged) and app.world.deaths==0,"extended station "+str(i+1)+" has a safe start")
	app.save_run();check(app.store.data==before,"extended lab keeps campaign progress separate")
	root.remove_child(app);app.queue_free();await frames(3)
	print("YEAR ROUND TEST COMPLETE: ",failures," failures");quit(1 if failures else 0)
