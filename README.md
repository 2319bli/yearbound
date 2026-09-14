# Yearbound · Foundation 0.17.0

A native desktop platformer about travelling from 1 June to 31 May. **183 stages** are available: the existing 51 calendar dates and **132 additional monthly challenges (11 per month)**. The calendar still reserves 365 dates for the main journey; the extra challenges do not overwrite its future days or boss slots.

## Run the game

Open the accompanying **Yearbound.app** on an Apple silicon Mac. The app includes its runtime and works offline. It is an ad-hoc signed development build, not a notarized public release.

Move with **A/D**, arrows, or **J/L**. **Space/Z** jumps; hold for height. Hold **Shift/C**, aim with WASD/arrows/IJKL, then release for a charge dash. **Esc/P** pauses, **R** restarts at the checkpoint, and **F11** toggles fullscreen. Standard controllers use stick/D-pad, bottom face button to jump, X/West or right shoulder to charge, Start to pause and top face button to restart. Controls are rebindable in Settings. Physical controller hardware has not been tested.

**Explore the calendar** gives immediate access to all 51 calendar stages. **Monthly challenges** opens 132 additional stages, eleven for each month, with separate saved progress. June runs from the welcoming village gate through early-summer countryside, midsummer brightness and longer evenings to the Squallkeeper. The monthly shortcuts along the bottom lead to the other seasonal samples.

## Challenging, readable routes

Version 0.17 replaces the 0.16 object-spam pass. The original 51 calendar maps return to their earlier expert geometry and timing, including the five-arena June boss. The 132 extra stages are rebuilt with clear landing decks, separated obstacles, staged climbs and useful recovery space.

Each monthly challenge has **four connected places and eight mechanisms**: two deliberate crossings per place. Spike beds punish missed transfers; platforms no longer have spikes covering nearly every top and underside. Ordinary upward transfers stay at or below 240 pixels. Moving freight pauses at both docks, and underwater shutters have longer openings.

All 132 monthly routes and the 50 ordinary calendar routes are checked continuously from their entrances using actual inputs, active hazards and the default unassisted movement profile. The June boss has separate full-duration survival and chase checks. These establish a working route; final human pacing and difficulty remain playtest work.

See [CHALLENGE_REBALANCE.md](docs/CHALLENGE_REBALANCE.md) for the changes and check scope. [EXTREME_CHALLENGES.md](docs/EXTREME_CHALLENGES.md) retains the full 132-stage listing and updated authoring guidance.

## Movement, atmosphere and workshop

The base controller, original charge-dash profile with **horizontal multiplier 1.5**, swimming code and **44,160-pixel / 17-station Dash Lab** are byte-for-byte unchanged from 0.15. The lab remains accessible from the title screen. There is no second special ability or new storyline.

Every November challenge is physically underwater, through spacious over/under passages and timed sluices. January challenges use ice; March combines waterfall updrafts with crosswinds. The original 51 maps retain their own pixel-art atlases. The new challenges use editable, original code-native compositions: layered ridges, seasonal architecture, foliage, sunlight, water and weather. They do not borrow another map's bitmap background. All scenery stays in the background pass, behind solid terrain and hazards.

The workshop can copy all 183 stages, preserve mechanism timing and composed scenery, save/open layouts and playtest them with charge dash. Monthly challenge IDs remain fixed when editing a challenge copy; ordinary calendar dates remain editable. [WORKSHOP.md](docs/WORKSHOP.md) covers the general editor.

## Source and building

The public repository is [2319bli/yearbound](https://github.com/2319bli/yearbound). Earlier foundations remain tagged as `v0.11.0` and `v0.12.0`. Git includes editable source, artwork and music; app builds, caches, workshop drafts and player saves are excluded.

Import `project.godot` in **Godot 4.6.2** and press F5. On Apple silicon macOS, run `python3 tools/build_macos.py` to build the standalone app beside the project. It defaults to `/Applications/Godot.app`; set `GODOT_BIN` for another engine executable. Editing the source does not update an already-built app until rebuilt.

- `content/calendar.json`: the 365-day journey and twelve boss slots.
- `content/catalog.json`: available dates, featured monthly shortcuts and the separate challenge order.
- `content/layouts/MM-DD.json`: explicit room blueprints. `MM-XNN.json` files are the monthly challenge stages. Route annotations are historical/design references, not current reachability evidence.
- `tools/build_authored_stages.py`: compiles blueprints into ordinary stage JSON; no seeded geometry or historical Git tag is required.
- `content/stages/`: the data consumed by the game and workshop, including music and art references.
- `scripts/player.gd`, `movement_tuning.gd`, `charge_dash.gd`, `charge_dash_tuning.gd`: shared movement and modular charge ability.
- `scripts/swim_motion.gd`, `swim_tuning.gd`: physical water and tuning.
- `scripts/obstacles.gd`, `obstacle_rules.gd`: seasonal mechanism drawing, swept collision and workshop validation.
- `scripts/platform_motion.gd`, `stage_hazards.gd`: platform paths and shared rendering/contact timing.
- `scripts/june_boss.gd`: five-arena boss progression, attacks, chase and phase checkpoints.
- `scripts/journey_scenery.gd`: per-place scenery, lighting transitions, interiors and optional-area covers.
- `scripts/world.gd`, `world_layer.gd`, `terrain_art.gd`: collision, camera and ordered drawing passes.
- `scripts/layout_editor.gd`, `layout_document.gd`: workshop, validation and compilation.
- `scripts/main.gd`, `audio.gd`, `save.gd`, `controls.gd`: application menus, sound, versioned saves and bindings.

See [AUTHORING.md](docs/AUTHORING.md) for the stage contract and [FOUNDATION.md](docs/FOUNDATION.md) for the architectural intent.

## Saves

On macOS the save is `~/Library/Application Support/Godot/app_userdata/Yearbound/yearbound_v1.json`, with a `.bak` recovery copy. Settings, bindings, completed-day records and saved lab tuning are retained. An unfinished run from an older layout revision resumes at its new entrance because checkpoint and collectible positions have changed. June boss phases save independently. Optional sunmotes use the existing collectible save system.

## Checks for this build

```sh
python3 tools/build_authored_stages.py --check
python3 tools/validate_content.py
```

Set `YEARBOUND_SAVE_DIR` to an empty scratch directory and use an explicit `--log-file` when running `tests/challenge_content.gd` in Godot. It checks all 183 content loads, menu navigation, save/resume, workshop round trips, mechanism warning states and Lab availability. It never moves the player along a route. `tests/challenge_capture.gd` renders representative screenshots using relocation only.

`tests/challenge_routes.gd` checks every monthly challenge from start to finish. `tests/authored_routes.gd` covers ordinary calendar stages; `tests/june_boss_routes.gd` covers the boss. These use normal input actions, keep physics/hazards active and do not relocate the player between route points. Boss survival checks begin on an arena perch, as documented in that suite.

See [VALIDATION.md](docs/VALIDATION.md) and `docs/validation_0_17.json` for the delivered results. Windows/Linux/Intel Mac exports, physical controller testing and final music/pacing remain future work.
