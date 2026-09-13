# Monthly challenges · 0.16.0

The title screen and calendar link to **Monthly challenges**. Left/right or the arrow buttons change month; each collection exposes eleven cards. Click a card and enter it, or use Tab/up/down and Enter/controller A. Completion, best times and unfinished runs use stable `MM-XNN` save IDs. “Next” continues in challenge order. Main calendar dates and future boss slots remain separate.

## Difficulty

All 51 existing maps have exactly ten times their prior mechanism count. The shared extreme authoring values are recorded in `content/extreme_rules.json`; per-instance values remain in the blueprints. Landing tops are reduced to narrow catches by spikes, undersides and long ground stretches gain spike banks, movement machinery runs faster, and existing current/wind zones are stronger. The June boss's five phases remain but attack intervals are divided by ten; its chase speed is 430 instead of 215.

Each new stage contains four connected places, 12,864–13,248 world pixels and 1,408–2,012 visible spikes. The eleven architectural forms are intentionally recombined and evolved across seasonal conditions. There are no identical full platform layouts or repeated full scenery compositions. This is an offline authored collection built from reusable architectural forms, not 132 individually hand-playtested bespoke campaigns.

**Reachability, survival and human difficulty are untested by explicit request.** There is no claim that any route is beatable. Historical route proofs are retained only as history. Base movement, the original charge-dash profile (horizontal multiplier 1.5), swimming and the Dash Lab remain unchanged.

## Content pipeline

- `content/monthly_challenges.json`: human-readable manifest of all 132 additions.
- `content/catalog.json`: separate `stages` (calendar) and `challenges` lists.
- `content/layouts/MM-XNN.json`: editable local geometry, hazards, zones, scene compositions and unverified design waypoints.
- `tools/build_authored_stages.py --write`: compile explicit blueprints into normal game/editor data.
- `tools/build_monthly_challenges.py --write`: deliberate regeneration of all 132 challenge blueprints from their original authoring source. It overwrites challenge edits; do not use it for routine compilation.
- `scripts/challenge_scenery.gd`: original code-native scene renderer. A region's `composition` owns six palette colors, three ridge silhouettes, its landmark list, sun position, waterline and weather. Eleven architectural landmark families are composed differently for every place. The renderer shares no collision geometry with terrain.
- `tools/synthesize_challenge_scores.py`: NumPy-based offline synthesis of 132 distinct temporary loops in `audio/challenges/`. These are original sketches, intended for replacement with final compositions.
- `content/extreme_report.json`: exact before/after mechanism counts for the original 51 maps.

The 51 pre-existing map atlases are unchanged. New challenge scenery is drawn from project-native code and data; no image-generation service or external image assets were used for this expansion.

## The 132 additions

### June

| No. | Stage | Opening form |
|---|---|---|
| 1 | The Razorwind Pasture | Sail helix |
| 2 | Foxglove Freefall | Counterweight well |
| 3 | The Broken Stile | Crosswind chimney |
| 4 | Sunwheel Spires | Floodgate organ |
| 5 | Bramble Bellows | Needle descent |
| 6 | The Beekeeper’s Needle | Fracture staircase |
| 7 | The Gallows Orchard | Canopy zipper |
| 8 | Cloverlock Canal | Crown transfer |
| 9 | Thirteen Haylofts | Press vault |
| 10 | The Skylark Crucible | Moving freight |
| 11 | Noon Above the Thorns | Bell circuit |

### July

| No. | Stage | Opening form |
|---|---|---|
| 1 | The Saffron Furnace | Press vault |
| 2 | Barleyknife Ravine | Moving freight |
| 3 | The Copper Silo | Bell circuit |
| 4 | White Heat Viaduct | Sail helix |
| 5 | Cicada Overdrive | Counterweight well |
| 6 | The Scorched Granary | Crosswind chimney |
| 7 | Heliostat Heights | Floodgate organ |
| 8 | The Dry Well Engine | Needle descent |
| 9 | Sunstroke Switchback | Fracture staircase |
| 10 | The Thresher’s Crown | Canopy zipper |
| 11 | High Summer Hellgate | Crown transfer |

### August

| No. | Stage | Opening form |
|---|---|---|
| 1 | The Amber Breakwater | Fracture staircase |
| 2 | Thunder on the Moorings | Canopy zipper |
| 3 | The Golden Bell Tower | Crown transfer |
| 4 | Stormglass Quarry | Press vault |
| 5 | The Last Light Rig | Moving freight |
| 6 | Copper Rain Causeway | Bell circuit |
| 7 | The Creaking Drydock | Sail helix |
| 8 | The Lightning Orchard | Counterweight well |
| 9 | Floodgate at Dusk | Crosswind chimney |
| 10 | The Horizon Engine | Floodgate organ |
| 11 | Sunset’s Falling Teeth | Needle descent |

### September

| No. | Stage | Opening form |
|---|---|---|
| 1 | The Redleaf Guillotine | Crosswind chimney |
| 2 | Acorn Ironworks | Floodgate organ |
| 3 | The Auburn Belfry | Needle descent |
| 4 | The Mushroom Needle | Fracture staircase |
| 5 | The Copper Canopy | Canopy zipper |
| 6 | Leafstorm Sawmill | Crown transfer |
| 7 | The Hollow Chestnut | Press vault |
| 8 | The Harvest Pendulum | Moving freight |
| 9 | The Russet Labyrinth | Bell circuit |
| 10 | Briarwood Observatory | Sail helix |
| 11 | The Last Falling Leaf | Counterweight well |

### October

