extends SceneTree
var failures = 0
class Probe extends Node2D:
	var spec: Dictionary
	var player_x = 0.0
	var cam = 0.0
	var calm = 0.0
	func _draw() -> void:
		YBMapScenery.background(self, spec, player_x, cam, calm)
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	if ok: print("PASS: ", message)
	else: failures += 1; push_error(message)
func pixel(view: SubViewport, probe: Probe, at: Vector2i = Vector2i(640, 360)) -> Color:
	probe.queue_redraw()
	await process_frame; await process_frame
	RenderingServer.force_draw(); RenderingServer.force_sync()
	return view.get_texture().get_image().get_pixelv(at)
func near(a: Color, b: Color) -> bool:
	return Vector3(a.r - b.r, a.g - b.g, a.b - b.b).length() < .025
func run() -> void:
	var view = SubViewport.new(); view.size = Vector2i(1280, 720)
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS; root.add_child(view)
	var probe = Probe.new(); probe.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST; view.add_child(probe)
	var colors = [Color.RED, Color.GREEN, Color.BLUE, Color.YELLOW, Color.MAGENTA, Color.CYAN, Color.WHITE, Color(.25,.25,.25)]
	for grid in [Vector2i(3, 2), Vector2i(2, 4)]:
		var source = Image.create(grid.x * 128, grid.y * 72, false, Image.FORMAT_RGBA8)
		var regions = []
		for i in grid.x * grid.y:
			source.fill_rect(Rect2i((i % grid.x) * 128, (i / grid.x) * 72, 128, 72), colors[i])
			regions.append({"x":i * 1000, "y":0, "w":1000, "art_cell":i})
		var path = "res://art/maps/render-probe.png"
		YBMapScenery.atlases[path] = ImageTexture.create_from_image(source)
		probe.spec = {"scenery":{"atlas":path, "columns":grid.x, "rows":grid.y, "inset":2}, "journey_regions":regions}
		probe.calm = 0
		for i in regions.size():
			probe.player_x = i * 1000 + 400; probe.cam = i * 1000
			check(near(await pixel(view, probe), colors[i]), "native renderer samples correct cell " + str(i) + " in " + str(grid))
			for corner in [Vector2i(0,0), Vector2i(1279,0), Vector2i(0,719), Vector2i(1279,719)]:
				check(near(await pixel(view, probe, corner), colors[i]), "atlas edges never leak adjacent views")
		# This compact fixture blends over one quarter of its 1000 px room.
		probe.player_x = 1125; probe.cam = 1000
		check(near(await pixel(view, probe), colors[0].lerp(colors[1], .5)), "the physical boundary blends the two correct places")
		probe.player_x = 900
		check(near(await pixel(view, probe), colors[0]), "backtracking restores the earlier place")
		probe.player_x = 1400; probe.spec.scenery.aftermath_cell = regions.size()-1; probe.calm = 1
		check(near(await pixel(view, probe), colors[regions.size()-1]), "aftermath fully replaces the storm without old background bleed")
		probe.position.y = 48; probe.calm = 0
		check(near(await pixel(view, probe, Vector2i(640,0)), colors[1]), "vertical camera offset leaves no uncovered top edge")
		probe.position.y = 0
	YBMapScenery.atlases.clear(); YBMapScenery.recent.clear()
	view.queue_free(); await process_frame
	print("MAP SCENERY RENDER TEST COMPLETE: ", failures, " failures")
	quit(1 if failures else 0)
