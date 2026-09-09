# Charge dash · campaign and extended laboratory · 0.10.0

Charge dash is enabled in all twenty-one playable campaign days. Open **Yearbound.app → Charge dash lab** for the separate seventeen-station testing area. Lab attempts never replace campaign progress; its saved tuning profile also applies when you next enter a campaign day. The original thirteen layouts retain their geometry. No second major mechanic is included.

## Play

- **Hold Shift or C**, choose a direction, then **release** to dash. Controller defaults are **X / West** or **right shoulder**.
- Aim with **WASD**, **arrows**, **IJKL**, the left stick or D-pad. Horizontal, vertical and diagonal directions work; analog sticks also allow angles between the eight keyboard directions.
- With no aim held on release, dash in the facing direction. Direction is sampled at release, so you can change your plan while charging.
- **Space / Z** jumps; controller **A / South** jumps. Up/down are dedicated aiming inputs, avoiding an unwanted jump when aiming upward.
- **Esc / Start** opens the stations and tuning panel. **R / Y** restarts at the selected station's lantern. The HUD has a clickable **Stations & tuning** button.
- **Settings → Rebind keyboard / controller**, or **Controls** in the lab panel, changes bindings. Keyboard keys, mouse buttons, controller buttons and trigger/stick axes are supported. Rebinding replaces that action's keyboard/mouse or controller group. Conflicts are reported before changing anything. Escape cancels capture; F11 stays reserved for fullscreen. Controls save locally.

## How the first tuning behaves

Charging preserves full ground acceleration and 85% of normal air acceleration/braking. Gravity and held-jump behaviour continue while charging: charging does not suspend the player in the air. Charge stops increasing after **0.80 seconds**, but the player can hold maximum power until ready to release.

Power follows `pow(clamped_charge_fraction, 1.35)`. Launch speed blends continuously from **560 to 1180 logical pixels/second**; the burst lasts **0.075–0.20 seconds**. There are no hard charge tiers. Small holds give quick corrections, middle holds balance distance and commitment, and long holds require more planning. The stronger launch gets much less mid-burst steering and can overshoot small landing areas.

A small ring and aim pointer show charge near the traveller. The HUD reports charge, time, launch speed and measured burst displacement. Three restrained particles orbit while charging; a soft hum rises in pitch and strength. Full charge fills the ring, adds a small cap marker and sounds one chime. A short trail and whoosh accompany release. Reduced motion removes the orbit/trail animation; effects volume controls all charge audio. There is no screen shake or invulnerability.

The initial momentum rule keeps **40% of incoming velocity along the launch direction**, discards the opposing component, and retains **15% of perpendicular velocity**, capped at 100 px/s. Recent moving-platform velocity is included once. Diagonals are normalized by default. The original profile is restored with **horizontal multiplier 1.5** as the only exception. Vertical strength stays 1.0. The original charge curve, force range, momentum, steering, cooldown, air rules and 1550 px/s total launch cap remain unchanged.

In November's physical water volumes, environmental drag reduces burst travel and a 0.65-second swimming recovery refills the air allowance. This lives in the separate swim controller and does not modify the shared dash profile or dry lab behavior. See `UNDERWATER.md`.

The burst retains **75% of its exit velocity**. Normal movement resumes immediately, with an additional decay path for excess horizontal speed so the controller's normal speed cap does not erase all momentum in one frame. Holding the same direction carries speed further; releasing or reversing brakes harder. A ground jump can cancel a horizontal dash and carry its speed, including a jump pressed at the release boundary within the controller's existing coyote window. This supplies an interaction point for later movement combinations.

A two-pixel, collision-checked ground-launch clearance avoids catching a same-height landing lip. Floor snapping is suspended only during the burst, then restored. Solids still stop the player; downward/diagonal impacts can finish the burst with remaining tangential velocity. Thin hazards are checked along the travelled path, so high speeds do not skip them.

By default there is **one launch per airborne period**, with a **0.12-second cooldown after a burst**. Landing restores the air allowance, but does not remove cooldown. A ground horizontal dash does not spend the airborne allowance. These are tuning choices: air launches can be increased or set to zero for unlimited experiments, airborne charging can be disabled, and landing reset behaviour is configurable.

