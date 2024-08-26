extends BaseComponent
class_name GrabbableComponent

signal pickup
signal drop


func _ready() -> void:
	add_to_group("grabbable")
	disable()


func _input(event: InputEvent) -> void:
	if Input.is_action_just_released("interact"):
		emit_signal("drop")


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("interact"):
		emit_signal("pickup")
