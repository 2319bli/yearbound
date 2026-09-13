class_name YBObstacleRules
extends RefCounted
## Shared workshop/import validation for moving environmental hazards.
static func numeric(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value))
static func errors(h: Dictionary) -> PackedStringArray:
	var out: PackedStringArray = []
	if h.get("mechanism", "") not in YBObstacles.KINDS:
		out.append("Unknown mechanism.");return out
	for key in ["x", "y", "period", "phase"]:
		if not numeric(h.get(key)):out.append("Mechanism needs finite " + key + ".")
	if not out.is_empty():return out
	if h.period < .6 or h.period > 20:out.append("Mechanism period must be 0.6–20 seconds.")
	if h.has("extension_seconds") and (not numeric(h.extension_seconds) or h.extension_seconds<.02 or h.extension_seconds>1):out.append("Mechanism extension must be 0.02–1 seconds.")
	if h.mechanism in ["windmill", "pendulum"]:
		if not numeric(h.get("radius")) or h.radius < 32 or h.radius > 360:out.append("Mechanism radius must be 32–360.")
		if h.mechanism == "windmill":
			if not numeric(h.get("blades")) or h.blades < 2 or h.blades > 4 or h.blades != floorf(h.blades):out.append("Windmill needs 2–4 whole blades.")
			if not numeric(h.get("rotation_direction",1)) or absf(float(h.get("rotation_direction",1))) != 1:out.append("Windmill direction must be -1 or 1.")
		else:
			if not numeric(h.get("swing")) or h.swing < .2 or h.swing > 1.25:out.append("Pendulum swing must be .2–1.25 radians.")
	else:
		for key in ["safe_seconds", "warning_seconds"]:
			if not numeric(h.get(key)):out.append("Mechanism needs " + key + ".")
		if out.is_empty() and (h.safe_seconds < .08 or h.warning_seconds < .12 or h.period < h.safe_seconds+h.warning_seconds+.2):out.append("Mechanism needs an opening, warning and active interval.")
		if h.mechanism in ["press","shutter","geyser"]:
			for key in ["w","h"]:
				if not numeric(h.get(key)) or h[key] < 24 or h[key] > 480:out.append("Mechanism dimensions must be 24–480.")
		if h.mechanism == "arc":
			for key in ["dx","dy"]:
				if not numeric(h.get(key)) or absf(h[key]) > 480:out.append("Arc endpoints must be finite and within 480 pixels.")
			if out.is_empty() and Vector2(h.dx,h.dy).length()<48:out.append("Arc needs separated endpoints.")
	if h.has("head_radius") and (not numeric(h.head_radius) or h.head_radius<8 or h.head_radius>64):out.append("Mechanism head radius must be 8–64.")
	if h.has("thickness") and (not numeric(h.thickness) or h.thickness<2 or h.thickness>16):out.append("Mechanism thickness must be 2–16.")
	if h.has("travel") and (not numeric(h.travel) or h.travel<12 or h.travel>144):out.append("Saw travel must be 12–144.")
	return out