Pause, focus loss, restart, death, spring launches and leaving the lab cancel charging safely. Releasing a held button while paused cannot cause a delayed launch on resume. Springs interrupt the dash through the ability interface rather than changing the base controller.

## Seventeen stations

| Station | What to compare |
|---|---|
| Short corrections | 48/96 px gaps and small islands; tap charge and brake before the edge. |
| Medium range | 192 px gaps; combine a jump with medium charge and compare release timing. |
| Long commitment | A 384 px gap; use full charge with a jump/run-up or aim up-right. |
| Upward launches | Launch up the shaft, then steer onto the 336 px-high balcony. |
| Downward launches | Drop through a narrow shaft and launch downward to the lower floor. |
| Diagonal lines | Start back from the edge, launch up-right and brake onto the balcony; then try down-right. |
| Charge in the air | Leave the high deck before charging; compare charge commitment against remaining fall time. |
| Momentum runway | Compare standing, running and jump-cancel launches using the live speed readout. |
| Moving platforms | Launch from a horizontal ferry or vertical lift and compare inherited velocity. |
| Quick hazard dodges | Read the moving hazard and try a brief burst through the timing window. Dashes do not make contact safe. |
| Less is more | Narrow safe islands next to tall brambles make overcharging inconvenient. |

| Long momentum circuit | A 3,840 px runway with repeated jump cancels and braking points. |
| Precision rhythm | Six small hazards and a row of narrow upper perches. |
| Ice and lift carry | Long ice, a horizontal ferry, a vertical lift and exposed stone. |
| Vertical relay | Upward launches, diagonal connections, landing resets and controlled drops. |
| Headwind crossing | A long pulsing headwind with repeatable obstacle spacing. |
| The endurance course | An extended mix of hazards, moving platforms and open momentum stretches. |

The lab is now **44,160 px long**, more than twice its previous 21,120 px. The first eleven stations keep their existing positions; the six new courses follow them. Scroll the station list or navigate its buttons with the keyboard/controller. Jump to any station from the panel. Selecting a station or respawning restarts its environmental phase for repeatable attempts. World-space distance ticks are 48 px apart, with labels every 192 px. The last burst displacement remains visible for comparison after a reset.

## Tune and share

The lab panel exposes every field from the dash resource, including forces, charge curve/duration, burst duration, diagonal normalization, momentum caps, steering, exit braking, cooldown, air allowance and landing rules. Scroll the right-hand panel for the complete set. Changes save locally and apply to the next attempt. **Defaults** clears the local override and restores the shipped resource.

**Export profile…** writes a small JSON file containing the full tuning profile. Send that file back with the station and behaviour you want changed. The export has `schema_version: 1`, `mechanic: "charge_dash"` and a `values` object; it is separate from workshop layout JSON.

The source defaults are the exported resource properties in `scripts/charge_dash_tuning.gd`, used by `content/charge_dash.tres`. The `.tres` can also be opened in Godot's Inspector. Local in-game overrides live under `settings.dash_tuning` in the normal Yearbound save, and take precedence over resource defaults. Reset them before comparing changed source defaults. The first 0.9.1 launch clears existing dash overrides once to restore the original profile with only horizontal multiplier 1.5. Bindings, progress and unrelated settings are preserved. Subsequent lab tuning edits persist normally.

## Architecture

- `player_ability.gd` defines pre-motion, post-base-motion, post-collision, interruption and drawing hooks, plus `launched`, `ended` and feedback signals.
- `charge_dash.gd` owns charge, burst, cooldown, air allowance, momentum carry and visual feedback. Base running/jumping values remain in `movement.tres` / `movement_tuning.gd`.
- `player.gd` dispatches ability hooks around the existing controller. With no assigned ability, its base movement path remains unchanged.
- `world.gd` opts into the ability only when a content file includes `"abilities": ["charge_dash"]`, and owns collision/hazard interactions. All current campaign stages and `content/labs/charge_dash.json` opt in. New workshop documents inherit the ability from the opening-stage template.
- `dash_lab_panel.gd` builds its tuning controls from the profile's field metadata; `controls.gd` owns action bindings and validation.
- `audio.gd` owns the charge hum, cap chime and launch whoosh. No extra sound asset dependency is required.

The lab remains a tuning environment alongside the playable campaign samples. Measured distances establish a starting point; your playtesting should decide the final charge curve, braking, air rules and which combinations belong in the larger game.
