# A playable sample in every month · 0.11.0

Open **Explore the calendar** and use the twelve shortcuts along its bottom edge. The year now contains 29 playable dates, including all 1–17 June scenes and the eight independent monthly samples. Every current stage enables charge dash. The base running/jumping profile and original stage geometry are unchanged.

| Date | Sample | Setting and movement |
|---|---|---|
| 16 July | The Long Light of Barley Common | Wheat, harvest carts and bright sun. Tailwinds, stacked hay and short dash connections. |
| 23 August | The Lake Before the Storm | Golden lakeside light beneath approaching clouds. Jetties, moving ferries and pulsing headwinds. |
| 14 September | Copper Leaves, Quiet Footsteps | Copper woodland and leaf fall. Fragile elevated terraces and narrow timber perches. |
| 19 November | Lanterns Beneath the Flood | Submerged countryside, buoyancy, free swimming, alternating over/under passages and opposing currents. |
| 8 December | The First White Mile | Fir woods, lit cabins and increasing snow cover. Sheltered ledges followed by telegraphed falling ice. |
| 17 February | Where the Ice Lets Go | Thaw pools, snowdrops and exposed stone. Alternating ice strips, dry braking spots and low water flow. |
| 11 April | A Rainbow Between Showers | Blossom, garden arches and a rainbow. Waterfall ascent, wind and high diagonal connections. |
| 24 May | The Garden at the Edge of May | Flower beds and long garden walks. Spring launches, moving upper platforms and controlled descents. |

Each addition is a 7,680 px reference route with three named passages, two checkpoints and optional elevated sunmotes. The continuous floor and 48 px terrain grid remain consistent with the existing samples. Each month has its own layout, terrain palette, landmark vocabulary, weather and original temporary score sketch. These are compact design references, not finished five-minute stages or a new set of monthly bosses.

The new monthly scenes combine the existing distant pixel-art landscape library with original code-drawn landmarks and environmental animation. They retain the terrain/player/hazard layer ordering. November now has a separate environmental swimming controller, detailed in `UNDERWATER.md`. No second core special mechanic is added.

## Shared charge dash

The original charge-dash settings are restored in **0.9.1**, with **horizontal multiplier 1.5** as the only exception. Vertical strength is **1.0**; the charge curve, force range, momentum, cooldown, air rules and launch-speed cap all match the original 0.8 defaults. The campaign HUD still shows charge and availability.

The one-time 0.9.1 dash reset still applies to saves from earlier versions; this update does not reset it again. Progress, bindings and unrelated settings are preserved. Later lab adjustments persist normally, and **Defaults** restores that original profile with horizontal 1.5. Lab tuning also applies when entering a campaign stage.

The lab retains all eleven original stations and adds six 3,840 px courses: a momentum circuit, precision rhythm, ice/lift carry, a vertical relay, headwind crossing and a mixed endurance course. Total length increases from **21,120 to 44,160 px**. Scroll its station list to reach all seventeen. Selecting a station resets its environmental phase for repeatable attempts. Lab attempts never replace campaign progress.

## Content pipeline

- The new dates are ordinary `content/stages/MM-DD.json` files listed in `content/catalog.json`.
- `abilities: ["charge_dash"]` opts a layout into the modular ability; blank workshop layouts inherit it from the opening-day template.
- `ambience.month_scene` selects a scene in `content/month_scenes.json`. That registry selects the distant plate, tint and weather; `scripts/month_scenery.gd` draws its landmarks and animation.
- Per-month terrain colours live in `content/terrain_styles.json`. Keep bright, continuous caps reserved for playable blocks.
- Each new day references its own `audio/<month>.wav`. `tools/synthesize_month_scores.py` reproduces these temporary original music sketches without touching the supplied June music.
- The workshop can copy, compile, export and reopen all new samples while retaining scene metadata, decorations and the ability. Seasonal landmarks are retained as authored scenery; the small editor's brush palette remains focused on its existing block and basic-prop tools.

See `CHARGE_DASH.md` for controls and tuning fields, and `VALIDATION.md` for verification and playtesting limits.
