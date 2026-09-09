class_name YBLayoutEditor
extends Node2D

const CANVAS=Rect2(280,174,980,440)
const MAP=Rect2(280,636,980,34)
const TOOLS=[
 ["ground","Grass"],["stone","Stone"],["wood","Timber"],["hay","Hay"],["log","Log"],["ice","Ice"],["spring","Spring"],["crumble","Crumble"],["lift_x","Lift ↔"],["lift_y","Lift ↕"],
 ["spawn","Start"],["goal","Exit"],["checkpoint","Lantern"],["mote","Sunmote"],["spikes","Spikes"],["erase","Eraser"],["tree","Tree"],["flowers","Flowers"],["wind","Wind →"],["updraft","Updraft ↑"],["current","Current →"]]
var sample_ids: Array=[]
const SEASON_NAMES=["Early summer","High summer","Storm","Autumn","Winter","Spring"]
var host: Node2D
var document=YBLayoutDocument.new()
var tool="ground"
var rectangle_mode=false
var view=Vector2.ZERO
var zoom=0.6
var cursor=Vector2i(-1,-1)
var stroke=false
var erasing=false
var panning=false
var rectangle_start=Vector2i.ZERO
var last_cell=Vector2i.ZERO
var buttons: Array[Dictionary]=[]
var canvas: Node2D
var fields: Dictionary={}
var syncing=false
var saved_revision=-1
var autosave_clock=0.0
var current_path=""
var folder=""
var status="Paint your first blocks. Drafts save automatically."
var status_error=false
var file_dialog: FileDialog
var message_dialog: AcceptDialog
var sample_menu: OptionButton

func _ready() -> void:
	texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	folder=host.store.PATH.get_base_dir().path_join("layouts")
	DirAccess.make_dir_recursive_absolute(folder)
	sample_ids=host.stage_order.duplicate()
	build_controls()
	var clipped=Control.new();clipped.position=CANVAS.position;clipped.size=CANVAS.size;clipped.clip_contents=true;clipped.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(clipped)
	canvas=Node2D.new();canvas.set_script(load("res://scripts/overlay.gd"));canvas.host=self;canvas.draw_method="draw_canvas";clipped.add_child(canvas)
	file_dialog=FileDialog.new();file_dialog.access=FileDialog.ACCESS_FILESYSTEM;file_dialog.use_native_dialog=true;file_dialog.filters=PackedStringArray(["*.json ; Yearbound layout"]);add_child(file_dialog)
	file_dialog.file_selected.connect(func(path):
		if file_dialog.file_mode==FileDialog.FILE_MODE_SAVE_FILE: save_to(path)
		else: open_path(path))
	message_dialog=AcceptDialog.new();message_dialog.title="Yearbound workshop";add_child(message_dialog)
	var recovered=YBLayoutDocument.read_layout(folder.path_join("workshop-draft.json"))
	if recovered.has("stage"):
		document.load_stage(recovered.stage);status="Recovered your last workshop draft. Save layout to export a shareable file."
	else: document.load_stage(JSON.parse_string(FileAccess.get_file_as_string("res://content/workshop_starter.json")))
	sync_fields()
func field_label(text: String, at: Vector2) -> void: host.label(self,text,at,11,host.MUTED)
func style_control(control: Control) -> void:
	control.add_theme_font_override("font",host.font);control.add_theme_font_size_override("font_size",14)
	control.add_theme_color_override("font_color",host.CREAM)
	for state in ["normal","focus","hover","pressed"]:
		var box=YBWorld.box(Color("29474b") if state=="normal" else Color("3b5c5d"),5)
		box.content_margin_left=10;box.content_margin_right=10;control.add_theme_stylebox_override(state,box)
	add_child(control)
