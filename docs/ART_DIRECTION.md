# Yearbound countryside · 0.4

Early summer should feel alive and inviting: an open blue sky, green valley, river reflections, birds, flowers and small signs of rural life. Scenic detail belongs in distinct depth layers, with a quieter landscape behind crisp playable terrain.

The requested reference is Towerverse's density, layering and polish. Use those as composition goals while developing Yearbound's own countryside vocabulary. Reference links: [creator's release post](https://x.com/16lordGD/status/1771269097570943138) and [Nexus's showcase](https://www.youtube.com/watch?v=kcjXmwmfmJ4). No reference-game art, level layout or props are included.

## Terrain rendering (0.4, September 2026 overhaul)

Terrain is no longer drawn as bordered 48×48 tiles, and the world is no longer composited through a coarse 640×360 pixel grid. `terrain_art.gd` now renders each platform and the base ground as one **composed mass**:

- The drawn silhouette always matches the collision rectangle exactly. Decoration never extends past it, and no decorative element may resemble a platform, cap or hazard.
- Solid fill is continuous across a platform; adjoining platforms merge visually because borders are only drawn on **exposed** edges (detected via the shared `block_cells` occupancy map).
- The walk edge is always the brightest element: a 2 px light line over a mid band with a scalloped underside. Interior texture (stones, strata, masonry courses, log grain, hay bands, ice sheen, crumble fissures) stays below the cap's contrast.
- Cap vegetation is paired, curved, low blades (never single straight strokes, which read as spikes); frozen caps get low snow clumps instead. Springs keep their flower cap and chevron marker; moving timber keeps its diamond.
- Underside shadow and notches stay inside the collision rect. Exposed sides get a dark rim with a thin lit inner line for thickness.
- The pixel-composite pass remains in place but samples at the native 1280×720 grid; restoring `pixel_grid` to `Vector2(640,360)` in `main.gd` reverts it. Painterly textures use linear filtering.
- The layout workshop still paints the legacy per-cell `tile()` look; playtests and the game itself show the composed masses.

## A readable scene

| Layer | Treatment | Role |
|---|---|---|
| Sky and distant landscape | Fine pixel painting; reduced lower-landscape contrast and saturation | Scale, light and atmosphere |
| Middle-distance meadow | Muted hedges and fence fragments with independent parallax | Connect the distant valley to the riverbank |
| Authored countryside props | Clustered flower beds, trees, birdhouses, beehives and walls; irregular silhouettes | Give stretches of the path distinct landmarks |
| Playable masses | Exact rectangular silhouette, continuous bright cap, material-specific body | Communicate where feet can land immediately |
| Face detail | Sparse large-scale facets, wood grain, masonry joints | Craft and material identity without mottled noise |
| Nearest riverbank | Darker reed and leaf clusters beneath the play area | Depth and motion without hiding jumps |

World art is composited at the native 1280×720 grid. Physics uses the same logical coordinates. Keep small accents crisp, and prefer restrained palette steps to smooth photorealistic shading.

## Placement rules

Group decoration into small scenes and leave clear stretches between them. A fence, flower bed and birdhouse make one garden vignette; a rock and reeds establish a river margin. Increase density inside those groups instead of covering every square of the screen.

Keep the ends of platforms visibly open. Continuous bright tops belong to collision surfaces. Decorative hedges have stepped, irregular edges; fences are muted and thin. Put tall props behind the terrain and player. Keep trailing ivy beneath the grass cap. Near-screen foliage must stay beneath required landings and hazards.

Give moving timber a pale walkable strip, warm planks, end grain and a central diamond. Springs retain flowers above their cap; ice retains pale sheen streaks and snow edges; leaf platforms retain cracked undersides. Shared framing should unify these mechanics without erasing their identity.

## Extending the year

`terrain_styles.json` supplies shared color roles. `scenery.gd` draws reusable prop families, and each stage arranges them through `decorations`. Reuse the drawing grammar while authoring a new composition and landmark sequence for each day. Palette swaps alone do not establish a new day's identity.

The current June days share the initial landscape plate. Future production can add separate day-specific plates and independently painted depth layers without changing collision or controller code. Keep asset paths, decorative placement and gameplay geometry separate.
