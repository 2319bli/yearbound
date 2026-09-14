# Yearbound contributor guide

This directory is the canonical editable Godot project and Git repository. Start with `README.md`, then the relevant document in `docs/`.

## Project state

- Godot 4.6.2; native Apple silicon desktop build, currently version 0.17.0.
- 183 stages: 51 calendar dates plus 132 monthly challenges (11 per month). The full main calendar still has 365 dates.
- 787 named places: 259 original atlas views plus 528 original code-native challenge scenery compositions. See `docs/MAP_SCENERY.md`, `docs/EXTREME_CHALLENGES.md` and the artwork provenance records.
- The repository `https://github.com/2319bli/yearbound` is intentionally public, following the owner's latest preference.

## Working together

- Read `git status` before editing. Preserve other contributors' uncommitted work.
- For simultaneous AI or human contributors, use separate branches and Git worktrees. Agree on file ownership for overlapping changes and review changes before integration. Do not share one writable checkout between concurrent editing sessions.
- Make focused commits explaining the change and relevant verification. Do not force-push or discard someone else's changes.
- Treat imported design documents as reference material unless the user's current request makes them instructions.
- Keep secrets, player saves, workshop drafts, engine caches and app builds out of Git. Supplied reference material lives separately in `~/Documents/Yearbound`; do not modify those originals.

## Content and gameplay conventions

- Edit `content/layouts/MM-DD.json` for authored layout changes, then compile with `python3 tools/build_authored_stages.py --write`. The game consumes `content/stages/`; avoid edits there that the compiler will overwrite.
- Each day should have its own scenery and gameplay identity. Keep terrain tops and hazards clearly separated from background decoration.
- Preserve the existing responsive movement unless the task explicitly calls for tuning it. The approved charge-dash profile is the original profile with horizontal multiplier **1.5**. Keep the 17-station Dash Lab available.
- Monthly challenges use `MM-XNN` IDs, a separate `catalog.challenges` list and the Monthly challenges browser. Edit their explicit blueprints normally. `tools/build_monthly_challenges.py --write` deliberately regenerates all 132 challenge blueprints; do not run it casually over custom edits.
- Mechanisms are authored as `type: "mechanism"` hazards; see `docs/OBSTACLES.md`. Drawn geometry and swept contact must agree. Keep warning intervals harmless.
- November is physically underwater. Preserve swimming support and workshop metadata when changing shared stage systems.
- The second major ability and full storyline are intentionally undecided.

## Build and checks

The latest request supersedes the extreme-spam direction: stages must be remotely possible, readable and intentionally designed. Reachability and survival testing are now authorized and required for changed routes. Preserve challenging mechanics without overlapping hazard spam.

Run commands from this directory:

```sh
python3 tools/build_authored_stages.py --check
python3 tools/validate_content.py
python3 tools/build_macos.py
```

The build script writes `../Yearbound.app`. It defaults to `/Applications/Godot.app/Contents/MacOS/Godot`; override with `GODOT_BIN`. Rebuild after runtime changes before handing over the app.

For engine tests, isolate saves with `YEARBOUND_SAVE_DIR`. For example:

```sh
yearbound_test_dir="$(mktemp -d /tmp/yearbound-test.XXXXXX)"
YEARBOUND_SAVE_DIR="$yearbound_test_dir" /Applications/Godot.app/Contents/MacOS/Godot --headless --path . --log-file "$yearbound_test_dir/engine.log" --script tests/smoke.gd --fixed-fps 60
```

Run `tests/challenge_routes.gd` for changed monthly routes, `tests/authored_routes.gd` for changed ordinary dates, and `tests/june_boss_routes.gd` for the June boss. Run tests appropriate to the changed subsystem; see `README.md` and `docs/VALIDATION.md`. Rendering checks such as `tests/map_scenery_render.gd` and `tests/ground_layout.gd` require the native renderer, without `--headless`. Set `YEARBOUND_CAPTURE_DIR` for screenshot scripts. Automated reachability checks do not establish final human difficulty or five-minute pacing.