func build_controls() -> void:
	var title=LineEdit.new();title.position=Vector2(280,98);title.size=Vector2(282,32);title.max_length=80;style_control(title);fields.title=title
	title.text_changed.connect(func(value): if not syncing: edit_metadata("title",value))
	var month=OptionButton.new();month.position=Vector2(574,98);month.size=Vector2(116,32)
	for m in host.calendar.months: month.add_item(m.name,int(m.number))
	style_control(month);fields.month=month
	month.item_selected.connect(func(_index): if not syncing: update_date())
	var day=OptionButton.new();day.position=Vector2(698,98);day.size=Vector2(58,32);style_control(day);fields.day=day
	day.item_selected.connect(func(_index): if not syncing: update_date())
	var season=OptionButton.new();season.position=Vector2(768,98);season.size=Vector2(160,32)
	for name in SEASON_NAMES: season.add_item(name)
	style_control(season);fields.season=season
	season.item_selected.connect(func(index):
		if syncing: return
		document.begin_edit();document.stage.season=YBLayoutDocument.SEASONS[index];document.stage.terrain_style=document.stage.season
		document.stage.erase("background");document.stage.erase("decoration_profile");document.stage.erase("ambience")
		for prop in document.stage.decorations:
			if prop.type=="tree": prop.season=document.stage.season
		document.end_edit();sync_fields())
	var length=SpinBox.new();length.position=Vector2(940,98);length.size=Vector2(112,32);length.min_value=27;length.max_value=1024;length.step=1;length.suffix="blocks";style_control(length);fields.length=length
	length.value_changed.connect(func(value):
		if syncing: return
		var problem=document.resize_columns(int(value))
		if not problem.is_empty(): say(problem,true)
		sync_fields();clamp_view())
	var music=OptionButton.new();music.position=Vector2(1064,98);music.size=Vector2(196,32)
	music.fit_to_longest_item=false;music.clip_text=true
	for id in sample_ids: music.add_item(host.date_label(id)+" · "+host.stages[id].title.left(18))
	style_control(music);fields.music=music
	music.get_popup().max_size=Vector2i(650,480)
	music.item_selected.connect(func(index): if not syncing: edit_metadata("music",host.stages[sample_ids[index]].music))
	sample_menu=OptionButton.new();sample_menu.position=Vector2(24,96);sample_menu.size=Vector2(232,32);sample_menu.add_item("Copy a sample day…")
	for id in sample_ids: sample_menu.add_item(host.date_label(id))
	style_control(sample_menu)
	sample_menu.get_popup().max_size=Vector2i(450,480)
	sample_menu.item_selected.connect(func(index):
		if index==0: return
		if archive_current():
			document.load_stage(host.stages[sample_ids[index-1]]);current_path="";view=Vector2.ZERO;sync_fields();say("Editing a copy. The original sample day stays intact.")
		sample_menu.select(0))
func update_date() -> void:
	var month=fields.month.get_selected_id();var day=fields.day.get_selected_id()
	var count=31
	if month in [4,6,9,11]: count=30
	elif month==2: count=28
	edit_metadata("id","%02d-%02d" % [month,clampi(day,1,count)]);sync_fields()
func sync_fields() -> void:
	syncing=true
	fields.title.text=document.stage.title
	fields.month.select(fields.month.get_item_index(int(document.stage.id.substr(0,2))))
	var month=int(document.stage.id.substr(0,2));var count=28 if month==2 else (30 if month in [4,6,9,11] else 31)
	fields.day.clear()
	for day in range(1,count+1): fields.day.add_item(str(day),day)
	fields.day.select(int(document.stage.id.substr(3,2))-1)
	fields.season.select(YBLayoutDocument.SEASONS.find(document.stage.season));fields.length.value=document.columns()
	for i in sample_ids.size():
		if host.stages[sample_ids[i]].music==document.stage.music: fields.music.select(i)
	syncing=false;queue_redraw()
func edit_metadata(field: String, value: Variant) -> void:
	document.begin_edit();document.stage[field]=value;document.end_edit()
func say(message: String, error: bool=false) -> void:
	status=message;status_error=error;queue_redraw()
func show_message(message: String) -> void:
	message_dialog.dialog_text=message;message_dialog.popup_centered(Vector2i(670,300))
func flush_draft() -> bool:
	if document.stage.is_empty(): return true
	if stroke: finish_stroke()
	var code=YBLayoutDocument.write_layout(folder.path_join("workshop-draft.json"),document.compile())
	if code!=OK: say("Draft could not be saved. Use Save layout to choose another folder.",true);return false
	saved_revision=document.revision;return true
