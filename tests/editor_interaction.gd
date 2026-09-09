extends SceneTree
var failures=0
func _initialize() -> void: call_deferred("run")
func frames(n: int) -> void:
	for i in n: await process_frame
func check(ok: bool, message: String) -> void:
	if ok: print("PASS: ",message)
	else: failures+=1;push_error(message)
func mouse(at: Vector2, pressed: bool, button: int=MOUSE_BUTTON_LEFT) -> void:
	Input.warp_mouse(at);await frames(2)
	var motion=InputEventMouseMotion.new();motion.position=at;motion.global_position=at;root.push_input(motion,true)
	var event=InputEventMouseButton.new();event.position=at;event.global_position=at;event.button_index=button;event.pressed=pressed;root.push_input(event,true);await frames(2)
func click(at: Vector2) -> void:
	await mouse(at,true);await mouse(at,false)
func key(code: Key, command: bool=false) -> void:
	var event=InputEventKey.new();event.keycode=code;event.physical_keycode=code;event.pressed=true;event.meta_pressed=command
	root.push_input(event,true);await frames(2)
	event=event.duplicate();event.pressed=false;root.push_input(event,true);await frames(2)
func run() -> void:
	var app=load("res://main.tscn").instantiate();root.add_child(app);await frames(6);app.transition=0
	await click(Vector2(370,600));check(app.screen=="editor","title workshop button responds to a real mouse event")
	if app.screen!="editor": quit(1);return
	var editor=app.editor;editor.document.load_stage(YBLayoutDocument.blank());editor.sync_fields();await frames(4)
	await click(Vector2(190,179));check(editor.tool=="stone","block palette changes the active brush")
	await click(Vector2(582,476));check(editor.document.cells.has("10:10"),"canvas click paints the cell under the cursor")
	await key(KEY_Z,true);check(not editor.document.cells.has("10:10"),"Command-Z undoes canvas painting")
	await click(Vector2(880,38));check(editor.document.cells.has("10:10"),"Redo toolbar restores the painted cell")
	await mouse(Vector2(582,476),true,MOUSE_BUTTON_RIGHT);await mouse(Vector2(582,476),false,MOUSE_BUTTON_RIGHT)
	check(not editor.document.cells.has("10:10"),"right-click erases the targeted tile")
	await click(Vector2(458,151));check(editor.rectangle_mode,"rectangle toolbar changes the drawing mode")
	await mouse(Vector2(582,476),true);await mouse(Vector2(668,505),false)
	check(editor.document.cells.has("10:10") and editor.document.cells.has("13:11"),"rectangle drag paints both endpoints and their interior")
	await click(Vector2(320,151))
	await mouse(Vector2(582,476),true);await mouse(Vector2(400,115),false)
	check(not editor.stroke,"releasing over a text control ends the paint stroke")
	await click(Vector2(1000,38));check(app.editor_test and app.screen=="playing","Playtest toolbar enters the running game")
	await key(KEY_ESCAPE);check(app.screen=="editor" and editor.visible,"Escape returns directly to the workshop")
	check(editor.document.cells.has("13:11"),"painted layout survives the playtest round trip")
	root.remove_child(app);app.queue_free();await frames(3)
	print("EDITOR INTERACTION TEST COMPLETE: ",failures," failures");quit(1 if failures else 0)
