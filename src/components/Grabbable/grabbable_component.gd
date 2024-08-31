extends BaseComponent
class_name GrabbableComponent

signal pickup(entity: Node2D)
signal drop(entity: Node2D)

@export var selectable_component: SelectableComponent
@onready var entity := get_parent()


func _ready() -> void:
	selectable_component.hover.connect(_on_hover)
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


func _on_hover(_entity: Node2D, state: bool) -> void:
	enable() if state == true else disable()
