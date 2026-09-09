# June chapter · 0.13.0

June is now a complete 30-date chapter: 29 exploration journeys and one five-arena monthly boss. Ordinary dates have five substantial sections, each named as a physical place. The room blueprints specify their own layouts and transitions. Camera and checkpoints work at the new elevations; optional routes can return into earlier space.

## The daily journeys

| Date | Day | Connected places |
|---|---|---|
| 1 June | Opening the Gate | The village gate → The open fields → Along the hedgerow → The first stream → The hilltop overlook |
| 2 June | Skipstones and Dragonfly Wings | The grassy riverbank → Stepping-stone shallows → The reed marsh → The broad river → The sunny pond |
| 3 June | Kites Above the Clover | Clover beneath the strings → The windy hillside → The kite field → The high ridge → The exposed hilltop |
| 4 June | Sunpatches on the Orchard Wall | The country lane → The orchard outskirts → Inside the orchard → The old stone wall → The upper sun terraces |
| 5 June | The Meadow Express | The quiet meadow → The rural platform → Cargo in motion → Beside the rails → The country express |
| 6 June | Sunlight on the Waterwheel | The riverside path → The mill approach → Sunlight on the waterwheel → Behind the mill → The rocky upstream |
| 7 June | The Sunflower Shortcut | The familiar field path → Above the sunflowers → The hidden crop route → Over the farm fences → The shortcut rejoins the valley |
| 8 June | Lanterns in the Breeze | The late-afternoon meadow → The sunset path → The dusk woodland edge → The lantern gardens → Under the deep-blue sky |
| 9 June | The Glasshouse Run | The formal garden → The glasshouse entrance → The palm-house canopy → The maintenance tunnels → Along the rooftop beams |
| 10 June | Cloverfield Crossing | The low meadow → The clover slopes → The shallow stream → Within the hedgerow → The open field beyond |
| 11 June | Riverside Rush | The upper riverbank → At the rapids edge → The bridge network → The riverside cliffs → Down beside the river |
| 12 June | The Orchard Climb | The orchard floor → The fruit-tree terraces → Among the high branches → The retaining walls → The high orchard overlook |
| 13 June | Wildflower Way | The country flower path → The dense flower meadow → The flower-covered rocks → The pollinator clearing → The panoramic ridge |
| 14 June | The Woodland Detour | The sunny field → The woodland entrance → The shaded forest floor → The fallen-log canopy → The bright clearing |
| 15 June | Windmill Heights | The lower farmland → The windy hillside → The windmill exterior → Within the mill machinery → The ridge beyond the sails |
| 16 June | The Hayfield Hop | The fresh meadow → The cut hay rows → The high hay bales → The barn loading floor → The golden field |
| 17 June | Brookside Bounce | The small woodland brook → The stepping stones → The narrow ravine → Brookside bounce → The waterfall clearing |
| 18 June | The Garden Maze | The formal garden gate → The hedge maze → The fountain courtyard → The hidden overgrown garden → The raised garden terrace |
| 19 June | Hilltop Sprint | The lower fields → The zigzag ascent → The rocky ridge → The exposed summit → The rapid descent |
| 20 June | The Long Grass | The short meadow → Where the grass grows tall → The hidden path network → The wooden grass walk → The clear field |
| 21 June | Midsummer Run | The midsummer morning → The flower valley → The sunlit hill → The midsummer plateau → The golden-evening horizon |
| 22 June | The Old Footbridge | The country lane → The stream valley → The bridge approach → Above and below the footbridge → The riverside wood |
| 23 June | Buttercup Trail | The gentle meadow → The buttercup field → The rolling hills → The narrow flower trail → The quiet pond |
| 24 June | The River Bend | The straight riverbank → Around the sweeping bend → The eroded outer bank → The wet inner bank → The river viewpoint |
| 25 June | Sunlit Slopes | The valley floor → The grassy incline → The rocky sun slope → The bright upper meadow → The long downhill |
| 26 June | The Hedgeway | The open farm lane → The narrow hedge corridor → Gaps through the hedge → The raised hedge-top route → The countryside exit |
| 27 June | Meadow Overlook | The low meadow → The wooded rise → The cliff terraces → The meadow overlook → Into the new valley |
| 28 June | The Country Mile | The village outskirts → The long fields → The working farm → The country river crossing → The distant rolling lane |
| 29 June | Last Light of June | The last afternoon fields → The sunset ridge → The shadowed woodland → The lantern countryside → The storm’s quiet threshold |
| 30 June | The Squallkeeper | The first squall → The wind-tossed terraces → Run with the storm → The crossing winds → The last light returns |

