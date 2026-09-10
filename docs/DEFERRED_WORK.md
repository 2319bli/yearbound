# Deferred work — recorded during the visual overhaul (10 September 2026)

These issues were found while preparing the visual reskin. They are **out of
scope for the reskin** and must be handled as their own authorised changes.
They are recorded here so they are not silently bundled into visual commits.

## 1. Camera behaviour (separately scoped fix)

- `scripts/world.gd` follows the player on both axes, with velocity
  look-ahead and smoothing on X and Y (`_physics_process`, camera block).
- The static boss-arena camera condition is:
  `if boss_active and spec.has("boss") and not june_boss:`
  Because it excludes the newer `YBJuneBoss`, the June boss (30 June, the
  only boss currently shipped) never gets the fixed arena camera; the camera
  keeps chasing the player through dense dodging. `scripts/june_boss.gd`
  does not introduce a replacement camera lock.
- Owner's desired future rule: each large section explicitly chooses
  **horizontal-only**, **vertical-only** or **static** camera behaviour;
  ordinary jumps must not produce vertical camera chasing; dense boss
  dodging uses a static arena camera; transitions happen at planned
  section boundaries.
- Do **not** change camera behaviour inside visual-pass commits.

## 2. Outdated test assumptions (replace when gameplay/camera work is authorised)

`tests/authored_campaign.gd` encodes the old design rather than neutral
correctness:

- It requires **at least 50 bramble/spike placements in every stage**,
  which reinforces the exact obstacle vocabulary the owner wants to move
  away from. The next phase is deliberate gameplay design, not spike quotas.
- It asserts that holding right meets a decision on the first screen and
  that the camera follows the highest route vertically — the camera
  assertion will conflict with deliberately locked camera sections.
- When gameplay/camera work is authorised, replace these with checks of the
  approved behaviour while preserving collision, hazard-timing, save/editor
  round-trip and reachability coverage (`tests/authored_routes.gd` is useful
  reachability coverage and should be kept).

## 3. Related notes

- `YBJourneyScenery.index_at()` and the map-atlas selection key off player X
  (sequential horizontal bands). True stacked rooms or alternative routes
  sharing an X range would need richer region selection later — a layout
  limitation, not a reskin task.
- `docs/FOUNDATION.md` is partly historical (21-stage slice, three-phase
  boss); README 0.14.0, the catalog and current code supersede it.
