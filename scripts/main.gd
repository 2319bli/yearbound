extends Node2D

const INK = Color("203f45")
const CREAM = Color("fff3d3")
const GOLD = Color("efcb82")
const MUTED = Color("a5beb5")
var store := YBSave.new()
var audio: YBAudio
var world: YBWorld
var overlay: Node2D
var background: Node2D
var font: SystemFont
var heading: SystemFont
var calendar: Dictionary
var stages: Dictionary = {}
var stage_order: Array = []
var featured_order: Array = []
var screen := "title"
var settings_return := "title"
var buttons: Array[Dictionary] = []
var focus := 0
var hovered := -1
var month_index := 0
var selected := "06-01"
var ui_time := 0.0
var transition := 1.0
var intro := 0.0
var toast := ""
var toast_time := 0.0
var closing := false
var editor: YBLayoutEditor
var editor_test := false
var lab_test=false
var lab_panel: YBDashLabPanel
var controls_return="settings"
var binding_action=""
var binding_gamepad=false
var binding_status="Choose a binding to replace it. Escape cancels capture."

func _ready() -> void:
	get_tree().auto_accept_quit = false
	DisplayServer.window_set_title("Yearbound")
	font = SystemFont.new();font.font_names = PackedStringArray(["Avenir Next","Arial"])
	heading = SystemFont.new();heading.font_names = PackedStringArray(["Georgia","Times New Roman"])
	calendar = JSON.parse_string(FileAccess.get_file_as_string("res://content/calendar.json"))
	var catalog = JSON.parse_string(FileAccess.get_file_as_string("res://content/catalog.json"))
	stage_order = catalog.stages
	featured_order = catalog.featured
	for id in catalog.stages: stages[id] = JSON.parse_string(FileAccess.get_file_as_string("res://content/stages/"+id+".json"))
	for day in calendar.days: day.available = stages.has(day.id)
	selected = store.data.last_stage if stages.has(store.data.last_stage) else "06-01"
	align_month()
	setup_inputs()
	audio = YBAudio.new();add_child(audio);audio.configure(store.data.settings)
	audio.play_track("res://audio/june_opens_the_gate.mp3")
	var back_layer = CanvasLayer.new();back_layer.layer=-10;add_child(back_layer)
	background = Node2D.new();background.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;background.set_script(load("res://scripts/overlay.gd"));background.host=self;background.draw_method="draw_background";back_layer.add_child(background)
	var distance_grade=ShaderMaterial.new();distance_grade.shader=load("res://art/background_grade.gdshader")
	background.material=distance_grade
	# Pixel-grid composite affects scenery and actors; text stays at native resolution.
	var pixel_layer=CanvasLayer.new();pixel_layer.layer=2;add_child(pixel_layer)
	var pixel_pass=ColorRect.new();pixel_pass.size=Vector2(1280,720);pixel_pass.mouse_filter=Control.MOUSE_FILTER_IGNORE
	var pixel_material=ShaderMaterial.new();pixel_material.shader=load("res://art/pixel_world.gdshader")
	pixel_pass.material=pixel_material;pixel_layer.add_child(pixel_pass)
	var layer = CanvasLayer.new();layer.layer=3;add_child(layer)
	overlay = Node2D.new();overlay.set_script(load("res://scripts/overlay.gd"));overlay.host=self;layer.add_child(overlay)
	if store.data.settings.fullscreen: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	DisplayServer.window_set_min_size(Vector2i(960,540))

func setup_inputs() -> void:
	YBControls.apply(store.data.settings.get("bindings",{}))

func _process(dt: float) -> void:
	ui_time += dt
	transition = maxf(0,transition-dt*2.1)
	intro = maxf(0,intro-dt)
	toast_time = maxf(0,toast_time-dt)
	background.queue_redraw();overlay.queue_redraw()
	var dash=world.player.ability if world and world.player else null
	audio.charge_feedback(dash is YBChargeDash and dash.charging and world.running and world.player.active, dash.charge_ratio if dash is YBChargeDash else 0.0)
	audio.water_feedback(world!=null and world.player!=null and world.player.swimming.submerged and screen in ["playing","pause"],dt)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and not closing:
		closing = true
		if editor: editor.flush_draft()
		save_run();store.persist();get_tree().quit()
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and screen == "playing": pause_game()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.echo: return
	if event is InputEventKey and event.pressed and event.keycode == KEY_F11:
		toggle_fullscreen();return
	if screen=="editor" or not binding_action.is_empty(): return
	if editor_test and event is InputEventKey and event.pressed and event.keycode in [KEY_ESCAPE,KEY_F5]:
		return_to_editor();get_viewport().set_input_as_handled();return
	if screen == "playing":
		if lab_test and event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
			for button in buttons:
				if button.id=="lab_menu" and button.rect.has_point(event.position): pause_game();return
		if editor_test and event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
			for button in buttons:
				if button.id=="editor_return" and button.rect.has_point(event.position): return_to_editor();return
		if event.is_action_pressed("pause"): pause_game();get_viewport().set_input_as_handled()
		elif event.is_action_pressed("restart"): world.die()
		return
	if event is InputEventMouseMotion:
		hovered = -1
		for i in buttons.size():
			if buttons[i].rect.has_point(event.position): hovered=i
		if hovered >= 0: focus=hovered
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		for i in buttons.size():
			if buttons[i].rect.has_point(event.position): activate(buttons[i].id);return
	if event.is_action_pressed("ui_down") or (event is InputEventKey and event.pressed and event.keycode == KEY_TAB):
		focus = (focus+1)%maxi(1,buttons.size());audio.effect("select")
	elif event.is_action_pressed("ui_up"):
		focus = posmod(focus-1,maxi(1,buttons.size()));audio.effect("select")
	elif event.is_action_pressed("ui_accept"):
		if not buttons.is_empty(): activate(buttons[clampi(focus,0,buttons.size()-1)].id)
	elif event.is_action_pressed("ui_cancel"):
		if screen == "pause": resume_game()
		elif screen == "settings": change_screen(settings_return)
		elif screen == "controls": change_screen(controls_return)
		elif screen == "lab_menu": resume_game()
		elif screen in ["calendar","about"]: change_screen("title")
	elif screen == "calendar" and event.is_action_pressed("ui_left"): change_month(-1)
	elif screen == "calendar" and event.is_action_pressed("ui_right"): change_month(1)

