# Block-grid and day identity update · 0.7

All current terrain uses `grid_size: 48`. Platform `x`, `y`, `w` and `h` are multiples of 48. The built-in samples retain a continuous floor at Y=624; workshop exports express the floor as editable blocks, so they can contain pits. The visual editor writes this same stage schema. Start with [the workshop guide](WORKSHOP.md) for mouse-based authoring and the validated installation command. The remaining reference includes earlier layout examples; snap new terrain to the 48-pixel grid.

# Adding a day

1. Create `content/stages/MM-DD.json` using an existing file as a schema reference. Author a new layout and identity; copying terrain unchanged and recoloring it is not a finished day.
2. Add its `MM-DD` identifier to `content/catalog.json` → `stages`. The application discovers it without a code change. Keep `featured` to the six review shortcuts for this UI.
3. The calendar's availability derives from the catalog at runtime. All 365 dates already exist. The calendar is year-neutral and excludes leap day; the listed date sequence starts on 1 June and ends on 31 May.
4. Assign a unique title, description, music path, terrain and mechanic arrangement. Use `content/themes.json` for palette values. Existing seasonal profile names also select background treatment such as pines, leaves or waterfalls.
5. Run the content validator, then play from start to finish with standard controls and gentle journey off. Check optional routes and recovery after every checkpoint. Package again when the source is approved.

## Stage contract · version 1

All positions are logical game pixels, with Y increasing downwards. The game canvas is 1280×720. The camera follows X. The current continuous base is at Y=620 (600 for the June boss). Above-ground obstacles and walkways use their own heights. The player position is at their feet; the collision body is 24×42. Drowning/falling occurs below Y=825. The continuous ground extends below the screen, so ordinary route failures come from hazards. The fall boundary remains as a recovery safeguard.

Required fields:

| Field | Contract |
|---|---|
| `schema_version` | `1` |
| `id` | A catalog/calendar identifier, e.g. `06-02` |
| `title`, `description` | UI-facing text; keep title below about 29 characters for the current HUD |
| `season` | A theme key from `themes.json`; current profiles: june, mill, boss, autumn, winter, spring |
| `music` | `res://audio/<file>`; imported MP3, WAV or Ogg supported by Godot |
| `spawn` | `[x, foot_y]` above a safe platform |
| `length` | Horizontal extent; goal and terrain should lie within it |
| `goal` | `[x, foot_y]`; the gate finishes the day within 58 pixels |
| `ground` | Optional `{y:624}` creates one solid floor across the entire stage; all twenty-one current samples use it |
| `layout_revision` | Current samples use `2`; saved run snapshots record this content revision |
| `platforms` | Above-ground obstacles and walkways described below |
| `motes` | Array of optional `[x,y]` collectible centers; order supplies save identifiers |
| `checkpoints` | Ordered `[x,foot_y]` lantern positions along the route |
| `hazards`, `zones`, `signs` | Arrays; use an empty array when absent |
| `boss` | Optional `{name, duration:105, phases:3}` for the slice's survival encounter |

The current boss implementation is specifically three 35-second phases; it is a reference encounter, not yet a universal boss-pattern editor. Future boss archetypes should live behind a boss component interface rather than extend date-specific conditionals.

Platform base fields: `{x,y,w,h,kind}`. Supported `kind` values:

- `ground`: legacy individual bank. Prefer the stage-level `ground` field for a continuous foundation.
- `block`: solid above-ground obstacle with `material` set to `log`, `hay` or `stone`. Set its bottom on the floor. Use 36–88 px heights for ordinary jumps.
- `wood`: thin solid bridge/ledge. Platforms are solid from below too.
- `ice`: reduced grounded acceleration and braking.
- `moving`: add `axis` (`x` or `y`), `distance` in pixels and `speed` in radians/second. The player inherits the displacement of the supporting surface.
- `spring`: add `power` (840 is the sample impulse). Automatically launches on landing.
- `crumble`: disappears after 0.65 seconds of contact and returns after 3 seconds of active simulation. Gentle journey allows 1.1 seconds.

Hazards:

- `bramble`: `{type,x,y,w,h}`. A static patch with pale triangular tips. Optional `direction` is `up`, `down`, `left` or `right` (default `up`). The rectangle describes the whole dangerous region; rotate its width/height appropriately for wall spikes. The drawn tips define the top of its forgiving collision rectangle. Keep clear space overhead for the intended jump.

- `blade` / `thorn`: `{type,x,y,r,axis,distance,speed}`. Animated circular collision with a visually pointed silhouette.
- `icicle`: `{type,x,y,r,period,phase}`. Amber warning for the opening 1.35 seconds of a cycle, then a falling shard. Tune period so it travels below the screen before repeating.