func archive_current() -> bool:
	if not flush_draft(): return false
	var stamp=Time.get_datetime_string_from_system().replace(":","-")+"-"+str(Time.get_ticks_msec())
	var code=YBLayoutDocument.write_layout(folder.path_join(document.stage.id+"-draft-"+stamp+".json"),document.compile())
	if code!=OK: say("Could not archive this draft. Save it before starting another.",true);return false
	return true
func open_path(path: String) -> bool:
	var result=YBLayoutDocument.read_layout(path)
	if result.has("error"): say(result.error,true);show_message(result.error);return false
	if not archive_current(): return false
	document.load_stage(result.stage);current_path=path;view=Vector2.ZERO;sync_fields();say("Opened "+path.get_file());flush_draft();return true
func save_to(path: String) -> bool:
	if not path.to_lower().ends_with(".json"): path+=".json"
	var code=YBLayoutDocument.write_layout(path,document.compile())
	if code!=OK: say("Could not save this file (error "+str(code)+"). Choose another location.",true);return false
	current_path=path;flush_draft();say("Saved "+path.get_file()+" — share this JSON to add the day to Yearbound.");return true
func choose_file(save: bool) -> void:
	finish_stroke()
	file_dialog.file_mode=FileDialog.FILE_MODE_SAVE_FILE if save else FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.current_dir=ProjectSettings.globalize_path(folder)
	if save: file_dialog.current_file=document.stage.id+"-"+document.stage.title.to_lower().validate_filename().replace(" ","-")+".yearbound.json"
	file_dialog.popup_centered(Vector2i(900,600))
func playtest() -> bool:
	finish_stroke()
	var data=document.compile();var problems=YBLayoutDocument.errors(data,true)
	if not problems.is_empty():
		show_message("Before playtesting:\n\n"+"\n".join(problems.slice(0,6)));say(problems[0],true);return false
	flush_draft();host.start_editor_test(data);return true
func home() -> void:
	if flush_draft(): host.leave_editor()
func _process(dt: float) -> void:
	if not visible: return
	autosave_clock+=dt
	if autosave_clock>1.2 and not stroke:
		autosave_clock=0
		if saved_revision!=document.revision: flush_draft()
	queue_redraw();canvas.queue_redraw()
func canvas_cell(at: Vector2) -> Vector2i: return Vector2i((((at-CANVAS.position)/zoom+view)/48.0).floor())
func clamp_view() -> void:
	view.x=clampf(view.x,0,maxf(0,float(document.stage.length)-CANVAS.size.x/zoom))
	view.y=clampf(view.y,0,maxf(0,720-CANVAS.size.y/zoom))
func change_zoom(amount: float) -> void:
	var center=view+CANVAS.size/(2*zoom)
	zoom=clampf(zoom+amount,0.3,1.4);view=center-CANVAS.size/(2*zoom);clamp_view()
func finish_stroke() -> void:
	if stroke:
		if rectangle_mode: document.paint_rectangle(rectangle_start,cursor,"erase" if erasing else tool)
		document.end_edit()
	stroke=false;panning=false
func _notification(what: int) -> void:
	if what==NOTIFICATION_APPLICATION_FOCUS_OUT and visible: finish_stroke();flush_draft()
func _input(event: InputEvent) -> void:
	# End drags even if a text field or another Control consumes the release.
	if visible and host.screen=="editor" and event is InputEventMouseButton and not event.pressed and event.button_index in [MOUSE_BUTTON_LEFT,MOUSE_BUTTON_RIGHT,MOUSE_BUTTON_MIDDLE]:
		cursor=canvas_cell(get_viewport().get_mouse_position());finish_stroke()
