# Yearbound · Foundation 0.12.0

A native Godot platformer about travelling from 1 June to 31 May. Twenty-nine playable days now include extended vertical challenge routes, each at least twice its previous length and with 116–164 separate spike placements. The first seventeen June days each have their own setting; the supplied 1–17 June tracks are included. Every month now has a playable sample. The other 336 dates are deliberately unfinished.

## GitHub and building

The private repository is `2319bli/Yearbound`. Tag `v0.11.0` preserves the tested foundation before the workshop and campaign expansion. The repository includes the editable source, art and music; generated app packages, caches and player saves are excluded.

Clone the repository and import `project.godot` in Godot 4.6.2. On an Apple silicon Mac with Godot installed at `/Applications/Godot.app`, run `python3 tools/build_macos.py` to create `Yearbound.app` beside the project. Set `GODOT_BIN` for a different Godot executable. The downloadable app supplied alongside this project is already built.

## Play

Open the accompanying **Yearbound.app** on an Apple silicon Mac. The app contains its own Godot runtime and works offline. No installation, account, browser, or development tools are required. This is a locally ad-hoc signed development build, not a notarized distribution release.

Move with **A/D**, **←/→**, or **J/L**. Jump with **Space** or **Z**; hold for height. **Esc/P** pauses, **R** returns to the checkpoint, and **F11** toggles fullscreen. Standard gamepads use left stick/D-pad, bottom face button to jump, Start to pause, and top face button to restart. Menus support mouse, ↑/↓, Tab, Enter, Escape, and standard gamepad confirm/back. Physical controller hardware was not available for testing.

Walk past lanterns to save a checkpoint. Sunmotes are optional. Pass through the timber gate to finish a normal stage. The June boss ends after 105 seconds of successful survival; deaths restart the current 35-second phase. Amber lines telegraph attacks. No melee action is assigned. Charge dash is enabled throughout the playable campaign using the original settings with only the horizontal multiplier changed to 1.5. The Dash Lab remains available for tuning.

The calendar lets you enter all twenty-nine playable days immediately. Use the twelve monthly shortcuts along the bottom or browse the months. Unbuilt dates say “A day yet to be written.”

## Underwater November

Choose **19 November** in the calendar. Swim with **WASD / arrows / IJKL**, or the controller stick/D-pad. **Jump** also swims upward; **Down** dives. Let go to drift gently towards the surface. Dash keeps the original profile with horizontal 1.5, with water drag during the burst and a short recharge while swimming. Lanterns save underwater checkpoints. There is no breath timer. See `docs/UNDERWATER.md`.

## Charge dash lab

Choose **Charge dash lab** on the title screen. Hold **Shift / C** (controller **X / West / RB**), aim with WASD/arrows/IJKL or the left stick, then release. Short, medium and long holds blend smoothly, with different steering and momentum tradeoffs. **Esc / Start** opens seventeen stations and the complete live tuning panel; export a tuning JSON file to share your preferred feel. Controls can be rebound in Settings or from the lab panel. See `docs/CHARGE_DASH.md`.

Lab attempts are isolated from campaign progress. Its tuning profile is shared with campaign play. The campaign keeps its established openings and adds longer vertical challenges; all playable days opt into charge dash. The lab is 44,160 logical pixels long, up from 21,120, with six extended courses.

## Layout workshop

Choose **Layout workshop** on the title screen to paint square blocks, place markers, set the date/theme/music and playtest your layouts. Save a shareable `.yearbound.json` file for incorporation as a day. The editor includes a visible charge-dash toggle, a height selector, four spike directions, undo/redo, rectangle fills, pan/zoom, sample copying and draft recovery. New layouts enable dash. Playtest uses the current Dash Lab profile and normal rebound controls. Campaign progress stays separate. See `docs/WORKSHOP.md` for the complete guide.

## The playable days

