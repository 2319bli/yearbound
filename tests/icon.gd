extends SceneTree
func _initialize() -> void:
	var im=Image.new()
	im.load_svg_from_string(FileAccess.get_file_as_string("res://icon.svg"),2.0)
	im.save_png(OS.get_environment("YEARBOUND_CAPTURE_DIR").path_join("icon.png"))
	quit()
