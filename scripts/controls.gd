class_name YBControls
extends RefCounted
const ACTIONS=["left","right","aim_up","aim_down","jump","ability","restart","pause"]
const NAMES=["Move / aim left","Move / aim right","Aim / swim up","Aim / swim down","Jump / swim up","Charge dash","Restart checkpoint","Pause"]
static func key(code: int) -> Dictionary: return {"kind":"key","code":code}
static func pad(code: int) -> Dictionary: return {"kind":"pad","code":code}
static func axis(code: int, value: float) -> Dictionary: return {"kind":"axis","code":code,"value":value}
static func defaults() -> Dictionary:
	return {"left":[key(KEY_A),key(KEY_LEFT),key(KEY_J),pad(JOY_BUTTON_DPAD_LEFT),axis(JOY_AXIS_LEFT_X,-1)],
	"right":[key(KEY_D),key(KEY_RIGHT),key(KEY_L),pad(JOY_BUTTON_DPAD_RIGHT),axis(JOY_AXIS_LEFT_X,1)],
	"aim_up":[key(KEY_W),key(KEY_UP),key(KEY_I),pad(JOY_BUTTON_DPAD_UP),axis(JOY_AXIS_LEFT_Y,-1)],
	"aim_down":[key(KEY_S),key(KEY_DOWN),key(KEY_K),pad(JOY_BUTTON_DPAD_DOWN),axis(JOY_AXIS_LEFT_Y,1)],
	"jump":[key(KEY_SPACE),key(KEY_Z),pad(JOY_BUTTON_A)],"ability":[key(KEY_SHIFT),key(KEY_C),pad(JOY_BUTTON_X),pad(JOY_BUTTON_RIGHT_SHOULDER)],
	"restart":[key(KEY_R),pad(JOY_BUTTON_Y)],"pause":[key(KEY_ESCAPE),key(KEY_P),pad(JOY_BUTTON_START)]}
static func valid(item: Variant) -> bool:
	if not item is Dictionary or not item.get("kind") in ["key","mouse","pad","axis"]: return false
	if not (item.get("code") is int or item.get("code") is float): return false
	var code=int(item.code)
	match item.kind:
		"key": return code>0 and code<KEY_SPECIAL+1000 and code!=KEY_F11
		"mouse": return code>=1 and code<=9 and code not in [4,5,6,7]
		"pad": return code>=0 and code<JOY_BUTTON_MAX
		"axis": return code>=0 and code<JOY_AXIS_MAX and (item.get("value")==-1 or item.get("value")==1)
	return false
static func resolved(saved: Dictionary) -> Dictionary:
	var result=defaults()
	for action in ACTIONS:
		if not saved.get(action) is Array or saved[action].is_empty() or saved[action].size()>12: continue
		var safe=[]
		for item in saved[action]:
			if valid(item): safe.append(item)
		if not safe.is_empty(): result[action]=safe
	return result
static func apply(saved: Dictionary) -> void:
	var map=resolved(saved)
	for action in ACTIONS:
		if not InputMap.has_action(action): InputMap.add_action(action)
		Input.action_release(action);InputMap.action_erase_events(action);InputMap.action_set_deadzone(action,.2)
		for item in map[action]:
			var event: InputEvent
			match item.kind:
				"key": event=InputEventKey.new();event.physical_keycode=int(item.code)
				"mouse": event=InputEventMouseButton.new();event.button_index=int(item.code)
				"pad": event=InputEventJoypadButton.new();event.button_index=int(item.code)
				"axis": event=InputEventJoypadMotion.new();event.axis=int(item.code);event.axis_value=float(item.value)
			if item.kind in ["pad","axis"]: event.device=-1
			InputMap.action_add_event(action,event)
static func from_event(event: InputEvent, gamepad: bool) -> Dictionary:
	if gamepad:
		if event is InputEventJoypadButton and event.pressed: return pad(event.button_index)
		if event is InputEventJoypadMotion and absf(event.axis_value)>.65: return axis(event.axis,signf(event.axis_value))
	else:
		if event is InputEventKey and event.pressed and not event.echo: return key(event.physical_keycode if event.physical_keycode else event.keycode)
		if event is InputEventMouseButton and event.pressed: return {"kind":"mouse","code":event.button_index}
	return {}
static func label(item: Dictionary) -> String:
	match item.kind:
		"key": return OS.get_keycode_string(int(item.code))
		"mouse": return "Mouse "+str(int(item.code))
		"pad":
			var names={JOY_BUTTON_A:"A / South",JOY_BUTTON_B:"B / East",JOY_BUTTON_X:"X / West",JOY_BUTTON_Y:"Y / North",JOY_BUTTON_RIGHT_SHOULDER:"RB",JOY_BUTTON_START:"Start",JOY_BUTTON_DPAD_UP:"D-pad ↑",JOY_BUTTON_DPAD_DOWN:"D-pad ↓",JOY_BUTTON_DPAD_LEFT:"D-pad ←",JOY_BUTTON_DPAD_RIGHT:"D-pad →"}
			return names.get(int(item.code),"Button "+str(int(item.code)))
		"axis":
			var names={JOY_AXIS_LEFT_X:"Left stick X",JOY_AXIS_LEFT_Y:"Left stick Y",JOY_AXIS_RIGHT_X:"Right stick X",JOY_AXIS_RIGHT_Y:"Right stick Y",JOY_AXIS_TRIGGER_LEFT:"Left trigger",JOY_AXIS_TRIGGER_RIGHT:"Right trigger"}
			return names.get(int(item.code),"Axis "+str(int(item.code)))+(" −" if item.value<0 else " +")
	return ""
static func labels(saved: Dictionary, action: String, gamepad: bool=false) -> String:
	var names=PackedStringArray()
	for item in resolved(saved)[action]:
		if (item.kind in ["pad","axis"])==gamepad: names.append(label(item))
	return " / ".join(names)
static func rebind(saved: Dictionary, action: String, gamepad: bool, item: Dictionary) -> Dictionary:
	if not valid(item): return {"error":"That input is reserved or unsupported. Choose another."}
	var map=resolved(saved)
	for other in ACTIONS:
		if other==action: continue
		for bound in map[other]:
			if YBLayoutDocument.same(bound,item): return {"error":"Already used by "+NAMES[ACTIONS.find(other)]+". Rebind that action first."}
	var kept=[]
	for bound in map[action]:
		if (bound.kind in ["pad","axis"])!=gamepad: kept.append(bound)
	kept.append(item);map[action]=kept
	return {"bindings":map}