| No. | Stage | Opening form |
|---|---|---|
| 1 | The Blackcloud Dynamo | Bell circuit |
| 2 | Thundercoil Cathedral | Sail helix |
| 3 | The Weather Vane Trap | Counterweight well |
| 4 | The Flashflood Organ | Crosswind chimney |
| 5 | Lightning in the Rafters | Floodgate organ |
| 6 | The Stormwatch Spindle | Needle descent |
| 7 | The Cinderbell Crossing | Fracture staircase |
| 8 | Rainwire Crucible | Canopy zipper |
| 9 | The Broken Conductor | Crown transfer |
| 10 | The Gale’s Drawbridge | Press vault |
| 11 | The Eye of the Machine | Moving freight |

### November

| No. | Stage | Opening form |
|---|---|---|
| 1 | The Submerged Belfry | Crown transfer |
| 2 | Pressure at Blackwater | Press vault |
| 3 | The Kelpbound Turbine | Moving freight |
| 4 | The Sunken Signal Box | Bell circuit |
| 5 | The Drowned Clockface | Sail helix |
| 6 | The Silt Cathedral | Counterweight well |
| 7 | The Undertow Cage | Crosswind chimney |
| 8 | The Flooded Foundry | Floodgate organ |
| 9 | The Rustwater Needle | Needle descent |
| 10 | The Abyssal Lock | Fracture staircase |
| 11 | The Last Airless Garden | Canopy zipper |

### December

| No. | Stage | Opening form |
|---|---|---|
| 1 | The Frostline Furnace | Needle descent |
| 2 | The Snowblind Sluice | Fracture staircase |
| 3 | The Icicle Bell Tower | Canopy zipper |
| 4 | The Frozen Boiler | Crown transfer |
| 5 | Steam in the Fir Trees | Press vault |
| 6 | The Avalanche Gantry | Moving freight |
| 7 | The Winterglass Gallery | Bell circuit |
| 8 | The Whiteout Mill | Sail helix |
| 9 | The Coalstar Chimney | Counterweight well |
| 10 | The Silent Snowpress | Crosswind chimney |
| 11 | Embers Under Ice | Floodgate organ |

### January

| No. | Stage | Opening form |
|---|---|---|
| 1 | The Blueice Guillotine | Counterweight well |
| 2 | The Glacier Clock | Crosswind chimney |
| 3 | The Hoarfrost Cathedral | Floodgate organ |
| 4 | The Black Ice Circuit | Needle descent |
| 5 | The Frozen Pendulum | Fracture staircase |
| 6 | The Polar Gearhouse | Canopy zipper |
| 7 | The Splintering Rink | Crown transfer |
| 8 | The Aurora Spindle | Press vault |
| 9 | The Ice Organ | Moving freight |
| 10 | The Midnight Crevasse | Bell circuit |
| 11 | The Deep Winter Crown | Sail helix |

### February

| No. | Stage | Opening form |
|---|---|---|
| 1 | The Meltwater Trap | Moving freight |
| 2 | Snowdrop Sawmill | Bell circuit |
| 3 | The Thawing Belfry | Sail helix |
| 4 | The Cracked Reservoir | Counterweight well |
| 5 | The Dripping Crown | Crosswind chimney |
| 6 | The Last Frost Engine | Floodgate organ |
| 7 | The Crocus Guillotine | Needle descent |
| 8 | The Slushwater Circuit | Fracture staircase |
| 9 | The Hollow Icehouse | Canopy zipper |
| 10 | The Returning Briar | Crown transfer |
| 11 | The Breakup Cascade | Press vault |

### March

| No. | Stage | Opening form |
|---|---|---|
| 1 | The Cascade Helix | Canopy zipper |
| 2 | The Waterfall Needle | Crown transfer |
| 3 | The Crosswind Organ | Press vault |
| 4 | The Rapids Dynamo | Moving freight |
| 5 | The Mistbound Viaduct | Bell circuit |
| 6 | The Whitewater Spindle | Sail helix |
| 7 | The Roaring Aqueduct | Counterweight well |
| 8 | The Updraft Cathedral | Crosswind chimney |
| 9 | The Torrent’s Teeth | Floodgate organ |
| 10 | The Stormwater Crown | Needle descent |
| 11 | The Falls Without End | Fracture staircase |

### April

| No. | Stage | Opening form |
|---|---|---|
| 1 | The Blossom Guillotine | Floodgate organ |
| 2 | The Rainbow Dynamo | Needle descent |
| 3 | The Rainwater Belfry | Fracture staircase |
| 4 | The Petalwind Spire | Canopy zipper |
| 5 | The Greenhouse Needle | Crown transfer |
| 6 | The Showerbound Switchyard | Press vault |
| 7 | The Orchard Siphon | Moving freight |
| 8 | The Roseglass Organ | Bell circuit |
| 9 | The Wisteria Circuit | Sail helix |
| 10 | The Pollenstorm Mill | Counterweight well |
| 11 | The Last Rain Gate | Crosswind chimney |

### May

| No. | Stage | Opening form |
|---|---|---|
| 1 | The Verdant Crucible | Sail helix |
| 2 | The Rosewheel Cathedral | Counterweight well |
| 3 | The Foxglove Crown | Crosswind chimney |
| 4 | The Garden of Blades | Floodgate organ |
| 5 | The Honeysuckle Helix | Needle descent |
| 6 | The Sunlit Siphon | Fracture staircase |
| 7 | The Laurel Guillotine | Canopy zipper |
| 8 | The Mayfly Ironworks | Crown transfer |
| 9 | The Briar’s Final Waltz | Press vault |
| 10 | The Emerald Observatory | Moving freight |
| 11 | The Year’s Last Thorn | Bell circuit |
