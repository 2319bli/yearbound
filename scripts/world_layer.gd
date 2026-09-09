class_name YBWorldLayer
extends Node2D
## A named drawing pass. Its parent supplies geometry; z_index controls ordering.
var host: Node2D
var draw_method: StringName
func _ready() -> void:
	if DisplayServer.get_name()=="headless": set_process(false)
func _process(_dt: float) -> void:
	if is_visible_in_tree(): queue_redraw()
func _draw() -> void:
	if is_instance_valid(host): host.call(draw_method,self)
