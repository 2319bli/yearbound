# Build verification · 9 September 2026

Environment: Apple M4 / macOS, Godot 4.6.2, native OpenGL compatibility renderer. Delivered app is Apple silicon ARM64, includes its own runtime, and uses an ad-hoc development signature. The original Documents/Yearbound music folder was read and copied from, never edited.

## Expanded campaign, GitHub and workshop · 0.12.0

All 29 playable dates are at least twice their previous length, with six additional named challenge sections, 116–164 independent spike placements and 864–1,488 pixels of elevation change. The original openings remain warmups. See `EXPANDED_CAMPAIGN.md` for every date’s measurements and the authoring pipeline.

- Content validation passes for all 29 stages and 365 dates, including taller bounds, grid alignment, safe marker support, spike directions, extension length and spike-count metadata.
- The packaged opening bot reaches the first new checkpoint on all 27 land routes with zero deaths. The swimming suite separately traverses November’s 29 original underwater waypoints with zero deaths. The new course bot starts once at each first extension checkpoint, then uses normal input through every landing and all six challenge sections; all 29 reach their exit or boss entry with zero deaths. It does not teleport between landings. These separate checks establish reachability, not a continuous human spawn-to-finish playthrough or final difficulty balance.
- Thirteen packaged suites pass with zero assertion failures: expanded campaign, workshop/editor, opening routes, expanded routes, swimming, smoke, seasonal mechanics, year-round samples, charge dash, controller, June 2–8 scenes, June 9–17 scenes, and native ground/layer checks. Boss tests verify delayed activation, offset camera/arena bounds, phase retry and survival completion. The dedicated updraft regression confirms that an active dash retains its launch velocity instead of being clipped to the normal float-speed cap.
- Workshop checks cover the dash toggle and undo, the height dropdown, negative-row geometry, wall spikes, refusal to shrink through upper content, export/reopen, actual charged vertical launches in Playtest, and clearing held aim/dash input on return. New and reopened layouts use editor format 2. Existing controller/ability tuning tests still pass.
- A comparison with `v0.11.0` verifies byte-identical player/ability/swimming scripts and tuning resources, the unchanged 17-station lab, and all 124 tracked files beneath art/audio. All 28 non-boss openings retain their original platform, hazard, checkpoint, mote, zone, sign and decoration arrays as prefixes. The original boss platforms are retained with their positions shifted to the final arena.
- Thirteen native packaged captures cover the title, nine elevated seasonal/June views, the relocated boss arena and two workshop views. Eight gameplay/editor views were inspected for clear spikes and terrain caps, correctly oriented wall/ceiling teeth, complete backgrounds during climbs, submerged November rendering and unclipped controls. The native layer suite verifies the actual framebuffer order of scenery, terrain, player, hazards, foreground and UI.

The private repository preserves the original foundation as `v0.11.0`; the expanded source is version `0.12.0`. The local app retains its verified ad-hoc development signature. App and source archives pass ZIP integrity checks. All test saves were isolated from normal player progress. Restricted headless runs can report the existing macOS certificate or resource-cleanup messages; no script, parser or native rendering errors remained. Physical controller hardware, final human balance and notarized public distribution remain outside this verification.

## June 9–17 decoration · 0.11.0

Nine distinct scene identities add dedicated original pixel-art landscapes, native animated landmarks and the supplied full-length soundtracks. Eight new compact routes join the campaign; 15 June becomes Windmill Heights with its existing collision layout preserved. All 29 playable stages and 365 calendar dates pass content validation.

- The packaged June scene suite verifies nine unique landscape resources, soundtrack streams over 210 seconds, distinct landmark combinations, safe starts/checkpoints, calendar order and complete workshop export/reopen preservation. The workshop lists all 29 samples and tracks; blank layouts choose the next unfinished date, currently 18 June.
- The eight new routes complete with zero deaths using normal movement and charge-dash input, without teleporting across obstacles. This verifies reachability, not final human difficulty or five-minute pacing.
- Packaged editor, earlier June, year-round, seasonal-mechanic and swimming regression suites pass with zero assertion failures. The November traversal again completes all 29 underwater waypoints with zero deaths.
- Nine MP3 hashes match the user's original files exactly. The twenty other pre-existing stage definitions, extended Dash Lab, player/ability/swimming scripts and all three movement tuning resources are unchanged from 0.10.0. Eleven geometry/gameplay fields of 15 June are identical, including its lifts, springs, checkpoints and hazards.
- Twenty-one native captures from the packaged runtime cover the title, each scene's opening and first checkpoint, June calendar and workshop. All nine scenes were visually reviewed; terrain caps and hazard outlines remain above scenery. The large flat draft background shapes were replaced by dedicated plates, with smaller detailed landmarks and restrained water animation. Captures are in `Previews/June-09-17` beside the project.