Zones: `{type,x,y,w,h,force:[ax,ay]}`. `wind` optionally has `pulse:true`; `updraft` adds vertical force and rising visual arrows; `current` is a shallow horizontal conveyor; `water` becomes physical when it has `swimmable:true`; see `UNDERWATER.md`. Forces are accelerations, not speeds. Normal gravity is 2800 ascending / 3200 descending. The March updrafts use a vertical force of -3650 to overcome it. Bellflower flight uses a separate, longer arc with 1650 / 1920 gravity. Lift needs to exceed the active gravity. Begin lift corridors early enough that a player can clear the underside of elevated solid platforms.

Signs: `{x,y,text}`. A newline separates two lines. Keep signs within the screen at the intended viewing location. They fade with distance.

## Controller tuning

The shared `content/movement.tres` resource uses the typed defaults in `scripts/movement_tuning.gd`; override them in the Godot Inspector. Maximum speed is 340 px/s. Ground acceleration/braking is 3600/4000; air acceleration/braking is 2400/2200. Reversing direction multiplies active acceleration by 1.25. Ice retains 640 acceleration and 160 braking.

A normal jump launches at 480 px/s upward (515 with gentle journey), with up to 0.14 seconds of held rise. Releasing the button ends that rise support. Gravity is 2800 ascending and 3200 descending, halved close to the apex while jump remains held. Normal fall speed is capped at 780. In the 60 Hz fixture, a short tap rises about 45 pixels, an intermediate hold about 77, and full hold about 111. A full jump lasts roughly 0.67 seconds on level ground. Running full jumps cover about 220 pixels; required gaps still need checking at their actual elevation.

Coyote time is 0.10 seconds; the input buffer is 0.12 seconds and is consumed on the landing tick. Upward corner correction searches at most 8 logical pixels sideways, requiring an empty lateral path and upward sweep. This is a small corner forgiveness feature, not a wall-climbing mechanic. Moving lifts contribute bounded momentum, remembered for 0.10 seconds. Checkpoints clear all jump, lift, spring and wind state. See `MOVEMENT.md` for measured behavior and reference notes.

`player.ability` implements the `YBPlayerAbility` pre-motion, post-base-motion, post-collision and interruption hooks. The first implementation is `YBChargeDash`, enabled by `"abilities": ["charge_dash"]` in a stage JSON. It is enabled throughout the current campaign and by default in new workshop layouts. The workshop toggle, undo/redo and export preserve this choice. See `CHARGE_DASH.md` for the tuning resource, exported profile format and signals. Stage logic communicates through `wind`, `ice`, and `bounce` rather than altering input code.

## Content stability

Do not reorder collectible/checkpoint arrays in an already-shipped stage without migrating active saves. Completed records are keyed by date, not file order. Schema changes require a version migration. The slice instantiates a whole stage, not the entire year; hundreds of catalog entries do not load hundreds of levels or tracks into memory. Add room/chunk streaming only when a single stage requires it. Preserve the data/rendering/physics boundaries as systems grow.

## Audio and attribution

`june_opens_the_gate.mp3` is copied from the supplied Yearbound folder. The source guide describes a composed ending rather than a sample-exact loop, so the game restarts playback after the cadence. The original source folder is untouched. Five sketch scores can be regenerated with `python3 tools/synthesize_scores.py` using only the Python standard library. Each day points at its own file. Audio playback and effects have independent level controls. Procedural visuals, icon and effects have no downloaded asset-pack dependencies. System fonts use Avenir Next/Georgia when available and engine/system fallbacks elsewhere.

## Pixel-art assets

A stage may set `"background": "res://art/my_day.png"` to use its own landscape. If omitted, `landscape.gd` chooses the seasonal reference. Use 16:9 pixel-art landscapes with atmospheric distance, a quiet lower third and no painted collision platforms. The renderer pans the plate subtly; collision and foreground objects remain independent. The current landscape plates pan as complete images rather than independent painted depth layers.

The five 64×64 maps in `art/materials/` preserve the earlier texture experiments and can be regenerated with `tools/bake_materials.gd`. The current terrain renderer uses palette-driven shapes instead of these maps, keeping faces quieter and top edges consistent. `art/trees.png` contains June, October and January trees; source rectangles are defined in `landscape.gd`. `art/squallkeeper.png` is the transparent boss sprite. Art provenance and generation prompts are in `art/README.md`.