| Date | Stage | Defining play |
|---|---|---|
| 1 June | The first sunlit path | A continuous meadow path, low countryside obstacles and optional timber routes beneath a wide summer sky. |
| 2 June | Skipstones and Dragonfly Wings | A bright streamside path of pale stepping blocks, willow curtains and darting dragonflies. |
| 3 June | Kites Above the Clover | An open clover common, long kite strings and little gusts above a low skyline. |
| 4 June | Sunpatches on the Orchard Wall | Honey-coloured orchard walls, green fruit and patches of sun beneath a leafy canopy. |
| 5 June | The Meadow Express | A tiny flower railway, timber cargo blocks and a little lakeside station in the tall grass. |
| 6 June | Sunlight on the Waterwheel | Turning paddles, stone sluices and animated spray along an aquamarine millrace. |
| 7 June | The Sunflower Shortcut | Tall golden sunflower lanes open into cool hazel shade, then turn back towards the sun. |
| 8 June | Apricot Lanterns in the Breeze | A warm evening village green, swaying paper lanterns and gentle terraces beside a pavilion. |
| 9 June | The Glasshouse Run | High glass panes, fern beds and palm galleries. Short ceramic steps lead through reflected early-summer light. |
| 10 June | Cloverfield Crossing | Intersecting paths, little bridges and clover hedges open onto a broad common. |
| 11 June | Riverside Rush | A wide silver river, rushing rapids and a quiet mooring. Long timber runs alternate with pale bank-side stones. |
| 12 June | The Orchard Climb | Terraced apple trees, picking ladders and high boughs. Small staircases rise towards a view beyond the orchard. |
| 13 June | Wildflower Way | Bluebells, pink flower drifts and pollinators fill a wide meadow with colour. Quiet gaps frame the low hopping route. |
| 14 June | The Woodland Detour | Tall birches, foxgloves and fallen wood lead from cool leaf shade into a clearing full of light. |
| 15 June | Windmill Heights | Tall windmill sails and lifting ribbons overlook a broad early-summer horizon. Ride the existing mill lifts and bellflower springs. |
| 16 June | The Hayfield Hop | Round hay rolls, freshly cut rows and a weathered barn catch warm afternoon light. Square hay steps carry the hopping path. |
| 17 June | Brookside Bounce | Little cascades, water-worn arches and lily pools. Pebble steps and optional bellflowers follow the brook into willow shade. |
| 30 June | The keeper of the squall | Read the sky. Outlast three changing storm patterns to quiet the keeper. |
| 16 July | The Long Light of Barley Common | Tailwinds over the cut fields. Chain low jumps and short dashes between the hay stacks. |
| 23 August | The Lake Before the Storm | Golden light gives way to a storm. Cross lake jetties and use the ferry between gusts. |
| 14 September | Copper Leaves, Quiet Footsteps | Copper woodland terraces. Keep moving across fragile leaf blocks, then brake for narrow perches. |
| 12 October | A rustle before thunder | Leaf bridges give way beneath your feet. Find shelter between the gusts. |
| 19 November | Lanterns Beneath the Flood | Full underwater swimming: buoyancy, diving through sunken beams, water resistance and opposing sluice currents. |
| 8 December | The First White Mile | Follow the snowline through fir woods. Leave sheltered ledges between falling ice warnings. |
| 18 January | The hush beneath the ice | Carry your momentum over frozen pools. Watch the glint of falling ice. |
| 17 February | Where the Ice Lets Go | Thaw pools interrupt the old ice road. Carry speed over slick blocks and brake on exposed stone. |
| 9 March | Where the river takes flight | Leap into waterfall updrafts. Let the rising spray lift you into spring. |
| 11 April | A Rainbow Between Showers | Climb rain-washed garden terraces. Ride the rising spray and dash diagonally beneath the rainbow. |
| 24 May | The Garden at the Edge of May | A long, lush garden path. Link flower springs, elevated walks and controlled diagonal landings. |

The expanded stages span 13,152–23,808 logical pixels, with six named vertical challenge sections and 864–1,488 pixels of elevation change. All 29 have more than 50 independent spike placements (116–164, containing 756–1,162 visible tips). Existing openings act as a warmup; the longer courses combine sharp landing edges, underside/wall spikes, climbs, descents and checkpoint rest decks. The June boss follows a substantial approach and retains its 105-second survival fight. These are harder reference journeys, not a claim of final five-minute pacing or human difficulty balancing. See `docs/EXPANDED_CAMPAIGN.md` for the per-day measurements. The supplied 1–17 June soundtracks are included; the later sample tracks are original synthesized sketch scores intended for later musical development.

See `docs/JUNE_09_17.md` for the latest nine June scenes, `docs/MONTHLY_SAMPLES.md` for the eight new monthly routes and `docs/JUNE_02_08.md` for the June decoration references.

## Open the source

Import `project.godot` into Godot 4.6.2 or a compatible Godot 4 version and press F6/F5 as appropriate (F5 runs the game). The app package is separate from the source. Editing JSON changes the source build; rebuild the package to update the app.