Exact image-generation prompts and asset hashes are in `art/june/PROVENANCE_09_17.json`; soundtrack/guide references are in `content/june_09_17_sources.json`. No supplied composition/render scripts were executed or future days from the plan added. Test saves were isolated from normal progress. Restricted headless runs emit existing macOS certificate and resource-cleanup notices, separate from the passing assertions; native captures produced no script/rendering errors. The self-contained 0.11.0 app retains its verified local development signature.

## Physical underwater November · 0.10.0

November is a full swimming route with collider-based water volumes, buoyancy, drag, normalized directional movement, stable surface transitions, water-resistant dashes and a timed underwater dash refill. The other twenty stage definitions, the base movement resource/script and the charge-dash tuning resource/script are byte-identical to 0.9.1. The 17-station lab remains intact.

- The packaged swimming, controller, charge-dash, year-round, seasonal-mechanic, editor and lab-route suites pass with zero assertion failures. Content validation passes all 21 stages and 365 dates.
- Swimming tests exercise upward/downward motion, Jump/Down priority, diagonal normalization, neutral buoyancy, braking, finite current drift, surface stability, breaching/re-entry, wall/ceiling collision, pause/reset, water dash drag and refill, checkpoint/death recovery and preservation of water metadata in workshop layouts.
- Real engine events verify IJKL swimming, a rebound diving key and controller-axis swimming. The music filter engages underwater and returns to its normal cutoff afterwards. No physical controller hardware was available.
- A normal-input traversal follows 29 waypoints through all three submerged passages, reaches both lantern checkpoints and completes the gate with zero deaths. It requires no dash. Stationary full horizontal burst distance measures 227 px in water versus 310 px in air at 60 physics ticks/second. This establishes route reachability, not final human difficulty.
- Native captures of the title, November's opening and three passages, plus a June regression view, are in `Previews/Underwater`. Water depth and shafts render behind gameplay geometry; sparse foreground effects preserve terrain and hazard outlines. Signs and the swim/dash HUD were reviewed for readability.

The self-contained 0.10.0 Apple silicon app uses isolated saves for verification and retains its local development signature. Restricted headless runs still emit the known macOS certificate/resource-cleanup notices; no assertion, script or rendering failures occurred. Normal player save files were not edited during development.

## Original dash profile with horizontal 1.5 · 0.9.1

Compared the complete tuning script against the original 0.8 source archive: horizontal multiplier 1.5 is the only difference. The charge resource is byte-identical. In particular, the original force range, charge duration, momentum, steering and total launch-speed cap are retained.

The packaged year-round, charge-dash, directional-route and engine-input suites pass with zero assertion failures. Migration checks seed exaggerated saved overrides, verify that they are cleared once, and confirm preservation of campaign progress, checkpoint, controls and unrelated preferences. Later lab edits survive reload. The campaign still contains 21 stages, and the lab retains all 17 stations.

## Every-month samples and campaign dash · 0.9

Twenty-one stages cover all twelve months, including eight new 7,680 px routes. All current campaign stages enable charge dash with horizontal multiplier 1.5. The original thirteen stage definitions differ from 0.8 only by the ability opt-in; both base movement profile files remain byte-identical. The laboratory grows from 21,120 to 44,160 px and from eleven to seventeen stations.

- Packaged year-round, charge-dash, base-controller, lab, directional-route, workshop and gameplay-smoke suites passed with zero assertion failures. All 21 starts and new checkpoints are supported and clear. Each new day loads its own score and retains scenery/ability metadata through workshop round-trips.
- The input/save checks cover the one-time horizontal-profile migration, later tuning persistence, binding capture/conflicts, analog trigger mapping, profile export, campaign isolation, lab completion and restart. A full engine-input run verified C charging, IJKL release direction, audio, Escape, rebinding, the last scrolling station button and the new May calendar shortcut. This ran headlessly with the UI render loop enabled to isolate it from desktop focus changes; visible-window runs correctly paused/cancelled input when macOS focus moved away.
- The traversal bot completed all eight new monthly routes with normal movement and dash input: seven with no deaths and November with one retry. All six extended lab courses completed with zero deaths. The seven original targeted lab landings pass at horizontal 1.5; the diagonal balcony uses an earlier launch and braking to accommodate the shallower trajectory. These checks establish reachability, not final human difficulty.
- At 60 physics ticks/second, stationary short/middle/full bursts measured approximately 71/158/310 px. The unchanged total speed cap limits a full horizontal release to 1,550 px/s. Thin hazards, walls/ceilings, momentum, air rules and interruption checks pass. Reversal after the stronger release occurs within the tested 0.22-second window.
- Twenty native screenshots cover title/calendar, opening and landmark views of all eight new months, the extended course and scrolling station panel. Screens were reviewed for seasonal identity, readable terrain, hazard separation, HUD placement and menu clipping. See `Previews/Year-round` beside the source folder.

