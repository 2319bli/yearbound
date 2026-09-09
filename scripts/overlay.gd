extends Node2D
var host: Node2D
var draw_method = "draw_overlay"
func _draw() -> void:
	if is_instance_valid(host): host.call(draw_method,self)
