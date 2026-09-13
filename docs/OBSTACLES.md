# Seasonal mechanisms · 0.16.0

The current build contains 183 stages, 787 named places and 28,374 moving or timed mechanisms. The 51 calendar maps have ten times their 0.15 mechanism counts (831 → 8,310). Another 132 monthly challenges add 528 places. See [EXTREME_CHALLENGES.md](EXTREME_CHALLENGES.md).

This difficulty was intentionally not checked for reachability, survival or balance at the owner's request. Original movement, charge dash with horizontal multiplier 1.5, swimming and the 17-station Dash Lab remain unchanged.

## The ten dates introduced in 0.15 (now also hardened)

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

`period` is seconds per cycle and `phase` is a seconds offset. Pulse mechanisms additionally use `safe_seconds` and `warning_seconds`; the remainder is active. Import bounds now allow periods from 0.6 to 20 seconds, an opening of at least 0.08 seconds, a warning of at least 0.12 seconds and at least 0.2 seconds active. The extreme pass usually uses 0.12 seconds open, 0.16 seconds warning and 0.06 seconds extension/retraction. `extension_seconds` is optional (0.02–1); legacy instances default to 0.18. Warnings remain harmless. Each instance can tune these parameters independently:

| Mechanism | Additional fields |
|---|---|
| windmill | `radius`, `blades` (2–4), `rotation_direction` (±1), `thickness` |
| pendulum | `radius` (suspension length), `swing` (radians), `head_radius` |
| press / shutter / geyser | `w`, `h` |
| bloom | `head_radius` |
| sawrail | `travel`, `head_radius` |
| arc | `dx`, `dy` (relative endpoint), `thickness` |

Use `scripts/obstacle_rules.gd` for import bounds and `scripts/obstacles.gd` for the shared behavior. Give every instance a unique `id`. The extreme build deliberately overlaps crossings and constricts landings. Do not widen its openings to satisfy old route bots. Small checkpoint islands remain, but are not a guarantee of a beatable route. Match machinery materials to the day's terrain while preserving the amber edge and dark outline.

Blueprint `route` entries are design/QA annotations, not gameplay automation. They have not been updated into a proof of reachability for 0.16. New challenge annotations use `unverified` explicitly. No traversal or survival tests were run for this extreme build.
