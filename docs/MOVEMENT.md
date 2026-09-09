# Movement revision · 0.4

The controller now responds quickly to starting, reversing and releasing movement, including in the air. Holding jump supports the early rise; releasing it produces a shorter arc. Gravity softens briefly near a held jump's peak and strengthens for descent. Small upward head-corner overlaps can slide clear, and buffered jumps trigger on the landing tick. Checkpoint retries take 0.38 seconds. Jump/landing squash now affects the traveller's drawing and respects reduced motion.

The reference was Celeste's base movement feel. The installed `/Applications/Massages.app` identifies itself as Celeste. Technical reference: Maddy Thorson's [Celeste & Forgiveness](https://www.mattmakesgames.com/articles/celeste_and_forgiveness/index.html) and the developer-published [player reference](https://github.com/NoelFB/Celeste/blob/master/Source/Player/Player.cs). Yearbound uses its own Godot implementation and tuning for its existing scale and layouts. No Celeste assets or source implementation were imported.

## Measured behavior

These are actual results from the 60 Hz collision fixture in `tests/controller.gd`, using normal digital inputs and gentle journey off. Frame sampling is accurate to one physics tick.

| Check | Result |
|---|---|
| Normal run speed | 340 logical px/s |
| Ground acceleration | Full speed in about 0.10 s |
| Ground stopping distance | 11.7 logical pixels |
| Air stopping distance | 23.5 logical pixels |
| Tap jump | 45.3 px rise; about 0.35 s airborne |
| Intermediate hold | 77.3 px rise; about 0.48 s airborne |
| Full hold | 111.3 px rise; about 0.67 s airborne |
| Full-jump apex | About 0.35 s after takeoff |

Shorter stopping distances allow the player to correct a landing without drifting across the whole platform. The highest normal jump remains close to the earlier build, preserving required rises. Bellflowers retain their longer launch arc. Ice retains intentional low traction. March's lift force is increased to overcome the stronger normal gravity.

## Tuning and boundaries

Open `content/movement.tres` in the Godot Inspector to override the typed properties defined in `scripts/movement_tuning.gd`. All dates share this profile. Use stage zones and surfaces for intentional environmental variations; avoid silently changing normal movement by date.

`player.gd` separates horizontal response, vertical shaping, jump initiation, corner correction, lift memory and the future ability interface. Corner correction is capped at 8 logical pixels and checks both the lateral path and the upward sweep. It does not pass through full ceilings or narrow side walls. Lift momentum is bounded and expires after 0.10 seconds. A checkpoint reset clears stored momentum, buffered input, jump sustain, spring flight and environmental forces.

The 0.8 charge dash uses the separate `YBPlayerAbility` interface in the Dash Lab. The base movement profile described here remains unchanged. See `CHARGE_DASH.md`; wall jumping, climbing and stamina are not implemented.

## Verification and limits

The controller fixture checks acceleration, stopping distance, reversal, variable jump heights, same-tick landing buffers, expired input, corner correction, full ceilings, narrow shafts, lift memory/expiry, reset state, assist jumps and pause freezing. The smoke and seasonal mechanics suites also pass. The updated traversal bot completes all five exploration routes through normal movement input, releasing jump on descent to allow a fresh press on short platforms.

The bot does not plan around moving hazards. Its final run took zero retries in June's opening, five in mid-June, sixteen in October, zero in January and zero in March. These results establish reachability, not polished difficulty balance. Physical controller hardware and extended human comparison remain untested. The next useful feedback is how quickly the player should stop or reverse, and whether the held jump feels too short or too long during actual play.