func change_screen(next: String) -> void:
	screen=next;focus=0;hovered=-1;transition=0.35
	if world: world.set_running(next=="playing")
	if lab_panel: lab_panel.visible=next=="lab_menu"

func start_stage(id: String, restore_save: bool = false) -> void:
	if not stages.has(id): return
	editor_test=false;lab_test=false
	if editor: editor.hide()
	if world: remove_child(world);world.queue_free()
	world=YBWorld.new();add_child(world);world.setup(stages[id],store.data.settings)
	world.sound.connect(func(sound_id): audio.effect(sound_id))
	world.finished.connect(stage_finished)
	world.checkpoint_reached.connect(func(): save_run();notice("Checkpoint saved"))
	if restore_save and store.data.get("run",{}).get("id","") == id: world.restore(store.data.run)
	store.data.last_stage=id;selected=id;store.persist()
	audio.play_track(stages[id].music)
	change_screen("playing");transition=1;intro=4.2
	Input.mouse_mode=Input.MOUSE_MODE_HIDDEN

func save_run() -> void:
	if world and not world.complete and not editor_test and not lab_test:
		store.data["run"]=world.snapshot();store.persist()

func pause_game() -> void:
	if lab_test: change_screen("lab_menu");Input.mouse_mode=Input.MOUSE_MODE_VISIBLE;return
	save_run();change_screen("pause");Input.mouse_mode=Input.MOUSE_MODE_VISIBLE

func resume_game() -> void:
	if lab_test and world.complete: lab_station(maxi(0,world.checkpoint_index));return
	change_screen("playing");Input.mouse_mode=Input.MOUSE_MODE_VISIBLE if lab_test else Input.MOUSE_MODE_HIDDEN

func stage_finished() -> void:
	if lab_test: change_screen("lab_menu");Input.mouse_mode=Input.MOUSE_MODE_VISIBLE;return
	if editor_test:
		change_screen("editor_complete");Input.mouse_mode=Input.MOUSE_MODE_VISIBLE;return
	store.record(world.spec.id,world.elapsed,world.collected.size(),world.deaths,world.assist)
	store.data.erase("run");store.persist()
	change_screen("complete");Input.mouse_mode=Input.MOUSE_MODE_VISIBLE

func notice(message: String) -> void:
	toast=message;toast_time=3

func toggle_fullscreen() -> void:
	store.data.settings.fullscreen = not store.data.settings.fullscreen
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if store.data.settings.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	store.persist()

func activate(id: String) -> void:
	audio.effect("select")
	if id.begins_with("bind:"):
		var parts=id.split(":");binding_action=parts[1];binding_gamepad=parts[2]=="pad";binding_status="Press a gamepad button or move an axis…" if binding_gamepad else "Press a key or mouse button…";return
	if id.begins_with("day:"):
		selected=id.substr(4);return
	if id.begins_with("sample:"):
		selected=id.substr(7)
		var month=int(selected.substr(0,2))
		for i in 12:
			if int(calendar.months[i].number)==month: month_index=i
		return
	match id:
		"begin": start_stage("06-01")
		"continue": start_stage(store.data.last_stage,true)
		"calendar": save_run();align_month();change_screen("calendar");Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
		"title": save_run();change_screen("title");Input.mouse_mode=Input.MOUSE_MODE_VISIBLE;audio.play_track("res://audio/june_opens_the_gate.mp3")
		"settings": settings_return=screen;change_screen("settings")
		"about": change_screen("about")
		"editor": open_editor()
		"lab": start_lab()
		"lab_menu": pause_game()
		"controls": controls_return="settings";change_screen("controls")
		"controls_back": change_screen(controls_return)
		"controls_reset": store.data.settings.bindings={};setup_inputs();store.persist();binding_status="Default WASD / arrows / IJKL controls restored."
		"editor_return": return_to_editor()
		"editor_retry": start_editor_test(editor.document.compile())
		"back": change_screen(settings_return if screen=="settings" else "title")
		"quit": save_run();store.persist();get_tree().quit()
		"resume": resume_game()
		"restart": start_stage(world.spec.id)
		"play":
			if stages.has(selected): start_stage(selected)
		"prev": change_month(-1)
		"next": change_month(1)
		"next_stage": start_stage(stage_order[(stage_order.find(world.spec.id)+1)%stage_order.size()])
		"music": store.data.settings.music=float((int(floor(store.data.settings.music*4))+1)%5)/4;audio.configure(store.data.settings);store.persist()
		"effects": store.data.settings.effects=float((int(floor(store.data.settings.effects*4))+1)%5)/4;audio.configure(store.data.settings);store.persist()
		"fullscreen": toggle_fullscreen()
		"motion": store.data.settings.reduced_motion=not store.data.settings.reduced_motion;store.persist();apply_settings()
		"assist": store.data.settings.assist=not store.data.settings.assist;store.persist();apply_settings()

