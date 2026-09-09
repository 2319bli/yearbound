# Yearbound · Foundation 0.13.0

A native desktop platformer about travelling from 1 June to 31 May. **All 30 June dates are playable**, alongside eleven other-month samples. June now follows a chapter-wide design: five substantial connected places per day, with changing scenery, light, elevation and gameplay. The other 324 calendar dates remain unbuilt.

## Run the game

Open the accompanying **Yearbound.app** on an Apple silicon Mac. The app includes its runtime and works offline. It is an ad-hoc signed development build, not a notarized public release.

Move with **A/D**, arrows, or **J/L**. **Space/Z** jumps; hold for height. Hold **Shift/C**, aim with WASD/arrows/IJKL, then release for a charge dash. **Esc/P** pauses, **R** restarts at the checkpoint, and **F11** toggles fullscreen. Standard controllers use stick/D-pad, bottom face button to jump, X/West or right shoulder to charge, Start to pause and top face button to restart. Controls are rebindable in Settings. Physical controller hardware has not been tested.

**Explore the calendar** gives immediate access to all 41 samples. June runs from the welcoming village gate through early-summer countryside, midsummer brightness and longer evenings to the Squallkeeper. The monthly shortcuts along the bottom lead to the other seasonal samples.

## This chapter

Each ordinary June stage contains five large places, not five single-screen challenges. Routes include open fields, interiors, low passages, climbs that carry their altitude forward, long descents, moving cargo, waterwheel circuits, windmill hoists, rivers, spring chains and backtracking. Room names in the HUD identify the current place. Backgrounds blend between environments; 8 and 29 June visibly progress into night. The Garden Maze includes returning corridors and optional side chambers beneath fading ivy.

30 June is a five-arena survival boss: an introductory dodge pattern, higher terraces, an advancing-storm chase, crossing attacks and a final squall followed by a clearing sky. Its health decreases through successful survival or chase progress. Completed phases remain completed after retries; cleared gates connect the arenas physically. There is no melee combat.

The supplied 1–22 June music is included. Dates 23–29 use distinct temporary synthesized scores pending supplied compositions. The existing boss and other-month music remain. See [JUNE_CHAPTER.md](docs/JUNE_CHAPTER.md) for every day’s route and [AUTHORED_DAYS.md](docs/AUTHORED_DAYS.md) for the other months and content pipeline.

## Movement, lab and workshop

The base player controller, original charge-dash profile with **horizontal multiplier 1.5**, and underwater profile are unchanged. The **Charge dash lab** remains 44,160 pixels long with 17 stations. Pause there to select a station, adjust live tuning or export a profile. Saved tuning applies to campaign stages when entered. Lab attempts stay separate from campaign progress. See [CHARGE_DASH.md](docs/CHARGE_DASH.md).

**19 November** is physically underwater. WASD/arrows/IJKL or the stick swims; Jump rises and Down dives. Water adds buoyancy, drag and dash recovery. There is no breath timer. See [UNDERWATER.md](docs/UNDERWATER.md).

The **Layout workshop** can copy, edit and playtest every sample. It retains charge dash, selectable height, four spike directions, undo/redo, fills, pan/zoom and draft recovery. Authored platform tracks, timed hazards, journey environments and secret metadata survive save/open and playtest. Detailed environment, track and boss settings remain JSON fields. New blank days choose the next unfinished date, 1 July. See [WORKSHOP.md](docs/WORKSHOP.md).

## Source and building

The public repository is [2319bli/yearbound](https://github.com/2319bli/yearbound). Earlier foundations remain tagged as `v0.11.0` and `v0.12.0`. Git includes editable source, artwork and music; app builds, caches, workshop drafts and player saves are excluded.

Import `project.godot` in **Godot 4.6.2** and press F5. On Apple silicon macOS, run `python3 tools/build_macos.py` to build the standalone app beside the project. It defaults to `/Applications/Godot.app`; set `GODOT_BIN` for another engine executable. Editing the source does not update an already-built app until rebuilt.

- `content/calendar.json`: the 365-day journey and twelve boss slots.
- `content/catalog.json`: available dates and featured monthly shortcuts.
- `content/layouts/MM-DD.json`: explicit per-day room blueprints, environments, optional areas and QA routes.
- `tools/build_authored_stages.py`: compiles blueprints into ordinary stage JSON; no seeded geometry or historical Git tag is required.
- `content/stages/`: the data consumed by the game and workshop, including music and art references.
- `scripts/player.gd`, `movement_tuning.gd`, `charge_dash.gd`, `charge_dash_tuning.gd`: shared movement and modular charge ability.
- `scripts/swim_motion.gd`, `swim_tuning.gd`: physical water and tuning.
- `scripts/platform_motion.gd`, `stage_hazards.gd`: platform paths and shared rendering/contact timing.
- `scripts/june_boss.gd`: five-arena boss progression, attacks, chase and phase checkpoints.
- `scripts/journey_scenery.gd`: per-place scenery, lighting transitions, interiors and optional-area covers.
- `scripts/world.gd`, `world_layer.gd`, `terrain_art.gd`: collision, camera and ordered drawing passes.
- `scripts/layout_editor.gd`, `layout_document.gd`: workshop, validation and compilation.
- `scripts/main.gd`, `audio.gd`, `save.gd`, `controls.gd`: application menus, sound, versioned saves and bindings.

See [AUTHORING.md](docs/AUTHORING.md) for the stage contract and [FOUNDATION.md](docs/FOUNDATION.md) for the architectural intent.

## Saves

On macOS the save is `~/Library/Application Support/Godot/app_userdata/Yearbound/yearbound_v1.json`, with a `.bak` recovery copy. Settings, bindings, completed-day records and saved lab tuning are retained. An unfinished run from an older layout revision resumes at its new entrance because checkpoint and collectible positions have changed. June boss phases save independently. Optional sunmotes use the existing collectible save system.

## Verification

Compile/check content with:

```sh
python3 tools/build_authored_stages.py --check
python3 tools/validate_content.py
```

For engine checks, set `YEARBOUND_SAVE_DIR` to a scratch directory, then run, for example:

```sh
godot --headless --path . --script tests/authored_routes.gd --fixed-fps 60
godot --headless --path . --script tests/june_chapter.gd --fixed-fps 60
godot --headless --path . --script tests/june_boss_routes.gd --fixed-fps 60
godot --headless --path . --script tests/authored_campaign.gd --fixed-fps 60
godot --headless --path . --script tests/authored_mechanics.gd --fixed-fps 60
godot --headless --path . --script tests/editor.gd --fixed-fps 60
godot --headless --path . --script tests/smoke.gd --fixed-fps 60
godot --headless --path . --script tests/controller.gd --fixed-fps 60
godot --headless --path . --script tests/charge_dash.gd --fixed-fps 60
godot --headless --path . --script tests/swimming.gd --fixed-fps 60
```

`authored_routes.gd` checks the 40 ordinary journeys continuously from their entrances, without moving the player between route points. The boss has separate full-duration arena survival tests, a chase traversal and state/transition tests. These establish reachability, not final human difficulty balance. Set `YEARBOUND_CAPTURE_DIR` to capture native views with `tests/authored_capture.gd`. The native `ground_layout.gd` suite also probes framebuffer layering.

See [VALIDATION.md](docs/VALIDATION.md) for the delivered build’s verification and limits. Final pacing, human balance, physical controller testing and Windows/Linux/Intel Mac exports remain production work. The foundation deliberately leaves the second major mechanic and full storyline open.
