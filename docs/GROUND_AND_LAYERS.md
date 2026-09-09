# Ground and layering · 0.5

All six sample stages now use a single continuous floor, flat at Y=620 in exploration stages and Y=600 in the June boss arena. The ground fills the screen below that edge. The challenge sits above it: solid logs, hay bales and stone obstacles, bramble patches, ice strips, elevated timber walks, leaf bridges, springs, moving lifts and the existing boss patterns.

June's opening is rebuilt as a countryside obstacle course with optional upper routes. The other examples retain their seasonal mechanics over a continuous foundation. In particular, falling from an upper route now returns the player to the base trail rather than automatically dropping into a gap. Hazards still trigger checkpoint retries. Difficulty and optional-route rewards can be developed further through human playtesting.

## Content contract

Set `ground` to `{"y":620}` in a stage. The world creates one solid body spanning the stage and draws only the visible portion of its surface and earth. This avoids seams, gaps and drawing work proportional to the length of the entire floor.

Keep above-ground collision in `platforms`. A `block` uses `material: "log"`, `"hay"` or `"stone"`; its bottom should meet the floor. These materials have simple top edges and distinct faces. Thin wood and seasonal platforms retain their existing mechanics. Decorative support posts are drawn behind actors and are not collision walls.

A `bramble` hazard defines `x`, `y`, `w` and `h`. Its pale tips identify the dangerous top. Leave room overhead for the intended jump; a patch under a low platform can become impassable even when its width looks reasonable. The validator checks checkpoints and exits against solid obstacles. `tests/ground_layout.gd` checks the continuous base collision independently of the obstacles.

Checkpoint and collectible ordering is preserved through this revision. Lanterns move to the new floor and mote heights follow the new routes. Existing saves resume at the corresponding checkpoint, preserving collected identities, elapsed time, deaths and completed-day records. Snapshots also record `layout_revision` for later content migrations.

## Explicit world layers

The old monolithic drawing pass is split into named `YBWorldLayer` nodes. They share the world camera and sit below the pixel composite and UI. Drawing methods live in `world.gd`; actor physics stays in `player.gd`.

| Order | Content |
|---|---|
| Background canvas | Seasonal landscape, distant haze and birds |
| Backdrop −20 | Legacy water backdrop for stages without a base floor |
| Scenery −10 | Trees, hedges, fences and muted support posts |
| Environment −5 | Waterfalls, current zones and local wind marks |
| Terrain 0 | Continuous floor, ice strips and above-ground collision surfaces |
| Markers 10 | Motes, checkpoint lanterns and exit gate |
| Player 20 | Traveller |
| Hazards 25 | Brambles, moving hazards, boss and attack telegraphs |
| Effects 30 | Particles and seasonal weather |
| Foreground 35 | Low framing plants and explicitly authored front decoration |
| Signs 40 | World hints |
| Pixel composite canvas 2 | Consistent world pixel grid |
| UI canvas 3 | HUD, menus and transitions |

Weather now goes through the same pixel composite as the world instead of being drawn in the UI. Waterfalls and current overlays sit behind collision geometry and the player. The front foliage stays below the walkable surface. Avoid moving background decoration into an actor or hazard layer to solve individual overlaps; keep the hierarchy consistent.

The native part of `tests/ground_layout.gd` adds overlapping colour probes to the actual passes and checks rendered pixels for scenery/terrain/player/hazard/foreground/UI ordering. Run it without `--headless` for those visual checks. Headless runs skip drawing work and cover the floor, hazards and save-resume cases.
