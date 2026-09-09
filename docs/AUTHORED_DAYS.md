# Authored campaign layouts · 0.13.0

There are 41 playable dates. All 30 June journeys follow the five-place chapter described in [JUNE_CHAPTER.md](JUNE_CHAPTER.md). The other months retain their rebuilt routes and original seasonal identities.

## Other months

| Day | Gameplay | Length (px) | Spike entries |
|---|---|---:|---:|
| 07-16 | Long wind-driven runs alternate with stone braking bays and high harvest walks. | 20,544 | 128 |
| 08-23 | Read the weather from cover, then board the ferry and transfer across the open lake. | 19,008 | 283 |
| 09-14 | Stable trunks separate brittle bridges; long stationary charges are costly on leaves. | 20,064 | 289 |
| 10-12 | Use roofed refuges to read lightning; travel during the dark interval. | 23,136 | 392 |
| 11-19 | Swim through offset wall openings, manage currents, and change depth throughout the route. | 17,376 | 104 |
| 12-08 | Pause under cabin roofs, read falling-ice warnings, then cross the open snow. | 19,680 | 238 |
| 01-18 | Long slick runs build momentum; small rock islands set up each precision launch. | 21,984 | 204 |
| 02-17 | Cracked pale shelves are both slippery and fragile; exposed stone is the place to prepare. | 20,928 | 227 |
| 03-09 | Rising spray carries the player through tall shafts; control the sideways exit onto dry ledges. | 21,984 | 381 |
| 04-11 | Move through rain-washed archways, choosing low jumps or diagonal launches to fit the openings. | 19,968 | 410 |
| 05-24 | A deliberate callback course links flower bounces, fragile trellises, lift transfers and rain arches. | 23,712 | 387 |

Each ordinary day introduces an obstacle or movement decision on the first screen. May intentionally combines earlier mechanics as a culmination. Geometry uses 48-pixel blocks above a continuous flat base floor. All days retain at least 50 actual spike placements; no decorative tooth count is substituted for contact hazards. June prioritizes the requested five-place journeys over preserving the previous expansion’s exact lengths.

## Content pipeline

1. Edit `content/layouts/MM-DD.json`. Rooms contain explicit local platforms, hazards, zones, decorations, signs, checkpoints, collectibles and QA route points. `origin` locates the room. There are no seeded room recipes, mirrored extensions or automatic hazard fillers in the compiler.
2. Bump `revision` when changed geometry invalidates saved checkpoint or collectible indices.
3. Run `python3 tools/build_authored_stages.py MM-DD --write`, then `python3 tools/validate_content.py`. Omit the day to compile all layouts and refresh `challenge_report.json`. Without `--write`, compilation reports measurements. `--check` fails on stale compiled geometry or a stale complete report.
4. Play in Godot, copy into the workshop for visual editing, or rebuild the desktop app.

The runtime reads `content/stages/`. Compilation preserves soundtrack, background, seasonal metadata and ground settings; it translates explicit geometry and splits fragile spans into independent tiles. The source ZIP compiles without Git or historical tags.

Workshop exports remain normal stage JSON. If a compiled day is edited directly or in the workshop, copy its geometry changes back into the blueprint before recompiling, or maintain the stage directly and remove its blueprint. Compilation replaces baked geometry. Revise stale QA routes after editing; route hints never control the player.

## Shared environmental parameters

- Moving platforms: `motion_path` is a closed list of offsets, relative to the platform’s grid position. `motion_seconds` gives a loop duration; optional `motion_phase` offsets the cycle. Repeated points create a dwell. Legacy sine-axis movement remains supported.
- Timed lightning: rectangular `storm` hazards have `period`, `phase`, `active_seconds` and `warning_seconds`. Only the final active interval hurts; the preceding amber warning is safe. Rendering and collision share timing code.
- Local falling ice: `local: true` anchors an icicle to its authored `y`, with `warning_seconds`, `floor_y` and optional `fall_acceleration`.
- Ice surfaces: `surface: "ice"` makes another platform kind slippery. February combines it with independent crumble tiles; July uses polished wooden runs.
- Updrafts: `visual: "wind"` renders rising air; the default displays waterfall spray. November remains physically underwater, with swim-safe checkpoints and currents.
- June: `visual` environment/light fields compile into spatially blended `journey_regions`. `secret_areas` describe optional vine covers and side chambers. The boss has five explicit arena definitions.

These parameters survive workshop save/open and playtest. Detailed inspectors remain future work; edit timing and region fields in JSON.

The player controller, movement/dash/swimming tuning and 17-station Dash Lab are unchanged. Fast authored tracks now use a movement-aware contact tolerance so diagonal lifts carry the player reliably. Older unfinished runs restart at the new entrance; completed-day records and settings remain.
