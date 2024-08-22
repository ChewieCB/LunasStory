extends Node2D

signal hover(state: bool)
signal pickup
signal drop

@export var follow_component: FollowComponent

@onready var sprite: Sprite2D = $Sprite2D


func _ready():
	add_to_group("selectable")


func _input(event: InputEvent) -> void:
	if Input.is_action_just_released("interact"):
		emit_signal("drop")


func _on_area_2d_mouse_entered() -> void:
	emit_signal("hover", true)


func _on_area_2d_mouse_exited() -> void:
	emit_signal("hover", false)


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("interact"):
		emit_signal("pickup")
