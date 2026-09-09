class_name YBStageHazards
extends RefCounted
## Environment timing is separate from player abilities. Warning intervals are safe.
static func cycle(h: Dictionary, time: float) -> float:
	return fposmod(time+float(h.get("phase",0)),float(h.get("period",4)))
static func active(h: Dictionary, time: float) -> bool:
	return h.type!="storm" or cycle(h,time)>=float(h.period)-float(h.active_seconds)
static func warning(h: Dictionary, time: float) -> bool:
	return h.type=="storm" and cycle(h,time)>=float(h.period)-float(h.active_seconds)-float(h.get("warning_seconds",0.9)) and not active(h,time)
static func rectangular(h: Dictionary) -> bool: return h.type in ["bramble","storm"]
static func position(h: Dictionary, time: float) -> Vector2:
	var at=Vector2(h.x,h.y)
	if h.type=="icicle":
		var t=cycle(h,time);var warning=float(h.get("warning_seconds",1.35))
		if h.get("local",false): at.y=h.y-70 if t<warning else h.y+pow(t-warning,2)*float(h.get("fall_acceleration",820))
		else: at.y=-100 if t<1.35 else 140+pow(t-1.35,2)*820
	else:
		var axis=Vector2.RIGHT if h.get("axis","y")=="x" else Vector2.DOWN
		at+=axis*sin(time*float(h.get("speed",1))+float(h.get("phase",0)))*float(h.get("distance",0))
	return at
