# Underwater November · 0.10.0

**19 November — Lanterns Beneath the Flood** is now physically underwater. Its surface is at y=144; the continuous riverbed remains at y=624. Twelve block structures alternate high swim passages with deep passages beneath sunken timber. Two lantern checkpoints retain their positions and saved indices.

Swim in all directions with WASD, arrows, IJKL, a controller stick or D-pad. Holding Jump also swims upward. Down takes precedence if Jump is held while diving. These use the existing rebindable movement, vertical-aim and jump actions. Release movement to decelerate and float gently towards a stable waterline; hold Jump to breach it. There is no oxygen timer or drowning penalty. Brambles and moving debris still cause a normal checkpoint retry.

## Movement and dash

The dry controller and charge-dash resource remain separate. Water uses continuous drag, normalized directional thrust, buoyancy and finite drift from currents. Entering water reduces incoming velocity; leaving it returns to normal gravity and movement. Swimming, recovery and animation pause with gameplay.

Charge dash retains **every original default with horizontal multiplier 1.5**. The water applies drag to the resulting burst; it does not rewrite the dash profile. Afterwards, swim steering and drag take over immediately. A 0.65-second recovery while not charging/dashing restores the airborne dash allowance in water. The HUD shows recovery. Existing saved tuning remains respected, and the 17-station dry Dash Lab stays available.

A stationary full horizontal burst measures approximately 227 px underwater versus 310 px in air at 60 physics ticks/s. These are burst distances, not the full journey after release. Swim speed is approximately 210 px/s horizontally and 190 px/s vertically; diagonal input is normalized. Idle buoyancy rises at up to 26 px/s and diminishes near the surface.

## Tune or author water

All swim values are exposed in `scripts/swim_tuning.gd` and the Godot resource `content/swimming.tres`: swim speed, response/drag, buoyancy, entry momentum, dash drag/recovery, surface breach and immersion thresholds. They do not modify `movement.tres` or `charge_dash.tres`.

Opt a rectangle into physical water in a stage's `zones` list:

```json
{"type":"water","x":0,"y":144,"w":7680,"h":576,"swimmable":true}
```

Water selection uses overlap with the actual player collider and different enter/exit thresholds to prevent waterline flicker. Decorative `water` without `swimmable: true` retains its former behavior, including June's streams. Water rectangles do not add collision; block geometry defines walls and floors.

Current zones retain their existing force format. Use `"submerged": true` to draw current streaks without the old shallow-water fill. Force is acceleration; drag creates a finite terminal drift. November's final opposing current is `[-300,40]` and remains swimmable without dash.

The workshop preserves physical water and current metadata when copying, exporting and reopening November. Its existing current brush remains available; author new water volumes in JSON for now. Physical-water painting is not a new editor tool in this revision.

## Presentation and validation

The surface, rear depth bands and light shafts sit behind terrain. Sparse bubbles and a light foreground wash preserve player, hazard and platform outlines. Rain stops above a full-width water surface, the character paddles while swimming, and the music is low-pass filtered underwater. Effect/music volume settings remain in force.

The swimming suite covers buoyancy, directional movement, normalized diagonals, drag, currents, surface stability, breaching/re-entry, walls/ceilings, dash resistance/refill, pause/reset, underwater checkpoint/death recovery and workshop metadata. An input-driven traversal completes all three passages, both lanterns and the gate with zero deaths and no dash requirement. This establishes reachability; human difficulty and feel still benefit from playtesting.
