class_name YBMapScenery
extends RefCounted
## A map owns its artwork. Named places select cells, never a shared biome picture.
## Atlases stay intact on disk; drawing crops a cell without resampling the source.
const CACHE_LIMIT = 2
const PAINTED_LANDMARKS = ["pavilion", "station", "waterwheel", "mill_tower", "hay_barn", "glasshouse_bay", "boathouse", "winter_cabin", "crossing_bridge", "brook_arch"]
static var atlases: Dictionary = {}
static var recent: Array[String] = []

static func texture(path: String) -> Texture2D:
	if not atlases.has(path):
		if not ResourceLoader.exists(path): return null
		atlases[path] = load(path)
	recent.erase(path)
	recent.append(path)
	while recent.size() > CACHE_LIMIT:
		atlases.erase(recent.pop_front())
	return atlases[path]

static func cell_rect(size: Vector2, art: Dictionary, cell: int) -> Rect2:
	var columns = int(art.columns)
	var rows = int(art.rows)
	var col = cell % columns
	var row = cell / columns
	# Rounded boundaries accommodate image widths not divisible by the grid.
	var left = roundf(size.x * col / columns)
	var right = roundf(size.x * (col + 1) / columns)
	var top = roundf(size.y * row / rows)
	var bottom = roundf(size.y * (row + 1) / rows)
	return Rect2(left, top, right - left, bottom - top).grow(-float(art.get("inset", 2)))

static func selection(regions: Array, x: float) -> Dictionary:
	var index = YBJourneyScenery.index_at(regions, x)
	var region: Dictionary = regions[index]
	var blend = clampf((x - float(region.x)) / minf(300, float(region.w) * .25), 0, 1) if index else 1.0
	return {"index": index, "previous": maxi(0, index - 1), "blend": smoothstep(0, 1, blend)}

static func draw_cell(n: Node2D, atlas: Texture2D, art: Dictionary, region: Dictionary, cam: float, alpha: float, cell: int = -1) -> void:
	var progress = clampf((cam - float(region.x) + 320) / maxf(1, float(region.w)), 0, 1)
	var destination = Rect2(-84 - progress * 64, -66, 1472, 828)
	var source = cell_rect(atlas.get_size(), art, int(region.art_cell) if cell < 0 else cell)
	n.draw_texture_rect_region(atlas, destination, source, Color(1, 1, 1, alpha), false, true)

static func background(n: Node2D, spec: Dictionary, player_x: float, cam: float, calm: float = 0) -> bool:
	var art: Dictionary = spec.get("scenery", {})
	var regions: Array = spec.get("journey_regions", [])
	if art.is_empty() or regions.is_empty(): return false
	var atlas = texture(str(art.atlas))
	if not atlas: return false
	var view = selection(regions, player_x)
	var region: Dictionary = regions[view.index]
	if view.blend < 1:
		draw_cell(n, atlas, art, regions[view.previous], cam, 1)
	draw_cell(n, atlas, art, region, cam, view.blend)
	if calm > 0 and art.has("aftermath_cell"):
		draw_cell(n, atlas, art, region, cam, calm, int(art.aftermath_cell))
	return true