func apply_settings() -> void:
	if world:
		world.assist=store.data.settings.assist;world.player.assist=world.assist;world.reduced_motion=store.data.settings.reduced_motion;world.player.reduced_motion=world.reduced_motion

func draw_background(n: Node2D) -> void:
	var show_world = world != null and screen in ["playing","pause","complete","editor_complete","lab_menu"] or (world != null and screen=="settings" and settings_return=="pause")
	if world: world.visible=show_world
	var season = world.spec.season if show_world else "june"
	var cam = world.camera_x if show_world else ui_time*9
	var time = world.age if show_world else ui_time
	var ambience: Dictionary=world.spec.get("ambience",{}) if show_world else {}
	n.material.set_shader_parameter("separation",float(ambience.get("separation",0.46 if season in ["june","mill"] else 0.32)))
	var air=Color(ambience.get("haze","99b8b0"))
	n.material.set_shader_parameter("air_color",Vector3(air.r,air.g,air.b))
	YBLandscape.background(n,season,cam,time,store.data.settings.reduced_motion,str(world.spec.get("background","")) if show_world else "",ambience)
	if season in ["june","mill"]: YBScenery.atmosphere(n,cam,time,store.data.settings.reduced_motion)

func draw_overlay(n: Node2D) -> void:
	buttons.clear()
	if screen in ["playing","pause","complete","editor_complete","lab_menu"] or (screen=="settings" and settings_return=="pause"):
		if world and screen!="lab_menu":
			draw_hud(n)
	match screen:
		"title": draw_title(n)
		"calendar": draw_calendar(n)
		"settings": draw_settings(n)
		"controls": draw_controls(n)
		"lab_menu": n.draw_rect(Rect2(0,0,1280,720),Color(.06,.16,.19,.6))
		"about": draw_about(n)
		"pause": draw_pause(n)
		"complete": draw_complete(n)
		"editor_complete": draw_editor_complete(n)
		"playing":
			if editor_test: button(n,"editor_return","← Editor · Esc / F5",Rect2(1030,105,222,37))
			if intro>0:
				var alpha = minf(1,intro)
				panel(n,Rect2(320,140,640,108),Color(0.12,0.23,0.26,0.82*alpha),12)
				label(n,date_label(world.spec.id).to_upper(),Vector2(640,174),15,Color(GOLD,alpha),true)
				label(n,world.spec.title,Vector2(640,215),31,Color(CREAM,alpha),true,true)
	if toast_time>0:
		panel(n,Rect2(520,641,240,39),Color(0.1,0.23,0.24,0.9),19)
		label(n,"✦  "+toast,Vector2(640,667),15,CREAM,true)
	if transition>0: n.draw_rect(Rect2(0,0,1280,720),Color(0.07,0.14,0.17,transition))

func draw_title(n: Node2D) -> void:
	panel(n,Rect2(0,0,650,720),Color(0.08,0.20,0.22,0.89),0)
	label(n,"A JOURNEY THROUGH THE TURNING YEAR",Vector2(72,102),13,GOLD)
	label(n,"Yearbound",Vector2(66,216),88,CREAM,false,true)
	n.draw_line(Vector2(74,243),Vector2(136,243),GOLD,2)
	label(n,"Every day, a world of its own.",Vector2(74,286),25,CREAM,false,true)
	label(n,"Begin in the sunlight. Follow the seasons.",Vector2(74,326),17,MUTED)
	label(n,"Find your way through a year still waiting to unfold.",Vector2(74,354),17,MUTED)
	var has_progress = store.data.has("run") or not store.data.results.is_empty()
	button(n,"continue" if has_progress else "begin","Continue the journey   →" if has_progress else "Begin · 1 June   →",Rect2(74,399,405,54),true)
	button(n,"calendar","Explore the calendar",Rect2(74,465,405,48))
	button(n,"settings","Settings",Rect2(74,524,194,44))
	button(n,"about","Field notes",Rect2(281,524,198,44))
	button(n,"quit","Quit",Rect2(74,579,194,40))
	button(n,"editor","Layout workshop",Rect2(281,579,198,40))
	label(n,str(stages.size())+" DAYS TO DISCOVER  /  365 DAYS TO IMAGINE",Vector2(74,674),11,MUTED)
	panel(n,Rect2(831,74,356,79),Color(1,0.97,0.84,0.75),12)
	label(n,"01",Vector2(853,128),42,INK,false,true)
	label(n,"JUNE",Vector2(931,107),13,INK)
	label(n,"The first sunlit path",Vector2(931,132),17,INK)
	button(n,"lab","Charge dash lab   →",Rect2(831,175,356,48),true)
	label(n,"Experiment · tune · repeat",Vector2(849,248),14,CREAM)
	label(n,"FOUNDATION EDITION  ·  0.11.0",Vector2(995,684),11,Color("e6eac7"),true)