Content validation passes 21 stages and 365 unique dates. The self-contained 0.9.0 app is locally development-signed. Tests use isolated save folders. As before, restricted headless runs can log macOS certificate and resource-cleanup notices. Physical gamepad hardware, final musical production and full human balancing remain outside these checks. The new music consists of original temporary 29–51 second score sketches.

## Charge dash laboratory · 0.8

The thirteen campaign stage JSON files and both base movement profile files were compared against the 0.7 archive and remain byte-for-byte unchanged. The dash is enabled only in the dedicated lab. Content validation still passes thirteen stages and all 365 calendar dates.

- Packaged controller, charge-dash, lab, lab-route, editor and gameplay smoke suites: zero assertion failures. Existing running/jumping regression checks pass with the ability unassigned.
- Dash checks cover continuous charge scaling, the charge cap, all eight directions, diagonal normalization, ground/air rules, landing resets, running and lift momentum, jump cancellation, post-dash braking, solid walls/ceilings, thin hazards, pause/release, death, checkpoints and spring interruption.
- At 60 physics ticks/second, stationary horizontal bursts measured approximately 47, 105 and 236 px at 4%, 48% and full charge. These are burst-only distances; run-up, jumping and retained velocity extend travel after the burst. Holding beyond maximum produced the same capped launch.
- All eleven station starts are safe on actual collision surfaces. Seven directed route checks reached the intended landings for short, medium, long, upward, downward, diagonal and airborne launches. Lab completion and Resume produce a fresh playable attempt. Campaign progress is preserved.
- Tuning validation, save/reload, defaults, input conflicts, keyboard rebinding and controller-axis binding checks pass. A two-pixel hazard is detected when crossed between physics frames at high speed.
- Native packaged input events verified title entry, Shift charging, rising hum/cap, IJKL upward aim, release/audio stop, Escape, the Controls screen, and rebinding the actual dash to V. Timing uses physics ticks, independently of native rendering speed.
- Profile export was verified through the file-selection callback and the written JSON. Production requests a native macOS save dialog; the automated test uses Godot's dialog to avoid leaving an OS-modal panel open.
- Seventeen native screenshots cover the title, eleven stations, charge feedback, tuning and controls. Key screens were visually inspected for readable terrain, unobscured charge feedback, controls and panel layout. See `Previews/Charge-dash` beside the source folder.

These checks establish mechanics and reachability, not final human balance. No physical controller was available; gamepad bindings were checked with software events. Test saves are isolated from normal progress. Some fixtures log the existing resource-cleanup notice at shutdown; native checks produced no script or rendering errors. The app retains its verified local development signature.

## Original foundation automated checks

- Content validator: six valid stage definitions, 365 unique calendar dates, twelve month-end boss slots, all audio references present, safe spawn/checkpoint/goal surfaces.
- Smoke suite: safe spawn and audio load for every stage; pause clock freezing; acceleration and braking; full vs short jump; death/checkpoint return; persisted run reload; monthly boss phase recovery; boss completion; door completion for all five exploration stages. Zero assertion failures.
- Mechanic suite: leaving a ledge and successfully using coyote time; buffered landing jump; spring launch; leaf crumble and regeneration; ice momentum; waterfall lift; malformed-save recovery from backup. Zero assertion failures.
- Actual physics traversal bot: all five exploration routes completed with zero deaths in the 0.5 layouts. The bot uses normal input actions, not teleporting between platforms. Smoke-suite goal tests separately place the player at the doorway to isolate completion behavior.
- Native renderer: title, calendar, settings and six stage views captured from the packaged app's PCK using the included runtime. Screens visually inspected for text layout, seasonal identity and collision readability.
- Package: native ARM64 runtime and content packed into an `.app`; signature verified with `codesign --verify --deep --strict`. Bundled icon verified as ICNS.

The test suites keep progress in isolated scratch folders. Normal player saves are separate. Headless runs in the restricted development environment can log OS certificate/editor-settings access messages and deferred script-resource cleanup notices; assertion results above are separate from those engine messages.

