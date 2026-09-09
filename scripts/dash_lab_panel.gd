class_name YBDashLabPanel
extends Control
var host: Node2D
var tuning: YBChargeDashTuning
var fields={}
var syncing=false
var status: Label
var export_dialog: FileDialog
var stations_scroll: ScrollContainer
var station_buttons: Array[Button]=[]
func _ready() -> void:
	size=Vector2(1280,720);mouse_filter=Control.MOUSE_FILTER_IGNORE
	tuning=host.world.player.ability.tuning
	var panel=Panel.new();panel.position=Vector2(42,38);panel.size=Vector2(1196,644);panel.add_theme_stylebox_override("panel",YBWorld.box(Color("18363b"),12));add_child(panel)
	text("CHARGE DASH / LABORATORY",Vector2(70,60),15,host.GOLD)
	text("Choose a station. Tune a launch.",Vector2(70,89),28,host.CREAM)
	text("Shared dash profile. Lab attempts keep campaign progress separate.",Vector2(70,130),14,host.MUTED)
	stations_scroll=ScrollContainer.new();stations_scroll.position=Vector2(70,175);stations_scroll.size=Vector2(446,392);stations_scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;add_child(stations_scroll)
	var station_rows=VBoxContainer.new();station_rows.size_flags_horizontal=Control.SIZE_EXPAND_FILL;station_rows.add_theme_constant_override("separation",6);stations_scroll.add_child(station_rows)
	for i in host.world.spec.lab_stations.size():
		var station=host.world.spec.lab_stations[i]
		var button=make_button("%02d  %s" % [i+1,station.name],Vector2.ZERO,Vector2(424,30))
		remove_child(button);station_rows.add_child(button);button.custom_minimum_size=Vector2(424,30);station_buttons.append(button)
		button.pressed.connect(func(): host.lab_station(i))
	text("17 stations · scroll for the extended courses",Vector2(70,577),12,host.MUTED)
	text("DASH PROFILE · logical pixels / seconds",Vector2(554,160),12,host.GOLD)
	var scroll=ScrollContainer.new();scroll.position=Vector2(550,181);scroll.size=Vector2(650,386);scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;add_child(scroll)
	var rows=VBoxContainer.new();rows.size_flags_horizontal=Control.SIZE_EXPAND_FILL;scroll.add_child(rows)
	for field in YBChargeDashTuning.FIELDS:
		var row=HBoxContainer.new();row.custom_minimum_size.y=34;rows.add_child(row)
		var label=Label.new();label.text=field[1];label.custom_minimum_size.x=363;label.add_theme_font_size_override("font_size",14);row.add_child(label)
		if field.size()==2:
			var toggle=CheckButton.new();toggle.button_pressed=tuning.get(field[0]);row.add_child(toggle);fields[field[0]]=toggle
			toggle.toggled.connect(func(value): update_value(field[0],value))
		else:
			var value=SpinBox.new();value.min_value=field[2];value.max_value=field[3];value.step=field[4];value.value=tuning.get(field[0]);value.custom_minimum_size.x=146;row.add_child(value);fields[field[0]]=value
			value.value_changed.connect(func(number): update_value(field[0],number))
	for node in [panel,rows]:
		node.add_theme_font_override("font",host.font);node.add_theme_color_override("font_color",host.CREAM)
	make_button("Resume lab  →",Vector2(70,600),Vector2(200,42)).pressed.connect(func(): host.resume_game())
	make_button("Controls",Vector2(283,600),Vector2(135,42)).pressed.connect(func(): host.controls_return="lab_menu";host.change_screen("controls"))
	make_button("Defaults",Vector2(551,600),Vector2(132,42)).pressed.connect(reset_defaults)
	make_button("Export profile…",Vector2(696,600),Vector2(210,42)).pressed.connect(export_profile)
	make_button("Home",Vector2(1058,600),Vector2(142,42)).pressed.connect(func(): host.activate("title"))
	status=text("Profile saves locally. Scroll for all tuning values.",Vector2(551,650),12,host.MUTED)
	export_dialog=FileDialog.new();export_dialog.use_native_dialog=true;export_dialog.access=FileDialog.ACCESS_FILESYSTEM;export_dialog.file_mode=FileDialog.FILE_MODE_SAVE_FILE;export_dialog.filters=PackedStringArray(["*.json ; Charge dash tuning"]);add_child(export_dialog)
	export_dialog.file_selected.connect(func(path):
		if not path.to_lower().ends_with(".json"): path+=".json"
		var code=YBLayoutDocument.write_layout(path,{"schema_version":1,"mechanic":"charge_dash","values":tuning.values()})
		status.text="Exported "+path.get_file() if code==OK else "Could not export here. Choose another folder.")
	visibility_changed.connect(func():
		if visible:
			var index=clampi(host.world.checkpoint_index,0,station_buttons.size()-1)
			focus_station.call_deferred(index))
func focus_station(index: int) -> void:
	await get_tree().process_frame
	if not visible: return
	station_buttons[index].grab_focus();stations_scroll.ensure_control_visible(station_buttons[index])
func text(value: String, at: Vector2, font_size: int, color: Color) -> Label:
	var label=Label.new();label.text=value;label.position=at;label.add_theme_font_override("font",host.font);label.add_theme_font_size_override("font_size",font_size);label.add_theme_color_override("font_color",color);add_child(label);return label
func make_button(value: String, at: Vector2, dimensions: Vector2) -> Button:
	var button=Button.new();button.text=value;button.position=at;button.size=dimensions;button.add_theme_font_override("font",host.font);button.add_theme_font_size_override("font_size",15)
	for state in ["normal","hover","pressed","focus"]: button.add_theme_stylebox_override(state,YBWorld.box(Color("315653") if state=="normal" else Color("577969"),5))
	button.add_theme_color_override("font_color",host.CREAM);add_child(button);return button
func update_value(key: String, value: Variant) -> void:
	if syncing: return
	tuning.apply_values({key:value});host.store.data.settings.dash_tuning=tuning.values();host.store.persist()
	sync_fields();status.text="Saved locally · next launch uses these values."
func sync_fields() -> void:
	syncing=true
	for key in fields:
		if fields[key] is SpinBox: fields[key].value=tuning.get(key)
		else: fields[key].button_pressed=tuning.get(key)
	syncing=false
func reset_defaults() -> void:
	tuning.apply_values(YBChargeDashTuning.profile().values());host.store.data.settings.dash_tuning={};host.store.persist();sync_fields();status.text="Default dash profile restored."
func export_profile() -> void:
	export_dialog.current_file="yearbound-charge-dash.json";export_dialog.current_dir=ProjectSettings.globalize_path(host.store.PATH.get_base_dir());export_dialog.popup_centered(Vector2i(900,600))
