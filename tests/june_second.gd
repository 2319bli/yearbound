extends SceneTree
var failures=0
func _initialize() -> void: call_deferred("run")
func frames(n: int) -> void:
	for i in n: await physics_frame
func check(ok: bool, text: String) -> void:
	if ok: print("PASS: ",text)
	else: failures+=1;push_error(text)
func run() -> void:
	var app=load("res://main.tscn").instantiate();root.add_child(app);await frames(3)
	var keys={};var music={};var types={};var plates={}
	for day in range(9,18):
		var id="06-%02d"%day;var s=app.stages[id];app.start_stage(id);await frames(5)
		keys[s.identity.key]=true;music[s.music]=true
		var signature=[]
		for d in s.decorations:
			if d.type not in signature: signature.append(d.type)
		signature.sort();types[str(signature)]=true
		check(app.world.player.is_on_floor() and app.world.deaths==0,id+" has a safe playable start")
		check(app.audio.current==s.music and app.audio.music.stream is AudioStreamMP3 and app.audio.music.stream.get_length()>210,id+" loads the supplied complete MP3")
		check(s.ambience.june_scene==s.identity.key and YBJuneScenery.scenes.has(s.identity.key),id+" selects its own scene composition")
		var plate=YBJuneScenery.scenes[s.identity.key].plate
		plates[plate]=true
		check(plate=="res://art/june/"+id+".png" and load(plate) is Texture2D,id+" loads its dedicated original landscape")
		var doc=YBLayoutDocument.new();doc.load_stage(s);var compiled=doc.compile()
		check(YBLayoutDocument.errors(compiled,true).is_empty(),id+" validates for workshop editing")
		check(YBLayoutDocument.same(compiled.decorations,s.decorations) and compiled.identity==s.identity and compiled.ambience==s.ambience,id+" workshop retains landmarks, identity and layered scene")
		var path=OS.get_environment("YEARBOUND_SAVE_DIR").path_join(id+"-roundtrip.json")
		check(YBLayoutDocument.write_layout(path,compiled)==OK,id+" exports decorated layout")
		var restored=YBLayoutDocument.read_layout(path)
		check(restored.has("stage") and YBLayoutDocument.same(restored.stage,compiled),id+" reopens without losing stage data")
		for cp in s.checkpoints:
			app.world.player.reset_at(Vector2(cp[0],cp[1]));await frames(5)
			check(app.world.player.is_on_floor() and app.world.deaths==0,id+" checkpoint remains safe")
	check(keys.size()==9 and music.size()==9 and types.size()==9 and plates.size()==9,"nine different scenes, landscape plates, soundtracks and landmark combinations")
	check(app.stage_order.slice(0,17)==Array(range(1,18)).map(func(day): return "06-%02d"%day),"calendar progression covers 1–17 June in order")
	check(app.stages.size()==41,"41 playable days retain every existing monthly sample")
	check(YBLayoutDocument.blank().id=="07-01","new workshop layouts choose the next unfinished date")
	app.open_editor();await frames(3)
	check(app.editor.sample_ids.size()==41 and app.editor.fields.music.item_count==41,"workshop discovers all 41 samples and tracks")
	var bad=app.stages["06-09"].duplicate(true);bad.ambience.june_scene="missing"
	check(not YBLayoutDocument.errors(bad).is_empty(),"invalid new scene identifiers are rejected")
	root.remove_child(app);app.queue_free();await frames(3)
	print("JUNE SECOND TEST COMPLETE: ",failures," failures");quit(1 if failures else 0)