## What these checks do not establish

No physical gamepad was connected. Standard stick, D-pad and face-button mappings are implemented, but device-specific layout, Bluetooth behavior and rumble are not validated. No claim of full human difficulty testing, accessibility certification, production balancing, five-minute stage lengths, or a finished 30-hour campaign is made. Boss phase and completion logic are tested; extended human testing of all attack combinations remains a tuning step. The five added scores are musical sketches, not final 365-track soundtrack production.

The build has been tested locally on Apple silicon only. Intel Mac, Windows and Linux builds and notarized public distribution are future packaging work. Source is included so those targets can use Godot's appropriate export templates later.

## June 2–8 decoration revision · 0.7

Seven independent June content files add unique identities, original generated landscape plates, authored rear scenery, individual terrain palettes and byte-identical copies of the supplied MP3s. The original six stage files and player controller were compared against the 0.6 source archive and are byte-for-byte unchanged.

- Content validation: thirteen stages, 365 unique dates, twelve monthly boss slots; valid resources, block coordinates and safe spawn/checkpoint/exit markers.
- New route traversal: all seven June routes completed with zero deaths using the existing run/jump bot. This establishes reachability, not final human difficulty or five-minute pacing.
- Packaged June suite: each supplied track loads as a full-length MP3, each landscape resolves, seven identities/art/music paths are distinct, campaign ordering follows 1–8 June, and all days/tracks appear in the workshop. Export/reopen preserves every stage including fractional animation phases; the exporter now writes full-precision numbers.
- Packaged editor suite: all thirteen stages validate, copy, compile and round-trip; paint/erase, undo/redo, marker checks, export/open, draft recovery and campaign-isolated playtesting pass.
- Native packaged floor/layer suite: thirteen continuous floors and restored checkpoints pass. Framebuffer probes verify scenery/terrain/player/hazard/foreground/UI occlusion.
- Native packaged interaction suite: real input events verify workshop entry, brush selection, painting, Command-Z, redo, right-click erase, rectangle strokes, Playtest and Escape return.
- Twenty-six native captures: title, calendar, settings, all thirteen days, June opening, seven June landmarks, focused June calendar and workshop (26 PNGs total, counting alternate calendar/workshop views). Screens inspected for distinct atmosphere, clean block caps, unobscured hazards, text fit and editor control clipping. See Previews/June-week.

All suites above completed with zero assertion failures. Native packaged runs reported no script or rendering errors. Headless fixtures retain the existing shutdown resource-cleanup notice and macOS certificate warning. Normal user saves were not used by verification. The app is locally ad hoc signed; controller hardware and final human difficulty balancing remain untested.

## Block grid and workshop revision 0.6

All six sample definitions now use 48-pixel grid coordinates and whole-block dimensions. Content validation, gameplay smoke checks, seasonal mechanic checks and the expanded editor suite passed with zero assertion failures. The traversal bot completed all five exploration routes with zero retries after the grid conversion. June overhead blocks were raised where the thicker square terrain reduced jump clearance. Movement tuning is unchanged.

The editor suite covers contiguous drag painting, rectangle erasing, whole-stroke undo/redo, floor extension/trimming, marker and environmental compilation, JSON round trips, reopening exports, malformed input rejection, date validation, draft recovery and all six sample-to-editor conversions. It also runs an authored layout through the actual game world, reaches its exit, returns to the editor and verifies that campaign save data is unchanged.

Native mouse/keyboard events verified the title entry button, palette selection, canvas painting, Command-Z, redo, right-click erasing, rectangle drawing, the Playtest toolbar and Escape return with the layout preserved. A native Save dialog selected a file in an isolated scratch folder and the exported JSON was confirmed on disk. The installation command validated the workshop starter with `--check-only`. In an isolated copy of the source, it also installed 2 June, preserved the six featured shortcuts, rejected an accidental overwrite, created a backup for explicit replacement, and passed content validation with seven available stages. The delivered campaign remains the six reference days.

The final packaged 0.6.0 app passed the ground/layer suite, editor suite and native interaction suite with zero failures. Thirteen native screenshots cover the menus, all six seasonal samples, the workshop, playtest and return to editing. The captures were inspected for block shapes, exposed terrain tops, editor clipping, readable controls and retained layering. No script or rendering errors were reported by these packaged runs.

The workshop is deliberately small: mouse/keyboard authoring, built-in material/theme/music choices, grid geometry, markers and basic environmental brushes. Detailed boss/hazard scripting, custom media import and device-specific editor controls are not included. Structural validation and safe start/exit placement do not establish that every user-authored jump is reachable.

