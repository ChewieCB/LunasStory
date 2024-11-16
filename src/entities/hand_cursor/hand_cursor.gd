extends Node2D
class_name HandCursor

@export var visual_component: CursorVisualComponent
@export var hitbox_component: HitboxComponent
@export var tilemap: TileMapLayer

@export_category("Posture Position Markers")
@export var open_marker: Marker2D
@export var pinch_marker: Marker2D
@export var grab_marker: Marker2D
@export var point_marker: Marker2D

@onready var position_markers := [open_marker, pinch_marker, grab_marker, point_marker]

var held_item: Node2D:
	set(value):
		if value:
			print("%s picked up!" % value.name)
		else:
			print("%s dropped!" % held_item.name)
		held_item = value


func _ready() -> void:
	for handle_group in ["ingredients", "furniture_big"]:
		for object in get_tree().get_nodes_in_group(handle_group):
			object.item.connect(handle_item)
	for object in get_tree().get_nodes_in_group("selectable"):
		object.hover.connect(hover)
	global_position = get_global_mouse_position()


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		visual_component.current_cursor = visual_component.HandPosture.PINCH
	elif Input.is_action_just_released("interact"):
		visual_component.current_cursor = visual_component.HandPosture.OPEN


func _physics_process(_delta: float) -> void:
	global_position = get_global_mouse_position()
	visual_component.global_position = global_position


func get_current_cursor_marker() -> Marker2D:
	return position_markers[visual_component.current_cursor]


func hover(_entity: Node2D, state: bool) -> void:
	if Input.is_action_pressed("interact"):
		return
	
	if state == true:
		visual_component.current_cursor = visual_component.HandPosture.POINT
	else:
		visual_component.current_cursor = visual_component.HandPosture.OPEN


func handle_item(item: Node2D, state: bool) -> void:
	_pickup_item(item) if state == true else _drop_item(item)


func _pickup_item(item: Node2D) -> void:
	if not held_item:
		held_item = item


func _drop_item(item: Node2D) -> void:
	if held_item == item:
		held_item = null
