# Current campaign artwork · 0.14.0

All 41 campaign maps now use dedicated generated pixel-art atlases in `maps/`, with unique views for 219 named places and the June boss aftermath. Exact prompts and SHA-256 hashes are in `maps/PROVENANCE.json`; see `../docs/MAP_SCENERY.md` for integration. Original PNGs are copied intact and sampled at runtime. Older art below remains for menus, legacy workshop exports and source history.

# Yearbound pixel-art direction · 0.3

Created for this project on 8 September 2026 using the built-in `image_gen.imagegen` tool. The final art uses detailed 16-bit-inspired pixel shapes, seasonal palettes and crisp silhouettes. These are generated game assets, not photographs of identified real places or assets from a third-party pack.

`PIXEL_PROMPTS.json` records the the successful generation and redraw instructions. The four landscape paintings are `summer.png`, `autumn.png`, `winter.png` and `spring.png`; each was redrawn from a generated naturalistic composition into pixel art. The June boss uses a subdued summer landscape with an original, code-authored pixel cloud bank, drifting rain curtains and light shafts. Regenerate `storm_clouds.png` with `tools/bake_storm.gd`. The two June exploration stages intentionally share the initial summer landscape reference. Each future day can supply its own background resource.

`trees.png` is a transparent atlas containing June, October and January foliage. `squallkeeper.png` is a transparent storm-eagle sprite. Original output PNGs are preserved and sampled by the game at render time. Source regions for the tree atlas are documented directly in `landscape.gd`.

The five 64×64 maps in `materials/` preserve earlier code-authored pixel texture experiments. The 0.3 terrain uses native drawing from `terrain_styles.json` instead, with restrained face facets and clean continuous top surfaces. The original maps can be regenerated using `tools/bake_materials.gd`. The traveller uses articulated code animation with a copper scarf, pack and compact human silhouette.

`pixel_world.gdshader` gives scenery and actors a consistent 640×360 pixel grid. The interface and text render above this pass at native resolution. Collision geometry and movement stay independent of visual resolution. The landscape plates pan as complete images; independently painted depth layers remain a future art-production extension.

The 0.3 countryside props and animation in `scenery.gd` are original code-authored pixel shapes: flowers, hedges, ivy, fences, signs, birdhouses, beehives, rocks, walls and reeds. This pass uses no Towerverse artwork or downloaded prop pack. The requested reference concerns decoration density, layering and polish; Yearbound uses its own countryside arrangement and visual vocabulary. See `docs/ART_DIRECTION.md` for the reusable design rules.

## Monthly samples · 0.9

The eight monthly samples use the existing distant landscape library with original code-drawn landmarks, per-month grades and animated weather in `month_scenery.gd`. These additions include wheat and harvest carts, copper and blossom trees, boathouses, flood markers, firs, winter cabins, thaw pools, snowdrops and garden arches. No new third-party artwork was downloaded. The collision terrain keeps its own bright caps and dark borders in front of scenic props.

## June 9–17 · 0.11.0

Nine dedicated landscape plates, `june/06-09.png` through `june/06-17.png`, were generated with built-in imagegen on 9 September 2026. These original pixel-art scenes follow the supplied musical guides: a glasshouse, clover common, broad river, terraced orchard, wildflower meadow, woodland, windmill hill, hayfield and brook. `june/PROVENANCE_09_17.json` records all exact prompts, original output paths, saved asset paths and SHA-256 hashes. The PNGs are copied without postprocessing; the game applies its existing pixel shader and scenery grade.

`june_scenery.gd` adds separate animated props and water accents. The registry is `content/june_scenes.json`. Clear block terrain, player and hazards draw above this scenery. See `docs/JUNE_09_17.md` for each scene's composition and content workflow.