func draw_calendar(n: Node2D) -> void:
	n.draw_rect(Rect2(0,0,1280,720),Color(0.07,0.18,0.20,0.94))
	label(n,"THE YEAR AHEAD",Vector2(56,53),12,GOLD)
	label(n,"One day. A different world.",Vector2(54,105),39,CREAM,false,true)
	button(n,"title","← Home",Rect2(1100,40,124,40))
	var month=calendar.months[month_index]
	label(n,month.name,Vector2(57,171),32,CREAM,false,true)
	label(n,month.subtitle.to_upper(),Vector2(260,166),12,MUTED)
	button(n,"prev","←",Rect2(622,136,44,40));button(n,"next","→",Rect2(676,136,44,40))
	var entries=[]
	for d in calendar.days:
		if int(d.month)==int(month.number): entries.append(d)
	for i in entries.size():
		var day=entries[i]
		var rect=Rect2(56+(i%7)*96,196+(i/7)*63,86,53)
		var available=day.available
		var chosen=day.id==selected
		var fill=Color("315a54") if chosen else (Color("263f40") if available else Color("172e32"))
		panel(n,rect,fill,7)
		if chosen: outline(n,rect,GOLD,7)
		label(n,str(int(day.day)),rect.position+Vector2(14,32),22,CREAM if available else Color("687e7c"),false,true)
		if available: n.draw_circle(rect.position+Vector2(69,18),3,GOLD,true,-1,true)
		if store.data.results.has(day.id): label(n,"✓",rect.position+Vector2(61,42),15,GOLD)
		elif day.boss: label(n,"♢",rect.position+Vector2(61,42),16,MUTED)
		buttons.append({"id":"day:"+day.id,"rect":rect})
		if focus==buttons.size()-1: outline(n,rect,Color("d4dfbf"),7)
	label(n,"● Playable     ✓ Complete     ♢ Monthly boss     Dim dates are unwritten",Vector2(57,545),12,MUTED)
	panel(n,Rect2(768,136,456,420),Color("f4ecd0"),12)
	var s=stages.get(selected,{})
	label(n,date_label(selected).to_upper(),Vector2(796,174),13,Color("547064"))
	if not s.is_empty():
		wrapped(n,s.title,Vector2(796,212),395,23,INK)
		wrapped(n,s.description,Vector2(796,267),390,18,INK)
		label(n,"A PLAYABLE CHAPTER",Vector2(796,387),11,Color("638070"))
		var result=store.data.results.get(selected,{})
		label(n,("Best: "+clock_text(result.best_time)+"  ·  "+str(int(result.motes))+" sunmotes") if not result.is_empty() else ("Survival boss · three phases" if s.has("boss") else "Explore · collect · reach the garden gate"),Vector2(796,415),15,INK)
		button(n,"play","Enter this day   →",Rect2(796,472,400,54),true)
	else:
		label(n,"A day yet to be written",Vector2(796,225),28,INK,false,true)
		wrapped(n,"This place in the year is reserved for an original stage, its own music, and something worth discovering.",Vector2(796,273),380,18,INK)
		label(n,"365 places. A growing journey.",Vector2(796,442),20,Color("547064"),false,true)
	label(n,"A SAMPLE IN EVERY MONTH  ·  CHARGE DASH IS READY THROUGHOUT THE YEAR",Vector2(56,594),12,GOLD)
	for i in featured_order.size():
		var id: String=featured_order[i]
		button(n,"sample:"+id,date_label(id),Rect2(56+(i%6)*196,606+(i/6)*37,184,32),id==selected)
	label(n,"↑ ↓ / Tab: focus   ·   Enter / A: select   ·   ← →: month   ·   Esc / B: back",Vector2(56,696),12,MUTED)

