class_name YBPlayerAbility
extends RefCounted
## Explicit hooks let later mechanics observe or compose with an ability.
signal feedback(id: String)
signal launched(direction: Vector2, power: float, launch_velocity: Vector2)
signal ended(reason: String)
func before_motion(_p: CharacterBody2D, _dt: float, _grounded: bool) -> bool: return false
func horizontal_control(_grounded: bool) -> float: return 1.0
func after_base_motion(_p: CharacterBody2D, _previous: Vector2, _axis: float, _grounded: bool, _dt: float) -> void: pass
func after_motion(_p: CharacterBody2D, _dt: float, _was_grounded: bool) -> void: pass
func recover_in_medium(_p: CharacterBody2D, _dt: float, _refill_time: float) -> void: pass
func cancel_charge(_p: CharacterBody2D) -> void: pass
func interrupt(_p: CharacterBody2D, _reason: String) -> void: pass
func draw_feedback(_p: Node2D) -> void: pass
func controls_motion() -> bool: return false