- `scripts/layout_editor.gd`: built-in visual workshop and native file dialogs.
- `scripts/layout_document.gd`: grid model, undo/redo, validation, JSON compilation and safe file writes.
- `scripts/player.gd`: responsive CharacterBody2D movement, jump forgiveness and modular ability hooks.
- `scripts/charge_dash.gd` / `charge_dash_tuning.gd`: the charge ability and its central tuning profile.
- `scripts/swim_motion.gd` / `swim_tuning.gd` / `content/swimming.tres`: physical water volumes, buoyancy, drag, surface transitions and central swim tuning.
- `scripts/water_art.gd`: layered water surface, depth, light, plants and bubbles.
- `scripts/controls.gd`: persisted, validated keyboard/mouse/controller bindings.
- `scripts/movement_tuning.gd` / `content/movement.tres`: shared, typed movement tuning resource.
- `scripts/world.gd`: collision, mechanics, checkpoints, boss state and stage drawing methods.
- `scripts/world_layer.gd`: explicit camera-bound drawing passes for scenery, environment, terrain, markers, hazards, particles, foreground and hints.
- `scripts/terrain_art.gd`: consistent collision-aligned terrain silhouettes and material details.
- `scripts/june_scenery.gd` / `content/june_scenes.json`: original June 9–17 scene compositions and animated landmarks.
- `scripts/day_decor.gd`: per-day animated landmarks and seasonal scenic vocabulary.
- `scripts/scenery.gd`: layered, non-colliding countryside props and environmental animation.
- `content/terrain_styles.json`: shared terrain palette roles, selected or overridden per stage.
- `scripts/landscape.gd`: detailed pixel-art seasonal backgrounds, sprites and environmental animation.
- `scripts/main.gd`: application state and menus; UI/background use separate canvas layers.
- `scripts/audio.gd`: music playback, level control and generated sound effects.
- `scripts/save.gd`: versioned save, atomic replacement and backup recovery.
- `content/catalog.json`: available stages and featured calendar shortcuts.
- `content/calendar.json`: the full 365-day journey and twelve boss slots.
- `content/themes.json`: editable seasonal colors.
- `art/`: generated landscape and sprite assets, material textures, and the prompt/provenance record. Each stage can override its seasonal background using a `background` resource path.
- `content/stages/`: level geometry, music references and mechanics.

See `docs/AUTHORING.md` for the stage contract, `docs/ART_DIRECTION.md` for the countryside composition rules, and `docs/FOUNDATION.md` for architectural intent.

## Saves and settings

On macOS the normal save is `~/Library/Application Support/Godot/app_userdata/Yearbound/yearbound_v1.json`, with a `.bak` recovery copy. Progress includes the last day, latest checkpoint, collected motes, time/deaths, and completed-day records. Leaving a stage resumes at its most recent lantern, not the precise exit position. Restarting a day deliberately begins a new run. Settings save automatically. Gentle journey increases jump height and relaxes leaf/boss timing; it is optional.

Tests can set `YEARBOUND_SAVE_DIR` to an existing scratch folder, so verification never modifies normal player progress.

## Validation

Run `python3 tools/validate_content.py`. Run the following from the project directory, using your Godot executable:

```
godot --headless --path . --script tests/smoke.gd --fixed-fps 60
godot --headless --path . --script tests/mechanics.gd --fixed-fps 60
godot --headless --path . --script tests/controller.gd --fixed-fps 60
godot --headless --path . --script tests/charge_dash.gd --fixed-fps 60
godot --headless --path . --script tests/year_round.gd --fixed-fps 60
godot --headless --path . --script tests/dash_interaction.gd --fixed-fps 60
godot --headless --path . --script tests/lab_extended_routes.gd --fixed-fps 60
godot --headless --path . --script tests/dash_lab.gd --fixed-fps 60
godot --headless --path . --script tests/dash_routes.gd --fixed-fps 60
godot --headless --path . --script tests/ground_layout.gd --fixed-fps 60
godot --headless --path . --script tests/editor.gd --fixed-fps 60
godot --headless --path . --script tests/june_week.gd --fixed-fps 60
godot --headless --path . --script tests/june_second.gd --fixed-fps 60
godot --headless --path . --script tests/expanded_campaign.gd --fixed-fps 60
godot --headless --path . --script tests/campaign_openings.gd --fixed-fps 60
godot --headless --path . --script tests/expanded_routes.gd --fixed-fps 60
godot --headless --path . --script tests/swimming.gd --fixed-fps 60
```

Always set `YEARBOUND_SAVE_DIR` to a scratch folder for these tests. `smoke.gd` deliberately records completion; `mechanics.gd` deliberately damages a test save to exercise backup recovery. `campaign_openings.gd` checks the warmup routes. `expanded_routes.gd` begins at each first new checkpoint and travels through the extended course using normal input, then checks the exit or boss entry. These are reachability checks, not substitutes for human playtesting. `tests/capture.gd` renders the menus and every installed stage with the native renderer when `YEARBOUND_CAPTURE_DIR` points to an existing folder.

See `docs/GROUND_AND_LAYERS.md` for the 0.5 layout and layering changes. See `docs/VALIDATION.md` for this build's results and limits, and `docs/MOVEMENT.md` for the 0.4 movement changes and tuning guide.

## Next production milestones

Continue testing the shared charge dash in the lab and across the monthly samples before committing to final stage designs. Replace sketch scores with individual compositions. Expand each approved sample into an approximately five-minute authored journey with distinct landmarks and optional discoveries. Expand the workshop with selection/move tools, detailed mechanic inspectors and per-day asset import. Expand device-specific controller glyphs, multiple save slots, localization, and formal accessibility review. Split the boss and growing mechanic families into dedicated resources/components when their complexity warrants it. Windows/Linux/Intel Mac exports need their respective Godot export templates; they are not included in this Apple silicon build.
