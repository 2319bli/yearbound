# Seasonal mechanisms · 0.17.0

Version 0.17 uses 1,887 mechanisms across 183 stages: the earlier 831 calendar mechanisms and 1,056 carefully spaced challenge crossings. This replaces 0.16's 28,374 overlapping machines. The original 51 routes and boss timing are restored; the 132 additional stages use two mechanisms per place and clear landing areas. See [CHALLENGE_REBALANCE.md](CHALLENGE_REBALANCE.md).

The latest request explicitly restores reachability testing. Continuous route checks use normal inputs and active hazards. Core movement and the Dash Lab are unchanged.

## The ten dates introduced in 0.15 (restored to their earlier expert layouts)

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

`period` is seconds per cycle and `phase` is a seconds offset. Pulse mechanisms additionally use `safe_seconds` and `warning_seconds`; the remainder is active. Import bounds now allow periods from 0.6 to 20 seconds, an opening of at least 0.08 seconds, a warning of at least 0.12 seconds and at least 0.2 seconds active. Current monthly challenges use at least 1.4 seconds open, 0.75 seconds warning and 0.18 seconds extension/retraction; submerged shutters use 2.2 seconds open and 0.85 seconds warning. `extension_seconds` is optional (0.02–1); legacy instances default to 0.18. Warnings remain harmless. Each instance can tune these parameters independently:

| Mechanism | Additional fields |
|---|---|
| windmill | `radius`, `blades` (2–4), `rotation_direction` (±1), `thickness` |
| pendulum | `radius` (suspension length), `swing` (radians), `head_radius` |
| press / shutter / geyser | `w`, `h` |
| bloom | `head_radius` |
| sawrail | `travel`, `head_radius` |
| arc | `dx`, `dy` (relative endpoint), `thickness` |

Use `scripts/obstacle_rules.gd` for import bounds and `scripts/obstacles.gd` for the shared behavior. Give every instance a unique `id`. Keep machinery away from landing/departure edges, give each crossing its own approach and recovery area, and verify that a complete route is possible with the approved player settings. Match machinery materials to the day's terrain while preserving the amber edge and dark outline.

Blueprint `route` entries are design/QA annotations, not gameplay automation. In 0.17 they describe verified paths. The test driver performs the actual jumps, dashes, swims, platform rides and timed crossings using ordinary input actions. Do not change a route and retain its old verification claim without rerunning the relevant check.