func draw_hud(n: Node2D) -> void:
	if lab_test: draw_lab_hud(n);return
	panel(n,Rect2(28,22,346,71),Color(0.09,0.22,0.25,0.9),11)
	label(n,date_label(world.spec.id).to_upper(),Vector2(48,47),12,GOLD)
	label(n,world.spec.title,Vector2(48,75),mini(20,int(20*310/maxf(310,heading.get_string_size(world.spec.title,HORIZONTAL_ALIGNMENT_LEFT,-1,20).x))),CREAM,false,true)
	panel(n,Rect2(982,22,270,71),Color(0.09,0.22,0.25,0.9),11)
	label(n,(str(maxi(0,ceili(105-world.boss_time)))+"s to calm the sky") if world.spec.has("boss") else ("✦  "+str(world.collected.size())+" / "+str(world.spec.motes.size())),Vector2(1002,52),18,GOLD)
	label(n,clock_text(world.elapsed)+"   ·   Esc / Start: pause",Vector2(1002,78),12,CREAM)
	if world.spec.has("boss"):
		panel(n,Rect2(417,25,446,67),Color(0.1,0.2,0.25,0.93),11)
		var phase=mini(3,int(world.boss_time/35)+1)
		label(n,"THE SQUALLKEEPER  ·  PHASE "+str(phase)+" / 3",Vector2(640,48),12,CREAM,true)
		panel(n,Rect2(439,61,402,10),Color("3c5560"),5)
		panel(n,Rect2(439,61,402*maxf(0,1-world.boss_time/105),10),GOLD,5)
		label(n,"SURVIVE THE STORM  ·  Each phase is a checkpoint",Vector2(640,696),13,CREAM,true)
	else:
		panel(n,Rect2(445,33,390,7),Color(0.12,0.27,0.27,0.25),4)
		panel(n,Rect2(445,33,390*clampf(world.player.position.x/float(world.spec.length),0,1),7),CREAM,4)
	if world.player.ability is YBChargeDash:
		var dash=world.player.ability as YBChargeDash
		var unavailable="RECHARGING" if world.player.swimming.submerged else "LAND TO RESET"
		var state="FULL" if dash.charge_ratio>=1 else ("CHARGING" if dash.charging else ("DASH" if dash.dashing else (unavailable if not dash.available(world.player.is_on_floor()) else "READY")))
		panel(n,Rect2(28,120,206,43),Color(.09,.22,.25,.88),7)
		label(n,"CHARGE DASH  /  "+state,Vector2(41,139),10,GOLD)
		panel(n,Rect2(41,148,180,4),Color("3b605b"),2)
		var fill=dash.charge_ratio
		if world.player.swimming.submerged and not dash.charging and not dash.available(false):
			fill=clampf(dash.medium_recovery/world.player.swimming.tuning.dash_refill_time,0,1)
		panel(n,Rect2(41,148,180*fill,4),GOLD if dash.charge_ratio>=1 else CREAM,2)
	if world.player.swimming.submerged:
		panel(n,Rect2(28,174,206,42),Color(.09,.22,.25,.88),7)
		label(n,"UNDERWATER  /  SWIM",Vector2(41,192),10,Color("b5e9e5"))
		label(n,"Jump to rise · Down to dive",Vector2(41,207),10,CREAM)
	if world.assist: label(n,"GENTLE JOURNEY",Vector2(48,113),11,CREAM)
	if world.respawn_delay>0: n.draw_rect(Rect2(0,0,1280,720),Color(0.1,0.2,0.24,world.respawn_delay*0.65))

func draw_pause(n: Node2D) -> void:
	if editor_test:
		n.draw_rect(Rect2(0,0,1280,720),Color(0.07,0.16,0.19,0.78))
		panel(n,Rect2(425,183,430,330),Color("18363b"),16)
		label(n,"PLAYTEST PAUSED",Vector2(640,236),24,CREAM,true)
		button(n,"resume","Resume test",Rect2(467,272,346,52),true)
		button(n,"editor_retry","Restart test",Rect2(467,338,346,46))
		button(n,"editor_return","Return to workshop",Rect2(467,396,346,46))
		return
	n.draw_rect(Rect2(0,0,1280,720),Color(0.07,0.16,0.19,0.72))
	panel(n,Rect2(425,133,430,470),Color("18363b"),16)
	label(n,"A MOMENT BETWEEN STEPS",Vector2(640,177),12,GOLD,true)
	label(n,"Take a breath.",Vector2(640,232),40,CREAM,true,true)
	button(n,"resume","Resume   →",Rect2(467,268,346,52),true)
	button(n,"settings","Settings & controls",Rect2(467,332,346,46))
	button(n,"restart","Restart this day",Rect2(467,389,346,46))
	button(n,"calendar","Return to calendar",Rect2(467,446,346,46))
	button(n,"title","Save & return home",Rect2(467,503,346,46))
	label(n,"Your latest lantern checkpoint is saved.",Vector2(640,578),12,MUTED,true)

