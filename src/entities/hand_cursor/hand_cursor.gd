extends Node2D
class_name HandCursor

@export var visual_component: CursorVisualComponent
@export_category("Posture Position Markers")
@export var open_marker: Marker2D
@export var pinch_marker: Marker2D
@export var grab_marker: Marker2D
@export var point_marker: Marker2D

@onready var position_markers := [open_marker, pinch_marker, grab_marker, point_marker]


func _ready() -> void:
	for object in get_tree().get_nodes_in_group("selectable"):
		object.hover.connect(hover)


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		visual_component.current_cursor = visual_component.HandPosture.PINCH
	elif Input.is_action_just_released("interact"):
		visual_component.current_cursor = visual_component.HandPosture.OPEN


func _physics_process(delta: float) -> void:
	global_position = get_global_mouse_position()


func hover(state: bool) -> void:
	if Input.is_action_pressed("interact"):
		return
	
	if state == true:
		visual_component.current_cursor = visual_component.HandPosture.POINT
	else:
		visual_component.current_cursor = visual_component.HandPosture.OPEN


func get_current_cursor_marker() -> Marker2D:
	return position_markers[visual_component.current_cursor]
