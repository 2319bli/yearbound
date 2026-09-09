extends SceneTree
func _initialize() -> void:
	var args=OS.get_cmdline_user_args()
	if args.is_empty(): printerr("Pass a layout JSON path after --");quit(2);return
	var result=YBLayoutDocument.read_layout(args[0])
	if result.has("error"): printerr(result.error);quit(1);return
	var issues=YBLayoutDocument.errors(result.stage,true)
	if not issues.is_empty():
		for issue in issues: printerr(issue)
		quit(1);return
	print("VALID LAYOUT: ",result.stage.id," / ",result.stage.title);quit()