func draw_settings(n: Node2D) -> void:
	n.draw_rect(Rect2(0,0,1280,720),Color(0.07,0.18,0.2,0.96))
	label(n,"MAKE YOURSELF AT HOME",Vector2(80,66),12,GOLD)
	label(n,"Settings",Vector2(77,126),46,CREAM,false,true)
	button(n,"back","← Back",Rect2(1080,58,120,43))
	var s=store.data.settings
	button(n,"music","Music                          "+str(roundi(s.music*100))+"%",Rect2(80,177,497,58))
	button(n,"effects","Sound effects                  "+str(roundi(s.effects*100))+"%",Rect2(80,248,497,58))
	button(n,"fullscreen","Fullscreen                       "+("On" if s.fullscreen else "Off"),Rect2(80,319,497,58))
	button(n,"motion","Reduced motion                   "+("On" if s.reduced_motion else "Off"),Rect2(80,390,497,58))
	button(n,"assist","Gentle journey                   "+("On" if s.assist else "Off"),Rect2(80,461,497,58))
	wrapped(n,"Gentle journey adds jump height, longer leaf-platform timing and slower boss patterns. Your records note assisted play.",Vector2(80,558),480,16,MUTED)
	panel(n,Rect2(643,177,557,450),Color("254348"),12)
	label(n,"Make the next leap.",Vector2(679,222),29,CREAM,false,true)
	var map=store.data.settings.bindings
	var controls=[["Move / aim",YBControls.labels(map,"left")+" · "+YBControls.labels(map,"right")],["Aim vertically",YBControls.labels(map,"aim_up")+" · "+YBControls.labels(map,"aim_down")],["Jump · hold for height",YBControls.labels(map,"jump")],["Charge dash · lab",YBControls.labels(map,"ability")],["Pause / restart",YBControls.labels(map,"pause")+" · "+YBControls.labels(map,"restart")]]
	for i in controls.size():
		var y=265+i*51
		label(n,controls[i][0],Vector2(679,y),16,CREAM)
		label(n,controls[i][1],Vector2(679,y+22),12,MUTED)
	button(n,"controls","Rebind keyboard / controller   →",Rect2(677,556,486,44))

	label(n,"Settings save automatically. Volume buttons cycle through levels.",Vector2(80,679),13,MUTED)

func draw_about(n: Node2D) -> void:
	n.draw_rect(Rect2(0,0,1280,720),Color(0.07,0.18,0.2,0.96))
	label(n,"FIELD NOTES  /  FOUNDATION 0.11.0",Vector2(90,81),12,GOLD)
	label(n,"A whole year starts here.",Vector2(87,148),46,CREAM,false,true)
	wrapped(n,"Yearbound is a platforming journey from 1 June to 31 May. Each date will become its own place: its own atmosphere, music and reason to take one more leap.",Vector2(90,213),750,23,CREAM)
	wrapped(n,"This foundation contains "+str(stages.size())+" playable days, with a sample in every month and seventeen distinct days at the beginning of June. Follow the sunmotes, light the checkpoint lanterns and find each day's door. On 30 June, read the amber warnings and survive three phases to calm the Squallkeeper. There is no attack button.",Vector2(90,344),750,18,MUTED)
	wrapped(n,"1–17 June use the supplied Yearbound music. The later sample days use original synthesized sketch scores. The world uses detailed pixel-art landscapes and sprites, animated terrain and weather, and a traveller in a copper scarf. Background and sprite art was generated for this project.",Vector2(90,473),750,16,MUTED)
	button(n,"back","← Back to the sunlight",Rect2(90,616,310,51),true)

func draw_complete(n: Node2D) -> void:
	n.draw_rect(Rect2(0,0,1280,720),Color(0.06,0.17,0.2,0.78))
	panel(n,Rect2(343,117,594,493),Color("f5ecd0"),16)
	label(n,"A DAY TO REMEMBER",Vector2(640,166),12,Color("638174"),true)
	label(n,"The sky is quiet again." if world.spec.has("boss") else "A little further into the year.",Vector2(640,225),32,INK,true,true)
	label(n,date_label(world.spec.id)+" · "+world.spec.title,Vector2(640,265),18,INK,true)
	for i in 3:
		var x=450+i*190
		var value=[clock_text(world.elapsed),str(world.collected.size()),str(world.deaths)][i]
		label(n,value,Vector2(x,344),35,INK,true,true)
		label(n,["TIME","SUNMOTES","RESTARTS"][i],Vector2(x,375),11,Color("638174"),true)
	button(n,"next_stage","Discover the next day   →",Rect2(390,417,500,52),true)
	button(n,"calendar","Return to the calendar",Rect2(390,482,500,46))
	label(n,"Progress saved  ·  "+str(store.data.results.size())+" of "+str(stage_order.size())+" playable days completed",Vector2(640,573),13,Color("638174"),true)

func button(n: Node2D, id: String, text: String, rect: Rect2, primary: bool=false) -> void:
	var focused=focus==buttons.size()
	var fill=GOLD if primary else Color("2b4b4c")
	if focused: fill=fill.lightened(0.1)
	panel(n,rect,fill,8)
	if focused: outline(n,rect,CREAM,8)
	label(n,text,rect.position+Vector2(19,rect.size.y/2+6),17,INK if primary else CREAM)
	buttons.append({"id":id,"rect":rect})

