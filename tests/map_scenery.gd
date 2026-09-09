extends SceneTree
var failures = 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	if ok: print("PASS: ", message)
	else: failures += 1; push_error(message)
func run() -> void:
	var catalog = JSON.parse_string(FileAccess.get_file_as_string("res://content/catalog.json"))
	var paths = {}
	var cells = 0
	for id in catalog.stages:
		var stage = JSON.parse_string(FileAccess.get_file_as_string("res://content/stages/" + id + ".json"))
		check(stage.has("scenery"), id + " owns an artwork set")
		if not stage.has("scenery"): continue
		var art = stage.scenery
		check(not paths.has(art.atlas), id + " does not borrow another map's artwork")
		paths[art.atlas] = true
		var atlas = YBMapScenery.texture(art.atlas)
		check(atlas != null, id + " atlas is included and loads")
		if not atlas: continue
		check(YBMapScenery.atlases.size() <= 2, "map texture retention is bounded")
		var image = atlas.get_image()
		var used = {}
		var fingerprints = {}
		for region in stage.journey_regions:
			var cell = int(region.art_cell)
			check(not used.has(cell), id + "/" + region.name + " has its own view")
			used[cell] = true
			var rect = YBMapScenery.cell_rect(atlas.get_size(), art, cell)
			check(Rect2(Vector2.ZERO, atlas.get_size()).encloses(rect) and rect.size.x >= 450 and rect.size.y >= 250, "view crops stay inside a substantial atlas cell")
			var data = image.get_region(Rect2i(rect)).get_data()
			var hash = HashingContext.new(); hash.start(HashingContext.HASH_SHA256); hash.update(data)
			var fingerprint = hash.finish().hex_encode()
			check(not fingerprints.has(fingerprint), id + " contains distinct image content")
			fingerprints[fingerprint] = true
			cells += 1
		var document = YBLayoutDocument.new(); document.load_stage(stage)
		var copy = document.compile()
		check(YBLayoutDocument.errors(copy, true).is_empty(), id + " artwork validates in the workshop")
		check(copy.scenery == stage.scenery and copy.journey_regions == stage.journey_regions, id + " workshop preserves its exact art and room selection")
		var regions = stage.journey_regions
		for i in range(1, regions.size()):
			var x = float(regions[i].x)
			check(YBMapScenery.selection(regions, x - 1).index == i - 1 and YBMapScenery.selection(regions, x + 301).index == i, "forward travel and backtracking select the physical place")
	check(paths.size() == 41 and cells == 219, "every playable map and all 219 named places have custom art")
	var sample = JSON.parse_string(FileAccess.get_file_as_string("res://content/stages/06-01.json"))
	var bad = sample.duplicate(true); bad.scenery.columns = 0
	check(not YBLayoutDocument.errors(bad, false).is_empty(), "invalid atlas dimensions are rejected")
	bad = sample.duplicate(true); bad.journey_regions[0].art_cell = 6
	check(not YBLayoutDocument.errors(bad, false).is_empty(), "out-of-atlas cells are rejected")
	bad = sample.duplicate(true); bad.scenery.atlas = "res://art/maps/missing.png"
	check(not YBLayoutDocument.errors(bad, false).is_empty(), "missing artwork is rejected")
	check(not YBLayoutDocument.blank().has("scenery"), "new workshop days do not inherit June's artwork")
	var boss = JSON.parse_string(FileAccess.get_file_as_string("res://content/stages/06-30.json"))
	check(boss.scenery.aftermath_cell == 5 and not boss.journey_regions.any(func(r): return r.art_cell == 5), "the clearing sky has a dedicated aftermath view")
	print("MAP SCENERY TEST COMPLETE: ", failures, " failures")
	quit(1 if failures else 0)
