# Seasonal obstacle expansion · 0.15.0

The campaign contains 51 playable dates, 259 named places and 831 moving or timed mechanisms. All original dates retain their own scenery and route themes. Nine journeys gain additional elevation-changing transfer galleries; the others combine new mechanisms with their existing climbs, circuits, passages, platforms and weather. The June boss's survival attack intervals are 64% of their previous length, while its full five-arena progression and readable warnings remain.

This is an expert difficulty redesign. “Ten times harder” is a direction for playtesting, not an objectively verified multiplier. Checkpoints and immediate retries remain essential. The original movement, the original dash profile with horizontal multiplier 1.5, physical swimming and the 17-station Dash Lab are preserved.

## Ten new dates

| Date | Stage | Distinct challenge |
|---|---|---|
| 2 July | The Harvest Engine | Crossing revolving windmill sails, then catching raised mill decks between presses. |
| 6 August | Bells Across the Lake | Pendulum bell crossings over the lake; storm arcs punctuate the tower ascent. |
| 22 September | The Acorn Press | Tight canopy passages, presses, thorn blooms and crumbling orchard transfers. |
| 25 October | The Lightning Loom | Telegraphing lightning barriers on ascending storm gantries, with exposed rotor crossings. |
| 7 November | The Drowned Pump | Entirely submerged over/under sluice maze with timed shutters and rail cutters. |
| 21 December | Steam Beneath the Snow | Vent openings, machinery presses and alternating snowy/icy transfer surfaces. |
| 6 January | Clockwork on Ice | Drifting on ice while reading travelling rail cutters and pendulum clearances. |
| 25 February | Thorns at the Thaw | Short-lived crumble catches, expanding thorns and thaw vents. |
| 21 March | The Cascade Machine | Real waterfall updrafts, sideways exits onto high decks and watermill sails. |
| 23 April | The Blossom Switchyard | Boarding climbing freight carriages, jumping off at elevated docks and timing signal shutters. |

Every new stage has four connected places, its own original pixel-art atlas and a distinct temporary musical sketch. Generated PNGs were copied intact from built-in image generation; exact prompts, hashes and grids are in `art/maps/PROVENANCE_EXPANSION.json`. Scores can be regenerated with `tools/synthesize_expansion_scores.py` and replaced via each stage's music reference.

## Reading the mechanisms

Rotors and pendulums move continuously. The moving sails and toothed heads are dangerous; their mounting structures are scenery. Other mechanisms cycle through an open interval, an amber warning, an active red interval and retraction. Amber preview lines and rings are harmless. Near-camera activation gives a brief sound cue. Pause freezes all mechanism timing.

Active shapes are shared between drawing, ordinary contact and swept dash collision. A long dash cannot skip through a closed shutter. Vents here are damaging steam; the blue waterfall lift zones in March use the existing physical updraft mechanic.

## Editing

Edit `content/layouts/MM-DD.json`, then run `python3 tools/build_authored_stages.py --write`. Each section owns explicit local coordinates; its origin is added by the compiler. There is no runtime generator or historical Git dependency. The workshop preserves mechanism data when copying, moving, saving and playtesting a day. Detailed mechanism placement and parameters currently use JSON, rather than a new workshop brush panel.

Example windmill hazard:

```json
{
  "type": "mechanism", "mechanism": "windmill", "id": "my-day-mill-1",
  "x": 1200, "y": 420, "period": 7.2, "phase": 0,
  "radius": 132, "blades": 3, "rotation_direction": 1,
  "thickness": 7, "color": "c5ad79"
}
```

`period` is seconds per cycle and `phase` is a seconds offset. Pulse mechanisms additionally use `safe_seconds` and `warning_seconds`; the remainder is active. Use at least 0.65 seconds open and 0.5 seconds of warning. Shared extension/retraction takes 0.18 seconds. Each instance can tune these parameters independently:

| Mechanism | Additional fields |
|---|---|
| windmill | `radius`, `blades` (2–4), `rotation_direction` (±1), `thickness` |
| pendulum | `radius` (suspension length), `swing` (radians), `head_radius` |
| press / shutter / geyser | `w`, `h` |
| bloom | `head_radius` |
| sawrail | `travel`, `head_radius` |
| arc | `dx`, `dy` (relative endpoint), `thickness` |

Use `scripts/obstacle_rules.gd` for import bounds and `scripts/obstacles.gd` for the shared behavior. Give every instance a unique `id`. Place a safe observation/arrival area before an active crossing; don't let the next mechanism invade a jump's landing bay. Match machinery materials to the day's terrain while preserving the amber edge and dark outline.

Blueprint `route` entries are QA waypoints, not gameplay automation. `mechanism` entries ask the test driver to observe timing and cross using real inputs. All movement and hazards continue running normally. These checks establish reachability; they cannot establish enjoyable human difficulty or final five-minute pacing.