func label(n: Node2D,text: String,at: Vector2,size: int=18,tint: Color=CREAM,center: bool=false,serif: bool=false) -> void:
	var use_font: Font=heading if serif else font
	if center: at.x-=use_font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x/2
	n.draw_string(use_font,at,text,HORIZONTAL_ALIGNMENT_LEFT,-1,size,tint)

func wrapped(n: Node2D,text: String,at: Vector2,width: float,size: int,tint: Color) -> void:
	var line=""
	for word in text.split(" "):
		if font.get_string_size(line+word,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x>width and not line.is_empty():
			label(n,line,at,size,tint);at.y+=size*1.55;line=""
		line+=word+" "
	label(n,line,at,size,tint)

func panel(n: Node2D,rect: Rect2,fill: Color,radius: int) -> void:
	if rect.size.x>0: n.draw_style_box(YBWorld.box(fill,radius),rect)

func outline(n: Node2D,rect: Rect2,tint: Color,radius: int) -> void:
	var style=YBWorld.box(Color.TRANSPARENT,radius)
	style.border_color=tint;style.set_border_width_all(1)
	n.draw_style_box(style,rect)

func date_label(id: String) -> String:
	if id=="dash-lab": return "Charge dash lab"
	var month=int(id.substr(0,2))
	for m in calendar.months:
		if int(m.number)==month: return str(int(id.substr(3,2)))+" "+m.name
	return id

func clock_text(seconds: float) -> String:
	return "%d:%02d" % [int(seconds)/60,int(seconds)%60]

func align_month() -> void:
	for i in 12:
		if int(calendar.months[i].number)==int(selected.substr(0,2)): month_index=i

func change_month(direction: int) -> void:
	month_index=posmod(month_index+direction,12)
	var month=int(calendar.months[month_index].number)
	selected="%02d-01" % month
	for day in calendar.days:
		if int(day.month)==month and stages.has(day.id):
			selected=day.id
			break

func open_editor() -> void:
	save_run()
	if world: remove_child(world);world.queue_free();world=null
	editor_test=false;lab_test=false;change_screen("editor");Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	if not editor:
		var layer=CanvasLayer.new();layer.layer=4;add_child(layer)
		editor=YBLayoutEditor.new();editor.host=self;layer.add_child(editor)
	editor.show()
func leave_editor() -> void:
	editor.hide();change_screen("title");Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
func start_editor_test(data: Dictionary) -> void:
	if world: remove_child(world);world.queue_free()
	editor_test=true;lab_test=false;editor.hide()
	world=YBWorld.new();add_child(world);world.setup(data,store.data.settings)
	world.sound.connect(func(sound_id): audio.effect(sound_id));world.finished.connect(stage_finished)
	world.checkpoint_reached.connect(func(): notice("Test checkpoint"))
	audio.play_track(data.music);change_screen("playing");transition=.6;intro=0
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
func return_to_editor() -> void:
	if world: remove_child(world);world.queue_free();world=null
	editor_test=false;lab_test=false;change_screen("editor");editor.show();Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	for action in ["left","right","jump"]: Input.action_release(action)
func draw_editor_complete(n: Node2D) -> void:
	n.draw_rect(Rect2(0,0,1280,720),Color(0.06,0.17,0.2,.8))
	panel(n,Rect2(360,200,560,330),Color("18363b"),14)
	label(n,"LAYOUT PLAYTEST",Vector2(640,244),12,GOLD,true)
	label(n,"You reached the exit.",Vector2(640,295),34,CREAM,true,true)
	label(n,clock_text(world.elapsed)+"  ·  "+str(world.deaths)+" retries",Vector2(640,331),17,MUTED,true)
	button(n,"editor_return","← Return to workshop",Rect2(410,362,460,54),true)
	button(n,"editor_retry","Test again",Rect2(410,430,460,46))

func _input(event: InputEvent) -> void:
	if screen!="controls" or binding_action.is_empty(): return
	if event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE:
		binding_action="";binding_status="Binding unchanged.";get_viewport().set_input_as_handled();return
	var candidate=YBControls.from_event(event,binding_gamepad)
	if candidate.is_empty(): return
	get_viewport().set_input_as_handled()
	var result=YBControls.rebind(store.data.settings.bindings,binding_action,binding_gamepad,candidate)
	if result.has("error"): binding_status=result.error;return
	store.data.settings.bindings=result.bindings;setup_inputs();store.persist()
	binding_action="";binding_status="Binding saved."

func draw_controls(n: Node2D) -> void:
	n.draw_rect(Rect2(0,0,1280,720),Color("153239"))
	label(n,"MAKE THE MOVEMENT YOURS",Vector2(62,57),12,GOLD)
	label(n,"Controls",Vector2(59,110),42,CREAM,false,true)
	button(n,"controls_back","← Back",Rect2(1090,59,126,43))
	label(n,"WASD / arrows / IJKL are included by default. Up and down aim; jump has its own button.",Vector2(62,148),15,MUTED)
	label(n,"ACTION",Vector2(62,188),11,GOLD);label(n,"KEYBOARD / MOUSE",Vector2(344,188),11,GOLD);label(n,"CONTROLLER",Vector2(811,188),11,GOLD)
	for i in YBControls.ACTIONS.size():
		var action=YBControls.ACTIONS[i];var y=205+i*46
		label(n,YBControls.NAMES[i],Vector2(62,y+26),17,CREAM)
		button(n,"bind:"+action+":key",YBControls.labels(store.data.settings.bindings,action),Rect2(326,y,453,38))
		button(n,"bind:"+action+":pad",YBControls.labels(store.data.settings.bindings,action,true),Rect2(795,y,421,38))
	button(n,"controls_reset","Restore defaults",Rect2(62,597,231,43))
	wrapped(n,binding_status,Vector2(326,613),870,15,GOLD if not binding_action.is_empty() else MUTED)
	label(n,"Capture replaces that action's keyboard or controller group. Conflicts are rejected. F11 stays fullscreen.",Vector2(62,684),12,MUTED)
	if not binding_action.is_empty():
		panel(n,Rect2(360,64,645,66),Color("48665b"),8)
		label(n,"Binding: "+YBControls.NAMES[YBControls.ACTIONS.find(binding_action)]+"  ·  Esc cancels",Vector2(382,106),20,CREAM)

func start_lab() -> void:
	save_run()
	if editor: editor.hide()
	if world: remove_child(world);world.queue_free()
	if lab_panel: lab_panel.get_parent().queue_free();lab_panel=null
	lab_test=true;editor_test=false
	var data=JSON.parse_string(FileAccess.get_file_as_string("res://content/labs/charge_dash.json"))
	world=YBWorld.new();add_child(world);world.setup(data,store.data.settings)
	world.sound.connect(func(id): audio.effect(id));world.finished.connect(stage_finished)
	var layer=CanvasLayer.new();layer.layer=4;add_child(layer)
	lab_panel=YBDashLabPanel.new();lab_panel.host=self;layer.add_child(lab_panel)
	audio.play_track(data.music);lab_station(0)
func lab_station(index: int) -> void:
	var station=world.spec.lab_stations[index];var at=Vector2(station.spawn[0],station.spawn[1])
	world.complete=false;world.respawn_delay=0;world.player.visible=true
	world.age=0
	world.checkpoint=at;world.checkpoint_index=index;world.player.reset_at(at)
	world.camera_x=clampf(at.x-300,0,world.spec.length-1280);world.camera.position=Vector2(world.camera_x+640,360)
	change_screen("playing");intro=0;transition=.3;Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
func draw_lab_hud(n: Node2D) -> void:
	var dash=world.player.ability as YBChargeDash
	if not dash: return
	var station=world.spec.lab_stations[clampi(world.checkpoint_index,0,world.spec.lab_stations.size()-1)]
	panel(n,Rect2(22,19,1236,125),Color(.07,.18,.21,.95),10)
	label(n,"CHARGE DASH LAB  /  "+station.name.to_upper(),Vector2(42,45),14,GOLD)
	label(n,station.hint,Vector2(42,71),14,CREAM)
	var state=("FULL CHARGE" if dash.charge_ratio>=1 else "CHARGING") if dash.charging else ("DASH" if dash.dashing else ("COOLDOWN" if dash.cooldown_left>0 else ("LAND TO RECHARGE" if not dash.available(world.player.is_on_floor()) else "READY")))
	label(n,state,Vector2(42,103),12,GOLD)
	panel(n,Rect2(231,91,222,11),Color("395959"),3)
	panel(n,Rect2(231,91,222*dash.charge_ratio,11),GOLD if dash.charge_ratio>=1 else Color("b4e4d9"),3)
	label(n,"%d%%  ·  %.2fs" % [roundi(dash.charge_ratio*100),dash.charge_time],Vector2(465,103),13,CREAM)
	label(n,"Speed %4d  ·  Last %d%% / %d px/s  ·  Burst Δ %.0f, %.0f" % [world.player.velocity.length(),roundi(dash.last_ratio*100),dash.last_force,dash.dash_displacement.x,dash.dash_displacement.y],Vector2(42,130),12,MUTED)
	button(n,"lab_menu","Stations & tuning",Rect2(1020,87,218,40))
	panel(n,Rect2(20,672,1240,31),Color(.07,.18,.21,.94),6)
	label(n,"Hold "+YBControls.labels(store.data.settings.bindings,"ability")+" / "+YBControls.labels(store.data.settings.bindings,"ability",true)+" → aim → release.   Esc: tune   ·   "+YBControls.labels(store.data.settings.bindings,"restart")+": reset lantern",Vector2(34,693),12,CREAM)
	# A fixed world-space ruler makes the different bursts directly comparable.
	for x in range(floori(world.camera_x/48)*48,ceili((world.camera_x+1280)/48)*48,48):
		var sx=x-world.camera_x
		n.draw_line(Vector2(sx,651),Vector2(sx,658 if x%192 else 666),Color("c8d3b1"),1)
		if x%192==0: label(n,str(x-int(station.start)),Vector2(sx+3,664),10,CREAM)
