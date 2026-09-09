class_name YBPlatformMotion
extends RefCounted
## Authored platform tracks. Offsets are relative to the platform's grid position.
static func offset(data: Dictionary, time: float) -> Vector2:
	if data.has("motion_path"):
		var path: Array=data.motion_path
		var phase=fposmod(time/float(data.motion_seconds)+float(data.get("motion_phase",0)),1.0)*path.size()
		var index=floori(phase)
		return Vector2(path[index][0],path[index][1]).lerp(Vector2(path[(index+1)%path.size()][0],path[(index+1)%path.size()][1]),phase-index)
	var axis=Vector2.RIGHT if data.axis=="x" else Vector2.DOWN
	return axis*sin(time*float(data.speed)+float(data.get("phase",0)))*float(data.distance)
