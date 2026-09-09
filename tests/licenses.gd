extends SceneTree
func _initialize() -> void:
	var f=FileAccess.open("res://docs/ENGINE_NOTICES.txt",FileAccess.WRITE)
	f.store_string(Engine.get_license_text()+"\n\nTHIRD PARTY COMPONENTS\n\n"+JSON.stringify(Engine.get_copyright_info(),"\t")+"\n\nTHIRD PARTY LICENSE TEXTS\n\n")
	var licenses=Engine.get_license_info()
	for name in licenses: f.store_string(name+"\n\n"+licenses[name]+"\n\n")
	f.close()
	quit()
