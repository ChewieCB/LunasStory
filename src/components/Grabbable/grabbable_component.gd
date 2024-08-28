extends BaseComponent
class_name GrabbableComponent

signal pickup(entity: Node2D)
signal drop(entity: Node2D)

@onready var entity := get_parent()


func _ready() -> void:
	add_to_group("grabbable")
	disable()


func _input(event: InputEvent) -> void:
	if is_enabled():
		if Input.is_action_just_released("interact"):
			emit_signal("drop", entity)


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if is_enabled():
		if Input.is_action_just_pressed("interact"):
			emit_signal("pickup", entity)
