# Extended campaign and workshop · 0.12.0

All 29 playable dates have at least doubled in length. Each has six named challenge sections, substantial climbs and descents, and over 50 independent spike placements. An individual placement is a rectangle containing several visible teeth; the table reports both, so a single long spike strip does not masquerade as dozens of separate placements.

The established opening of each day is a warmup. The longer routes use their own named elevation sequences, gap rhythms, materials and day-specific decoration. Rising steps, narrow ledge edges, underside/wall teeth and descending landings make the flat base floor a hazardous fallback. Autumn includes crumbling perches, winter alternates ice with stone, wind and waterfall days retain local forces, and November remains physically submerged with changing-depth chamber openings. Charge-dash defaults are unchanged: original profile, horizontal multiplier 1.5. The 17-station Dash Lab is intact.

The 30 June boss now follows a long approach. Its health and attacks start only on entering the final arena. Arena bounds, projectiles, drawing, camera and phase retries use the arena position; the existing three survival phases remain 105 seconds in total.

## Measurements

| Day | Before → now (px) | Spike placements | Visible tips | Elevation change (px) |
|---|---:|---:|---:|---:|
| 06-01 | 10,080 → 23,424 | 164 | 1094 | 864 |
| 06-02 | 6,720 → 18,768 | 152 | 1027 | 912 |
| 06-03 | 6,720 → 19,680 | 156 | 1063 | 1056 |
| 06-04 | 6,720 → 16,128 | 116 | 756 | 1152 |
| 06-05 | 6,720 → 20,400 | 155 | 1072 | 1104 |
| 06-06 | 6,720 → 17,520 | 123 | 830 | 1152 |
| 06-07 | 6,720 → 18,528 | 145 | 976 | 1200 |
| 06-08 | 6,720 → 19,680 | 149 | 1024 | 1104 |
| 06-09 | 6,720 → 18,000 | 132 | 894 | 1248 |
| 06-10 | 6,720 → 19,056 | 150 | 1038 | 1104 |
| 06-11 | 6,720 → 19,392 | 146 | 1005 | 1248 |
| 06-12 | 6,720 → 18,240 | 137 | 912 | 1344 |
| 06-13 | 6,720 → 17,136 | 132 | 850 | 1200 |
| 06-14 | 6,720 → 18,048 | 140 | 949 | 1248 |
| 06-15 | 10,800 → 23,424 | 151 | 1058 | 1344 |
| 06-16 | 6,720 → 18,720 | 146 | 980 | 1248 |
| 06-17 | 6,720 → 17,856 | 132 | 898 | 1296 |
| 06-30 | 1,296 → 13,152 | 138 | 958 | 1344 |
| 07-16 | 7,680 → 20,976 | 154 | 1101 | 1344 |
| 08-23 | 7,680 → 20,592 | 151 | 1078 | 1248 |
| 09-14 | 7,680 → 19,296 | 138 | 956 | 1296 |
| 10-12 | 10,320 → 21,552 | 135 | 938 | 1344 |
| 11-19 | 7,680 → 20,592 | 164 | 1162 | 1344 |
| 12-08 | 7,680 → 19,248 | 141 | 978 | 1248 |
| 01-18 | 9,984 → 22,608 | 155 | 1048 | 1344 |
| 02-17 | 7,680 → 20,304 | 153 | 1086 | 1296 |
| 03-09 | 10,896 → 23,808 | 153 | 1082 | 1344 |
| 04-11 | 7,680 → 19,680 | 140 | 972 | 1392 |
| 05-24 | 7,680 → 20,976 | 160 | 1159 | 1488 |

## Editing and tuning

Use **Charge dash: On** in the workshop. Hold the rebound dash button during Playtest, aim, then release; the shared lab profile is used. Select **Height** to make room for vertical work. Shift-scroll, Up/Down or Space-drag pans vertically. The Spikes arrow cycles four directions. Save/open, autosave and undo retain all of these settings.

The baked stage JSON is the game’s source of truth. `challenge_recipes.json` records the authoring recipes, and `challenge_report.json` records measurements for this version. `challenge` inside a stage contains named rooms and route waypoints for QA; it does not drive or constrain the player at runtime. If you change a copied level, revise or remove its QA annotations before incorporating it as a campaign day.

`tools/build_challenge_routes.py --write` regenerates this complete expansion from the `v0.11.0` Git tag and `content/challenge_recipes.json`; it deliberately requires `--write` because regeneration replaces the baked stage files. Ordinary edits only require changing the stage JSON or using the workshop. A source ZIP can be edited and played without Git; regeneration from the historical tag requires a repository clone.

The original art, supplied music, movement tuning, dash tuning and swimming tuning are retained. Waterfall updrafts now leave active dash velocity alone instead of capping the burst. The source, assets and current version are tracked in the private GitHub repository; player saves and app packages are excluded.

Automated route checks establish reachability, not final human balance, five-minute pacing, or a finished 30-hour campaign. The prior baseline is tagged for comparison.
