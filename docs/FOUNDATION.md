# Yearbound · foundation plan

Native Godot 4.6 / GDScript. A 1280×720 logical canvas scales to desktop windows and fullscreen. No network or web runtime.

## Boundaries
- `layout_editor.gd` / `layout_document.gd`: the native workshop, square-grid model, undo history, exports and authoring validation.
- `main.gd`: application state, menus, calendar, HUD, transitions, input focus.
- `player.gd`: physics controller and a modular ability interface; no stage-specific rules.
- `world.gd`: stage instantiation, collisions, environmental mechanics, checkpoints and survival boss.
- `world_layer.gd`: explicit camera-bound drawing passes; terrain, scenery, hazards and the actor have independent depth.
- `landscape.gd`: pixel-art landscape plates, textured terrain and animated seasonal detail; collision geometry remains authoritative.
- `audio.gd`: independent music and effect buses, track replacement and synthesis.
- `save.gd`: versioned local JSON, backup recovery, settings and per-date results.
- `content/calendar.json`: all 365 dates in June–May order, month themes and boss markers.
- `content/stages/*.json`: authored terrain, moving platforms, collectibles, hazards, checkpoints, environmental zones, music and visual identity.

## Slice scope
Twenty-one compact playable reference stages and a separate seventeen-station charge-dash laboratory. Stage durations are samples, not a claim that all are five minutes. Every month has a playable date available from the calendar. Unbuilt days are clearly marked. Collect optional sunmotes, activate checkpoint lanterns, reach the gate. No storyline is assigned. Charge dash is enabled in the playable campaign and retains its laboratory for tuning; no second major gimmick is included. See `MONTHLY_SAMPLES.md` for the eight newest monthly routes.

1 June: a continuous country trail with logs, hay bales, stones, brambles and optional raised timber routes.
15 June: rotating mill hazards, timed moving platforms and flower springs.
30 June: three-phase storm-bird arena; survival safely drains its resolve over 105 seconds.
12 October: gust corridors, crumbling leaf platforms and sweeping thorn pods.
18 January: ice momentum along a flat snowfield, raised stone obstacles and falling icicles.
9 March: waterfall shafts, strong updrafts and rushing water.

All six samples use 48-pixel square terrain blocks and continuous flat ground beneath their seasonal obstacles and elevated routes. Workshop layouts can edit the floor itself and introduce pits. Ground height is stage data; the renderer and collision system share that value.

## Implementation order
Controller and data validation → play loop and checkpoint/save contracts → six stage layouts → seasonal rendering → complete application UI → audio → native packaging → headless and live verification.

## Future scale
A stage is keyed by `MM-DD`, independent of calendar position. Each has its own music reference and palette. New mechanics should register a named type with explicit parameters, rather than branch on date. The built-in workshop emits the same authored JSON schema used by the game; adding a day does not require a new runtime system. Chunk streaming, localization, narrative events and boss subclasses can be added behind these boundaries. Never auto-generate finished daily levels from a palette swap.
