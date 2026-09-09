extends SceneTree
var failures=0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	if ok: print("PASS: ",message)
	else: failures+=1;push_error(message)
func run() -> void:
	var app=load("res://main.tscn").instantiate();root.add_child(app);await process_frame
	var identities=[];var art=[];var music=[]
	for day in range(2,9):
		var id="06-%02d" % day;var s: Dictionary=app.stages[id]
		identities.append(s.identity.key);art.append(s.background);music.append(s.music)
		app.start_stage(id);await physics_frame
		check(app.audio.current==s.music and app.audio.music.stream is AudioStreamMP3 and app.audio.music.stream.get_length()>200,id+" loads its supplied full-length MP3")
		check(app.world.spec.background==s.background and ResourceLoader.exists(s.background),id+" loads its own landscape")
		var doc=YBLayoutDocument.new();doc.load_stage(s);var compiled=doc.compile()
		check(compiled.decorations==s.decorations and compiled.identity==s.identity and compiled.ambience==s.ambience and compiled.background==s.background and compiled.music==s.music,id+" workshop preserves decoration, identity, art, atmosphere and music")
		var path=OS.get_environment("YEARBOUND_SAVE_DIR").path_join(id+"-roundtrip.json")
		check(YBLayoutDocument.write_layout(path,compiled)==OK,id+" writes through the workshop exporter")
		var recovered=YBLayoutDocument.read_layout(path)
		check(recovered.has("stage") and YBLayoutDocument.same(recovered.stage,compiled),id+" decorated layout survives file export and import")
	check(count_unique(identities)==7 and count_unique(art)==7 and count_unique(music)==7,"seven distinct identities, backgrounds and music resources")
	check(app.stage_order.slice(0,8)==["06-01","06-02","06-03","06-04","06-05","06-06","06-07","06-08"],"campaign follows the first eight June dates in sequence")
	app.open_editor();await process_frame
	check(app.editor.sample_ids.size()==app.stages.size() and app.editor.fields.music.item_count==app.stages.size(),"every installed day and track appears in the workshop")
	var broken=app.stages["06-02"].duplicate(true);broken.ambience.separation="bad"
	check(not YBLayoutDocument.errors(broken).is_empty(),"malformed atmosphere metadata is rejected before drawing")
	root.remove_child(app);app.queue_free();await process_frame;await process_frame
	print("JUNE WEEK TEST COMPLETE: ",failures," failures");call_deferred("quit",1 if failures else 0)
func count_unique(values: Array) -> int:
	var seen={}
	for value in values: seen[value]=true
	return seen.size()
