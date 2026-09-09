# Yearbound countryside · 0.3

Early summer should feel alive and inviting: an open blue sky, green valley, river reflections, birds, flowers and small signs of rural life. The art remains pixel-based. Scenic detail belongs in distinct depth layers, with a quieter landscape behind crisp playable terrain.

The requested reference is Towerverse's density, layering and polish. Use those as composition goals while developing Yearbound's own countryside vocabulary. Reference links: [creator's release post](https://x.com/16lordGD/status/1771269097570943138) and [Nexus's showcase](https://www.youtube.com/watch?v=kcjXmwmfmJ4). No reference-game art, level layout or props are included.

## A readable scene

| Layer | Treatment | Role |
|---|---|---|
| Sky and distant landscape | Fine pixel painting; reduced lower-landscape contrast and saturation | Scale, light and atmosphere |
| Middle-distance meadow | Muted hedges and fence fragments with independent parallax | Connect the distant valley to the riverbank |
| Authored countryside props | Clustered flower beds, trees, birdhouses, beehives and walls; irregular silhouettes | Give stretches of the path distinct landmarks |
| Playable blocks | Exact rectangular silhouette, dark frame, continuous pale grass or timber top | Communicate where feet can land immediately |
| Face detail | Sparse facets, short ivy trails, wood grain, straps and nails | Craft and material identity without mottled noise |
| Nearest riverbank | Darker reed and leaf clusters beneath the play area | Depth and motion without hiding jumps |

All world art is composited at 640×360. UI remains above that pass. Physics still uses 1280×720 logical coordinates. Keep small accents at a visible pixel size, and prefer restrained palette steps to smooth photorealistic shading.

## Placement rules

Group decoration into small scenes and leave clear stretches between them. A fence, flower bed and birdhouse make one garden vignette; a rock and reeds establish a river margin. Increase density inside those groups instead of covering every square of the screen.

Keep the ends of platforms visibly open. Continuous bright tops belong to collision surfaces. Decorative hedges have stepped, irregular edges; fences are muted and thin. Put tall props behind the terrain and player. Keep trailing ivy beneath the grass cap. Near-screen foliage must stay beneath required landings and hazards.

Give moving timber a pale walkable strip, warm planks, dark straps and a central diamond. Springs retain flowers above their cap; ice retains pale cracks and snow edges; leaf platforms retain loose undersides. Shared framing should unify these mechanics without erasing their identity.

## Extending the year

`terrain_styles.json` supplies shared color roles. `scenery.gd` draws reusable prop families, and each stage arranges them through `decorations`. Reuse the drawing grammar while authoring a new composition and landmark sequence for each day. Palette swaps alone do not establish a new day's identity.

The current June days share the initial landscape plate. Future production can add separate day-specific plates and independently painted depth layers without changing collision or controller code. Keep asset paths, decorative placement and gameplay geometry separate.