`art/pixel_world.gdshader` composites scenery, terrain and actors on a consistent 640×360 pixel grid. The HUD, menus and text render above it at native resolution for readability. The viewport remains 1280×720 logical pixels. Stages can set `world_top` from 0 down to -3072 on the 48-pixel grid, retaining the bottom at 720. Terrain, markers, hazards, scenery and water use world coordinates; the camera follows both axes and snaps to a restored checkpoint. The workshop compiles negative rows and preserves `world_top`. Increase or decrease `pixel_grid` to explore a different visual resolution without rewriting level geometry.

The art cache retains at most sixteen textures and evicts the least recently used resource. Visiting more dates therefore does not retain every stage painting indefinitely.

The boss sky layers `art/storm_clouds.png` over the June countryside with its own light, rain curtains and drifting clouds. Regenerate that code-authored cloud map with `tools/bake_storm.gd`.

## Countryside decoration and terrain · 0.3

Terrain colors live in `content/terrain_styles.json`. A stage defaults to its `season` key and may override it with `terrain_style`. Each style provides `outline`, `soil`, `soil_light`, `soil_dark`, `seam`, `grass`, `grass_shadow`, `top`, `wood`, `wood_light` and `wood_top` as six-digit hex colors. `terrain_art.gd` uses the same silhouette and cap rules for every season. Ice, springs, crumble platforms and moving timber retain distinct visual cues. Their collision and mechanics remain in `world.gd`.

Set `decoration_profile` to `early_summer` to enable sparse grass-edge planting, hanging ivy, and near riverbank foliage. Author landmarks in a stage's optional `decorations` array:

```json
"terrain_style": "june",
"decoration_profile": "early_summer",
"decorations": [
  {"type": "fence", "platform": 0, "offset": 35, "width": 140},
  {"type": "flowerbed", "platform": 0, "offset": 285, "width": 72},
  {"type": "birdhouse", "platform": 0, "offset": 420, "scale": 0.85},
  {"type": "reeds", "x": 840, "y": 646}
]
```

Supported props: `fence`, `hedge`, `flowers`, `flowerbed`, `tree`, `ivy`, `birdhouse`, `signpost`, `stone_wall`, `reeds`, `boulder`, `beehive`. An entry uses either world `x`/`y` or a zero-based `platform` anchor with optional `offset` and `offset_y`. Anchored props follow moving platforms and disappear with crumbled platforms. `width` controls beds, fences, walls and boulders; `height` controls hedges, fences and ivy; `scale` controls trees and birdhouses. Prop defaults are in `scenery.gd`.

`layer` defaults to `back`, behind the terrain and actors. Use `front` only for low or hanging detail that stays clear of the playable top and hazard corridor. Decorations have no collision. They are culled outside the camera margin; only the active stage is loaded. Platform-edge plants leave 32-pixel margins, and automatic ivy begins below the top cap. Bottom framing stays below Y=674. Authored props still need a visual review for the specific jump route.

The background grade compresses contrast more strongly near the playable plane while retaining the open blue sky. The distant plate, middle-distance hedges, world-anchored props and near reeds move at different rates. Keep these layers visually distinct; reserve continuous pale top edges and strong dark frames for real platforms. See `ART_DIRECTION.md` for composition guidance.


## Ground and draw order · 0.5

See `GROUND_AND_LAYERS.md` for the explicit rendering passes and floor contract. Raised objects belong in `platforms`; scenery belongs in `decorations`. The base ground is generated separately at runtime and appended after authored platforms, so decoration anchors continue to refer to authored platform indices. Never put obstacles through spawn, checkpoint or goal positions. The content validator rejects those overlaps.

The 0.5 layouts preserve checkpoint ordering and collectible ordering/x positions. Existing in-progress saves therefore resume at the corresponding lantern on the new floor and retain collected-mote identities. Completed records are retained. The vertical placement of motes has been adapted to the new routes.

## Day-specific June designs

See `JUNE_02_08.md` for the independent 2–8 June design briefs and their `identity`, `ambience`, `background`, `terrain_style`, decoration and music contracts. These are seven separate content files, not palette swaps. The catalog supplies campaign ordering and the workshop day/music menus. Layout files are serialized at full floating-point precision so animation phases survive round trips.


## Monthly samples and campaign dash · 0.9

All current stages opt into `abilities: ["charge_dash"]`. `ambience.month_scene` selects additional monthly scenery and weather through `content/month_scenes.json`; monthly terrain palettes remain in `terrain_styles.json`. See `MONTHLY_SAMPLES.md` for the new dates, landmark vocabulary and workshop round-trip contract.