## Chapter progression

Early June introduces low countryside vaults, rivers, wind, orchards and the first mechanical landmarks. Middle June moves through glasshouses, river cliffs, real orchard altitude, woodland, mills and farms. The Garden Maze and Long Grass have returning routes and concealed side spaces. Midsummer Run uses the largest bright plateau; later dates broaden the journey and lengthen the light. Last Light of June transitions through sunset and lanterns to the storm threshold.

The first day now starts at the village edge and gradually opens through fields, a hedgeway, a stream and an overlook. It introduces normal jumping before requiring deeper charged transfers. Dash is available throughout, but low passages, broad walking surfaces, timed rides and river/spring sections provide other movement tasks.

## Optional spaces

Ivy covers fade as the player approaches a side chamber. These covers have no collision; the underlying blocks and entrance gaps are real geometry. Collectibles inside use ordinary sunmote persistence. The Garden Maze returns left along a middle corridor, rises through a side shaft and crosses above the earlier route; it also has a lower potting chamber, an upper nook and a separate hidden-garden room. Other optional shelves and crop/woodland passages leave room for later Easter eggs without adding a storyline.

## The Squallkeeper

| Phase | Place | Play |
|---|---|---|
| 1 | The first squall | Read amber falling-seed warnings and learn the dodge rhythm. |
| 2 | The wind-tossed terraces | Change elevation while horizontal and falling attacks overlap. |
| 3 | Run with the storm | Keep ahead of the advancing storm across the causeway; health progress follows distance. |
| 4 | The crossing winds | Read simultaneous vertical and crossing patterns from the separated terraces. |
| 5 | The last light returns | Survive the tightest pattern, then walk through the clearing-sky aftermath to the gate. |

The configured survival durations are 24, 28, 32 and 36 seconds. The chase contributes 28 health-progress units based on distance rather than a passive timer. Clearing a phase opens its exit; moving into the next arena establishes its checkpoint. Saving or dying after clearing a phase preserves that clearance. No attack button or melee damage is involved.

## Music and visual presentation

The supplied 1–22 June tracks are retained. `JUNE_MUSIC_18_22.json` records the five newly incorporated files and hashes. Dates 23–29 currently use distinct synthesized sketch compositions. Their score source is in `tools/synthesize_june_scores.py`; it does not overwrite supplied music. The existing Squallkeeper score remains.

Each place selects a background environment and light state. Existing original June landscape plates and prop vocabulary are recomposed into the routes; new interiors, night skies, tall grass and lantern passes add motion and depth. Platform caps, player and hazards remain sharp above the scenery. Lights change spatially as the player travels, rather than on a real-time deadline. The final boss aftermath fades back into warm light.

## Editing

Edit the explicit `content/layouts/06-DD.json` blueprint and compile with `python3 tools/build_authored_stages.py 06-DD --write`. Each section has local geometry and an `origin`; its `visual` describes place and light. Optional-area rectangles use world coordinates. The compiler creates `journey_regions`, `secret_areas` and the ordinary stage geometry. Detailed settings are validated and preserved by workshop copying, though the toolbar does not yet provide environment or boss inspectors.

Increase the blueprint `revision` when moving checkpoints, collectibles or fundamental geometry. The runtime detects old runs and restarts them safely at the entrance. Ordinary stage JSON and the workshop installer remain available for new days. See `AUTHORED_DAYS.md` for the general pipeline and `VALIDATION.md` for verification.