func _unhandled_input(event: InputEvent) -> void:
	if not visible or host.screen!="editor": return
	if event is InputEventKey and event.pressed:
		if event.echo: return
		if event.is_command_or_control_pressed():
			match event.keycode:
				KEY_Z: finish_stroke();document.redo() if event.shift_pressed else document.undo();sync_fields()
				KEY_Y: finish_stroke();document.redo();sync_fields()
				KEY_S:
					if current_path.is_empty() or event.shift_pressed: choose_file(true)
					else: save_to(current_path)
				KEY_O: choose_file(false)
		elif event.keycode==KEY_F5: playtest()
		elif event.keycode==KEY_ESCAPE: home()
		elif event.keycode==KEY_B: rectangle_mode=false
		elif event.keycode==KEY_G: rectangle_mode=true
		elif event.keycode==KEY_E: tool="erase"
		elif event.keycode==KEY_LEFT: view.x-=144;clamp_view()
		elif event.keycode==KEY_RIGHT: view.x+=144;clamp_view()
		get_viewport().set_input_as_handled()
	if event is InputEventMouseMotion:
		var mouse=get_viewport().get_mouse_position();cursor=canvas_cell(mouse)
		if panning: view-=event.relative/zoom;clamp_view()
		elif stroke and not rectangle_mode and CANVAS.has_point(mouse):
			document.paint_line(last_cell,cursor,"erase" if erasing else tool);last_cell=cursor
	if event is InputEventMouseButton:
		var mouse=get_viewport().get_mouse_position();cursor=canvas_cell(mouse)
		if not event.pressed and event.button_index in [MOUSE_BUTTON_LEFT,MOUSE_BUTTON_RIGHT,MOUSE_BUTTON_MIDDLE]: finish_stroke();return
		if not event.pressed: return
		if event.button_index==MOUSE_BUTTON_LEFT:
			for button in buttons:
				if button.rect.has_point(mouse): action(button.id);get_viewport().set_input_as_handled();return
			if MAP.has_point(mouse): view.x=(mouse.x-MAP.position.x)/MAP.size.x*document.stage.length-CANVAS.size.x/(zoom*2);clamp_view();return
		if not CANVAS.has_point(mouse): return
		if event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:
			var direction=1 if event.button_index==MOUSE_BUTTON_WHEEL_DOWN else -1
			if event.is_command_or_control_pressed(): change_zoom(-direction*.1)
			else: view.x+=direction*144;clamp_view()
		elif event.button_index==MOUSE_BUTTON_MIDDLE or event.button_index==MOUSE_BUTTON_LEFT and Input.is_physical_key_pressed(KEY_SPACE): panning=true
		elif event.button_index in [MOUSE_BUTTON_LEFT,MOUSE_BUTTON_RIGHT]:
			stroke=true;erasing=event.button_index==MOUSE_BUTTON_RIGHT;rectangle_start=cursor;last_cell=cursor;document.begin_edit()
			if not rectangle_mode: document.paint(cursor,"erase" if erasing else tool)
		get_viewport().set_input_as_handled()
func action(id: String) -> void:
	finish_stroke()
	if id.begins_with("tool:"):
		tool=id.substr(5)
		if tool in ["spawn","goal","checkpoint"]: say("Place this marker in an empty cell directly above a stable block.")
		elif tool in ["wind","updraft","current"]: say("Paint the air above terrain. Rectangle mode makes larger wind and water zones.")
		elif tool in ["tree","flowers"]: say("Decoration stays behind the player. Click just above the ground to plant it.")
		elif tool=="erase": say("Drag to erase. Use Rectangle to clear both floor rows when making a pit.")
		else: say("Paint square blocks. A normal held jump reaches two blocks high.")
		return
	match id:
		"new":
			if archive_current(): document.load_stage(YBLayoutDocument.blank());current_path="";view=Vector2.ZERO;sync_fields();say("A new day. Your previous draft is in the layouts folder.")
		"open": choose_file(false)
		"save": choose_file(true)
		"undo": document.undo();sync_fields()
		"redo": document.redo();sync_fields()
		"test": playtest()
		"home": home()
		"brush": rectangle_mode=false
		"rect": rectangle_mode=true
		"minus": change_zoom(-.1)
		"plus": change_zoom(.1)
		"fit": zoom=.6;view=Vector2.ZERO
		"folder": OS.shell_open(ProjectSettings.globalize_path(folder))
		"help": show_message("BUILD A DAY\n\nChoose a block and drag to paint. Right-drag erases. Rectangle fills larger areas; it also works with the eraser and wind/water tools.\n\nPlace Start, Exit and Lanterns in empty cells immediately above solid terrain. Erase both ground rows to make a pit. One normal jump reaches two blocks.\n\nSpace-drag or middle-drag pans; scroll moves sideways. ⌘/Ctrl + scroll zooms. Click the overview to travel further.\n\n⌘/Ctrl Z: undo · Shift Z: redo · S: save · O: open · F5: playtest. Esc returns from a test. Drafts save locally; Save layout creates a JSON file you can share.\n\nTree/flower brushes decorate the background. Zones push right, lift up, or carry downstream. Moving blocks travel two cells. Existing sample hazards and bosses are preserved when copying a sample.")
