extends BaseComponent
class_name GrabbableComponent

signal pickup(entity: Node2D)
signal drop(entity: Node2D)

@export var selectable_component: SelectableComponent
@export var collider: CollisionShape2D
@export var state_chart: StateChart
@onready var entity := get_parent()


func _ready() -> void:
	selectable_component.hover.connect(_on_hover)
	self.input_event.connect(_on_input_event)
	add_to_group("grabbable")
	disable()


func _input(event: InputEvent) -> void:
	if is_enabled():
		if Input.is_action_just_released("interact"):
			state_chart.send_event("drop")


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if is_enabled():
		if Input.is_action_just_pressed("interact"):
			state_chart.send_event("pickup")


func _on_hover(_entity: Node2D, state: bool) -> void:
	enable() if state == true else disable()


func _on_held_state_entered() -> void:
	emit_signal("pickup", entity)


func _on_dropped_state_entered() -> void:
	emit_signal("drop", entity)
	state_chart.send_event("settle")
