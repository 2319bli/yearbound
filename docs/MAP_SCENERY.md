# Custom map scenery · 0.14.0

Every one of the 41 playable dates has its own original pixel-art atlas. All 219 named places select different views within their map's artwork. The June boss has an additional clearing-sky aftermath view. No finished date borrows another date's landscape or cycles through the small old biome library.

The map's scenery follows its actual route: the watermill grows closer before the player enters its gear-filled interior; the glasshouse moves from formal gardens through palms and maintenance tunnels to the roof. Orchard and ridge views gain altitude, riverbanks change width and depth, the Garden Maze is surrounded by clipped hedge corridors, and 8/29 June progress into night. November's views are all physically underwater, while the spring, thaw and deep-winter sets depict their own waterways and structures.

## Rendering and readability

The game samples a single atlas cell at a time, with a smooth spatial blend over up to the first 300 pixels of the next place. Backtracking restores the earlier view. Local parallax is bounded, with no periodic reversal or full-map picture cycling. The stage camera can rise without exposing the edge of a picture. Lighting is part of the artwork, so interiors are not an outdoor landscape covered with a dark rectangle.

The existing grade reduces background contrast near the gameplay plane. Native terrain, hazards, the player, local scenery and weather keep their existing separate drawing layers. No generated picture contains the game's collision blocks or hazards. Broad code-drawn landmark placeholders are suppressed where the atlas now paints those buildings; local plants, wind, spray and lanterns remain animated. An explicitly authored decoration can set `draw_over_atlas: true` to opt back in. The renderer retains at most two map atlases, independently of the smaller shared prop cache. Original source PNGs are preserved intact; the engine crops their cells during drawing.

The layouts, checkpoints, movement, charge/swimming settings, music and 17-station Dash Lab are unchanged. This visual update does not invalidate current runs.

## Adding or editing a map's art

Place the artwork in `art/maps/MM-DD.png`. Use equal 16:9 cells in a regular grid. The current June atlases have three columns and two rows; other-month atlases have two columns and four rows. Extra cells are reserved local views, except June 30's final cell, which is used for the aftermath.

In the day blueprint, add:

```json
"scenery": {
  "atlas": "res://art/maps/06-06.png",
  "columns": 3,
  "rows": 2,
  "inset": 2
}
```

Each section's existing `visual` object selects its own zero-based `art_cell`, reading left to right and then down. For example, the mill interior uses cell 3. Retain `place` and `light` because local decoration, authoring tools and older exports use them. Boss scenery may add `aftermath_cell` to select its clearing-sky view.

Run `python3 tools/build_authored_stages.py --write`, then `python3 tools/validate_content.py`. The compiler preserves exact layout geometry and writes the scenery metadata into each stage. Import the new PNG in Godot before playing or exporting. Ordinary workshop copying, export/open and playtesting retain the atlas and cell assignments; blank days start without another map's atlas. Detailed art assignment remains a JSON workflow.

Do not reuse another day’s artwork merely because its place has the same broad label. A new orchard day needs its own viewpoint, architecture, canopy, geography and lighting. Intentional callbacks can be explicitly authored later.

## Provenance

All new atlases were generated with the built-in `image_gen` tool for this project. Exact prompts, map/section names, atlas grids, dimensions and final file hashes are recorded in `art/maps/PROVENANCE.json`. There was no CLI/API fallback and no third-party image download. The old background files remain available for earlier exports and source history.
