class_name YBChargeDashTuning
extends Resource
## Dash-only profile. Base movement remains in movement.tres.
@export var minimum_force := 560.0
@export var maximum_force := 1180.0
@export var charge_duration := 0.80
@export var charge_curve := 1.35
@export var horizontal_force := 1.5
@export var vertical_force := 1.0
@export var diagonal_normalization := 1.0
@export var forward_momentum := 0.40
@export var cross_momentum := 0.15
@export var cross_momentum_limit := 100.0
@export var maximum_launch_speed := 1550.0
@export var short_duration := 0.075
@export var long_duration := 0.20
@export var short_dash_control := 0.32
@export var long_dash_control := 0.055
@export var dash_gravity := 0.0
@export var ground_clearance := 2.0
@export var charge_ground_control := 1.0
@export var charge_air_control := 0.85
@export var exit_air_control := 1.0
@export var exit_control_duration := 0.18
@export var exit_momentum := 0.75
@export var carry_decay := 1000.0
@export var carry_braking := 4000.0
@export var reversal_braking := 6200.0
@export var cooldown := 0.12
@export var airborne_charging := true
@export var air_launches := 1
@export var landing_resets := true
@export var landing_resets_cooldown := false
@export var aim_deadzone := 0.24

# Property, readable label, minimum, maximum, step. This also drives the lab UI.
const FIELDS=[
 ["minimum_force","Minimum force · px/s",100,1400,10], ["maximum_force","Maximum force · px/s",200,2200,10],
 ["charge_duration","Full charge · seconds",0.1,2.0,0.025], ["charge_curve","Charge curve exponent",0.35,3.0,0.05],
 ["horizontal_force","Horizontal multiplier",0.2,2.0,0.05], ["vertical_force","Vertical multiplier",0.2,2.0,0.05],
 ["diagonal_normalization","Diagonal normalization",0,1,0.05], ["forward_momentum","Forward momentum retained",0,1.5,0.05],
 ["cross_momentum","Cross-direction momentum",0,1,0.05], ["cross_momentum_limit","Cross momentum cap · px/s",0,400,10],
 ["maximum_launch_speed","Total launch speed cap",400,3000,20], ["short_duration","Shortest burst · seconds",0.035,0.2,0.005],
 ["long_duration","Longest burst · seconds",0.08,0.4,0.01], ["short_dash_control","Short burst steering",0,1,0.025],
 ["long_dash_control","Long burst steering",0,1,0.025], ["dash_gravity","Gravity during burst",0,1,0.05], ["ground_clearance","Ground launch clearance · px",0,6,1],
 ["charge_ground_control","Ground control while charging",0,1.5,0.05], ["charge_air_control","Air control while charging",0,1.5,0.05],
 ["exit_air_control","Air control after burst",0.1,2,0.05], ["exit_control_duration","Exit control window · seconds",0,1,0.025], ["exit_momentum","Exit velocity retained",0,1,0.05],
 ["carry_decay","Held-direction excess decay",100,5000,50], ["carry_braking","No-input excess braking",500,8000,100],
 ["reversal_braking","Reverse-input excess braking",500,10000,100], ["cooldown","Cooldown after burst · seconds",0,1,0.025],
 ["airborne_charging","Allow airborne charging"], ["air_launches","Air launches · 0 = unlimited",0,5,1],
 ["landing_resets","Landing restores air launches"], ["landing_resets_cooldown","Landing clears cooldown"],
 ["aim_deadzone","Aim deadzone",0.1,0.7,0.025]]
func values() -> Dictionary:
	var result={}
	for field in FIELDS: result[field[0]]=get(field[0])
	return result
func apply_values(data: Dictionary) -> void:
	for field in FIELDS:
		var value=data.get(field[0],get(field[0]))
		if field.size()==2:
			if value is bool: set(field[0],value)
		elif (value is float or value is int) and is_finite(float(value)):
			set(field[0],int(clampf(value,field[2],field[3])) if field[0]=="air_launches" else clampf(value,field[2],field[3]))
	maximum_force=maxf(maximum_force,minimum_force)
	long_duration=maxf(long_duration,short_duration)
static func profile(overrides: Dictionary={}) -> YBChargeDashTuning:
	var result=load("res://content/charge_dash.tres").duplicate(true) as YBChargeDashTuning
	result.apply_values(overrides)
	return result
