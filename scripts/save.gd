class_name YBSave
extends RefCounted

var PATH = "user://yearbound_v1.json"
var data: Dictionary = {"version":1, "last_stage":"06-01", "results":{}, "settings":{"music":0.65, "effects":0.75, "fullscreen":false, "reduced_motion":false, "assist":false, "bindings":{}, "dash_tuning":{}}}

func _init() -> void:
	if not OS.get_environment("YEARBOUND_SAVE_DIR").is_empty():
		PATH = OS.get_environment("YEARBOUND_SAVE_DIR").path_join("yearbound_v1.json")
	for path in [PATH, PATH + ".bak"]:
		if not FileAccess.file_exists(path): continue
		var parser = JSON.new()
		if parser.parse(FileAccess.get_file_as_string(path)) != OK: continue
		var parsed = parser.data
		if parsed is Dictionary and parsed.get("version") == 1 and parsed.get("results") is Dictionary:
			data.last_stage = parsed.get("last_stage", "06-01")
			data["dash_profile_revision"] = parsed.get("dash_profile_revision",0)
			data.results = parsed.results
			if parsed.get("run") is Dictionary: data["run"] = parsed.run
			if parsed.get("settings") is Dictionary:
				for key in data.settings:
					if typeof(parsed.settings.get(key)) == typeof(data.settings[key]): data.settings[key] = parsed.settings[key]
			break
	# Restore original tuning plus horizontal 1.5 once, clearing saved lab overrides.
	# Progress, bindings and unrelated settings remain intact; future lab edits persist.
	if int(data.get("dash_profile_revision",0)) < 2:
		data.settings.dash_tuning={}
		data["dash_profile_revision"]=2
		if FileAccess.file_exists(PATH): persist()

func persist() -> bool:
	var file = FileAccess.open(PATH + ".tmp", FileAccess.WRITE)
	if file == null: return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	if FileAccess.file_exists(PATH):
		DirAccess.copy_absolute(PATH, PATH + ".bak")
	return DirAccess.rename_absolute(PATH + ".tmp", PATH) == OK

func record(id: String, seconds: float, motes: int, deaths: int, assisted: bool) -> void:
	var previous: Dictionary = data.results.get(id, {})
	data.results[id] = {"complete":true, "best_time":minf(seconds, previous.get("best_time", seconds)), "motes":maxi(motes, previous.get("motes", 0)), "fewest_deaths":mini(deaths, previous.get("fewest_deaths", deaths)), "assisted":assisted if previous.is_empty() else previous.get("assisted", false) and assisted}
	persist()