## Ground and layering revision 0.5

All six authored layouts now share a continuous, flat collision floor. Logs, hay bales, stone blocks, brambles and seasonal structures sit above it. Content validation, the gameplay smoke suite and seasonal mechanics suite completed with zero failures. The controller profile from 0.4 is unchanged.

The new ground/layer suite passed both headless and with the rebuilt app's bundled native runtime and PCK. It samples the base floor across every stage, independently of raised obstacles, checks restored checkpoints and retained time/death records, and checks that bramble tips can be jumped over while contact triggers one retry. Native framebuffer probes verify actual rendered occlusion through scenery, terrain, player, hazards, foreground and UI; all six probes passed.

The traversal bot now anticipates raised obstacles and brambles. All five exploration routes completed with zero retries. This establishes that the base routes are traversable with ordinary movement; it does not cover every optional elevated route, secret or human difficulty preference. Previously recorded 0.4 retry counts below describe the older layouts.

Ten screenshots were captured from the rebuilt native app and visually inspected: title, calendar, settings, the June opening and all six stage views. The capture run exited successfully with no script or rendering errors. The app's development signature was verified again.

The layout contract, draw-order table and migration notes are in `GROUND_AND_LAYERS.md`. Existing checkpoint and collectible indices retain their authored ordering so saved runs can resume on the new floor. The app is version 0.5.0.

## Pixel-art revision 0.2

The content validator and gameplay smoke suite were rerun after integrating the pixel rendering pass; zero assertion failures. All six stage views, title, calendar and settings were captured from the rebuilt app's PCK using its bundled native runtime. Four generated pixel-art landscapes, a three-tree atlas, the eagle sprite, code-authored material maps and the native storm-cloud layer were visually checked. The HUD and menus remain above the pixel composite. The final app signature was verified again. Earlier mechanic and traversal results above describe the unchanged physics controller and layouts.

The art cache is bounded to sixteen textures for future per-day backgrounds. Full performance profiling across future hundreds of assets is outside this slice. Landscape plates currently pan as complete images; the storm clouds, nearby foliage, windmills and weather supply additional layered motion.

## Countryside revision 0.3

The expanded content validator passed all six stages, including terrain palette roles, decoration types, layer names, dimensions and platform anchors. The gameplay smoke suite completed with zero assertion failures. A comparison against the 0.2 source archive confirmed that all six gameplay stage definitions and the player/world logic preceding rendering are unchanged; additions are decorative metadata and drawing code.

Ten native views were captured with the rebuilt app's bundled runtime and PCK: the opening June area, all six stage samples, title, calendar and settings. The captures were inspected for clear terrain caps and borders, safe foliage placement, seasonal readability and UI layout. The packaged capture run reported no script or rendering errors. The app's ad-hoc signature was verified, and both delivery archives passed ZIP integrity checks. Earlier controller/mechanic/traversal results apply to the unchanged movement and layouts.

The June decoration pass uses original code-authored props and existing project pixel assets. The background grade preserves blue sky while reducing contrast near the playable plane; pale platform tops, dark framing and restrained faces separate collision geometry from the landscape. The new authoring contract and composition guidance are in `AUTHORING.md` and `ART_DIRECTION.md`.

## Movement revision 0.4

Content validation, the gameplay smoke suite, seasonal mechanics suite and the new controller suite completed with zero failures. The controller suite was also run with the rebuilt app's bundled native OpenGL runtime and packaged resources; it produced the same measured jump heights and stopping distances as the headless run, with zero failures and no native script errors. It covers responsive input, progressive jump heights, same-tick landing buffers, expired input, head-corner correction, ceiling/wall collision boundaries, lift momentum and expiry, checkpoint state clearing, assist and pause.

The traversal bot now releases jump on descent instead of using a fixed forty-frame hold, allowing fresh presses on shorter landings. It exits unsuccessfully if any route is incomplete. All five routes completed: 1 June zero retries, 15 June five, 12 October sixteen, 18 January zero and 9 March zero. The bot has no hazard-avoidance strategy; this establishes route reachability, not final human difficulty balance. Geometry is unchanged. March's upward forces were retuned from -2150 to -3650 to overcome the new normal gravity.

`docs/MOVEMENT.md` records the new profile, reference sources and measured results. Physical gamepad testing and an extended human comparison with Celeste have not been performed. The updated app is version 0.4.0, retains the development signature, and is intended for local Apple silicon playtesting.