func ui_button(id: String, text: String, rect: Rect2, active: bool=false, small: bool=false) -> void:
	var hover=rect.has_point(get_viewport().get_mouse_position())
	host.panel(self,rect,host.GOLD if active else (Color("3b5b5b") if hover else Color("29474b")),5)
	host.label(self,text,rect.position+Vector2(12,rect.size.y*.5+5),13 if small else 15,host.INK if active else host.CREAM)
	buttons.append({"id":id,"rect":rect})
func _draw() -> void:
	buttons.clear()
	draw_rect(Rect2(0,0,1280,720),Color("102b32"))
	draw_rect(Rect2(0,0,1280,72),Color("19383e"))
	host.label(self,"YEARBOUND / WORKSHOP",Vector2(24,32),12,host.GOLD)
	host.label(self,"Make a day of your own.",Vector2(24,54),18,host.CREAM)
	ui_button("new","New",Rect2(456,20,66,36));ui_button("open","Open…",Rect2(530,20,80,36));ui_button("save","Save layout…",Rect2(618,20,131,36))
	ui_button("undo","Undo",Rect2(769,20,70,36));ui_button("redo","Redo",Rect2(847,20,70,36))
	ui_button("test","▶  Playtest",Rect2(939,20,137,36),true);ui_button("home","←  Home",Rect2(1092,20,104,36));ui_button("help","?",Rect2(1208,20,52,36))
	for item in [["TITLE",Vector2(280,88)],["DATE",Vector2(574,88)],["SEASON",Vector2(768,88)],["LENGTH",Vector2(940,88)],["MUSIC SKETCH",Vector2(1064,88)]]: field_label(item[0],item[1])
	field_label("BLOCKS / 48 × 48",Vector2(24,153))
	for i in 10:
		var item=TOOLS[i];ui_button("tool:"+item[0],item[1],Rect2(24+(i%2)*119,165+(i/2)*35,113,29),tool==item[0],true)
	field_label("MARKERS & DETAILS",Vector2(24,366))
	for i in range(10,18):
		var j=i-10;var item=TOOLS[i];ui_button("tool:"+item[0],item[1],Rect2(24+(j%2)*119,378+(j/2)*35,113,29),tool==item[0],true)
	field_label("ENVIRONMENT",Vector2(24,539))
	for i in range(18,21):
		var j=i-18;var item=TOOLS[i];ui_button("tool:"+item[0],item[1],Rect2(24+(j%2)*119,551+(j/2)*35,113,29),tool==item[0],true)
	ui_button("folder","Open layouts folder",Rect2(24,637,232,33),false,true)
	host.label(self,"Local draft · "+("saved" if saved_revision==document.revision else "saving…"),Vector2(24,698),12,host.MUTED)
	ui_button("brush","Brush · B",Rect2(280,140,106,27),not rectangle_mode,true)
	ui_button("rect","Rectangle · G",Rect2(394,140,138,27),rectangle_mode,true)
	host.label(self,"Right-drag: erase   ·   Space-drag: pan",Vector2(551,159),12,host.MUTED)
	ui_button("minus","−",Rect2(992,140,36,27));ui_button("plus","+",Rect2(1035,140,36,27));ui_button("fit","Fit",Rect2(1078,140,52,27),false,true)
	host.label(self,str(roundi(zoom*100))+"%  /  "+str(document.columns())+" columns",Vector2(1140,159),11,host.MUTED)
	draw_rect(CANVAS.grow(1),Color("5a7776"),false,1)
	host.label(self,"OVERVIEW  ·  click to navigate",Vector2(280,629),10,host.MUTED)
	draw_rect(MAP,Color("0b2027"))
	for k in document.cells:
		var c=YBLayoutDocument.coord(k)
		draw_rect(Rect2(MAP.position+Vector2(float(c.x)/document.columns()*MAP.size.x,float(c.y)/15*MAP.size.y),Vector2(maxf(1,MAP.size.x/document.columns()),3)),Color("81a18c"))
	for pos in [document.stage.spawn,document.stage.goal]: draw_circle(MAP.position+Vector2(pos[0]/document.stage.length*MAP.size.x,17),3,host.GOLD)
	draw_rect(Rect2(MAP.position+Vector2(view.x/document.stage.length*MAP.size.x,0),Vector2(minf(MAP.size.x,CANVAS.size.x/zoom/document.stage.length*MAP.size.x),MAP.size.y)),host.GOLD,false,1)
	var message=status.left(117)
	host.label(self,message,Vector2(280,698),13,Color("f0ab91") if status_error else host.MUTED)
