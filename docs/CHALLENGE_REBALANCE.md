# Playable challenge rebalance · 0.17.0

The 0.16 release interpreted “harder” as multiplicative hazard density and produced overlapping machinery, obstructed landings and oversized climbs. This revision removes that approach.

The original 51 calendar maps return to the earlier 0.15 expert geometry, mechanisms, platform speeds, environmental forces and boss timing. Their saved-layout revisions advance so an unfinished 0.16 run cannot resume inside changed terrain. Completed progress and settings remain.

All 132 monthly challenges remain available, with their names, scenery and music. They now have four linked places, eight mechanisms per map, broad clear catches, intentional spike beds, and at most 240-pixel standard rises. Freight docks pause; water gates allow a swimming crossing. Canopies cover the middle of a timed passage rather than the landing approach. Crumble transfers have a stable deck before the next machine. Wind acts across one transfer rather than through the waiting area.

The total mechanism count falls from 28,374 to 1,887. Density is no longer the difficulty target. The challenge comes from committing to a transfer, reading a machine cycle, and reaching the next stable platform.

The controller, original dash profile with horizontal multiplier 1.5, swimming code, terrain rendering and 17-station Dash Lab are unchanged. No second ability or story content was added.

## Verification

`tests/challenge_routes.gd` runs a continuous, unassisted attempt through each new challenge. It supplies actual controls; hazards, collisions, currents and platform motion stay active. It never relocates the player along a route. `tests/authored_routes.gd` does the same for the 50 non-boss calendar stages. The boss suite separately survives each full-duration attack arena from an arena perch and traverses the chase using real inputs.

The first pass identified 288- and 336-pixel rises that failed under the current dash. Those route silhouettes were reduced to a maximum 240-pixel rise rather than changing movement or disabling hazards. Final results are recorded in `validation_0_17.json`.

These checks show that routes exist under the default profile. They do not substitute for human testing of readability, enjoyment, pacing or difficulty, or prove every possible saved Dash Lab override is viable.
