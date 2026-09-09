class_name YBMovementTuning
extends Resource
## Logical pixels / seconds. The shared profile keeps every day physically consistent.
@export var run_speed := 340.0
@export var ground_acceleration := 3600.0
@export var ground_braking := 4000.0
@export var air_acceleration := 2400.0
@export var air_braking := 2200.0
@export var turn_multiplier := 1.25
@export var ice_acceleration := 640.0
@export var ice_braking := 160.0
@export var jump_speed := 480.0
@export var assist_jump_speed := 515.0
@export var jump_hold_time := 0.14
@export var rise_gravity := 2800.0
@export var fall_gravity := 3200.0
@export var apex_speed := 120.0
@export var apex_gravity_multiplier := 0.5
@export var max_fall_speed := 780.0
@export var coyote_time := 0.10
@export var jump_buffer_time := 0.12
@export var corner_correction := 8
@export var lift_memory_time := 0.10
@export var lift_horizontal_limit := 120.0
@export var lift_vertical_limit := 160.0
# Bellflowers have a deliberately longer launch arc than a normal jump.
@export var spring_rise_gravity := 1650.0
@export var spring_fall_gravity := 1920.0
@export var spring_max_fall_speed := 900.0