func draw_canvas(n: Node2D) -> void:
	n.draw_rect(Rect2(Vector2.ZERO,CANVAS.size),Color("183b44"))
	n.draw_set_transform(-view*zoom,0,Vector2.ONE*zoom)
	var first=maxi(0,floori(view.x/48));var last=mini(document.columns(),ceili((view.x+CANVAS.size.x/zoom)/48)+1)
	for x in range(first,last):
		if x%8<4: n.draw_rect(Rect2(x*48,0,48,720),Color(0.4,0.7,0.7,.025))
		for y in 15:
			var at=Vector2i(x,y);var k=YBLayoutDocument.key(at)
			if document.cells.has(k): YBTerrainArt.tile(n,Vector2(at)*48,document.cells[k],document.stage,not document.cells.has(YBLayoutDocument.key(at-Vector2i(0,1))) or document.cells[k].kind!="ground")
	for zone in document.stage.zones:
		var rect=Rect2(zone.x,zone.y,zone.w,zone.h)
		n.draw_rect(rect,Color(.35,.75,.88,.18));n.draw_rect(rect,Color(.5,.8,.9,.5),false,1)
		n.draw_string(host.font,rect.position+Vector2(10,28),"↑" if zone.type=="updraft" else "→",HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("b3e9e9"))
	for h in document.stage.hazards:
		if h.type=="bramble": YBTerrainArt.bramble(n,Rect2(h.x,h.y,h.w,h.h),document.stage.season)
		else: n.draw_circle(Vector2(h.x,h.y),float(h.r),Color("d08b77"));n.draw_string(host.font,Vector2(h.x-6,h.y+5),"!",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("fff2cc"))
	for d in document.stage.decorations:
		var at=Vector2(d.x,d.y)
		n.draw_line(at,at-Vector2(0,24),Color("80ad89"),3)
		n.draw_circle(at-Vector2(0,30),15 if d.type=="tree" else 7,Color(.4,.7,.5,.6))
	for point in document.stage.motes: n.draw_circle(Vector2(point[0],point[1]),5,host.GOLD)
	for field in ["spawn","goal","checkpoints"]:
		var points=document.stage.checkpoints if field=="checkpoints" else [document.stage[field]]
		for pos in points:
			var at=Vector2(pos[0],pos[1]);var tint=Color("91e5c0") if field=="spawn" else host.GOLD
			n.draw_rect(Rect2(at-Vector2(12,40),Vector2(24,40)),Color(tint,.25));n.draw_rect(Rect2(at-Vector2(12,40),Vector2(24,40)),tint,false,2)
			n.draw_string(host.font,at-Vector2(6,14),"S" if field=="spawn" else ("E" if field=="goal" else "L"),HORIZONTAL_ALIGNMENT_LEFT,-1,16,tint)
	for x in range(first,last+1): n.draw_line(Vector2(x*48,0),Vector2(x*48,720),Color(.5,.7,.7,.17),1/zoom)
	for y in 16: n.draw_line(Vector2(first*48,y*48),Vector2(last*48,y*48),Color(.5,.7,.7,.17),1/zoom)
	if CANVAS.has_point(get_viewport().get_mouse_position()) and document.inside(cursor):
		var rect=Rect2(Vector2(cursor)*48,Vector2(48,48))
		if stroke and rectangle_mode:
			rect=Rect2(Vector2(mini(cursor.x,rectangle_start.x),mini(cursor.y,rectangle_start.y))*48,Vector2(absi(cursor.x-rectangle_start.x)+1,absi(cursor.y-rectangle_start.y)+1)*48)
		n.draw_rect(rect,Color(1,.83,.5,.16));n.draw_rect(rect,host.GOLD,false,2/zoom)
	n.draw_set_transform(Vector2.ZERO)
