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

## DEBUG vars
@onready var debug_label: RichTextLabel = $DebugPosLabel
var local_pos_DEBUG: Vector2
var cell_local_pos_DEBUG: Vector2
var cell_global_pos_DEBUG: Vector2
var cell_global_pos_offset_DEBUG: Vector2
var cell_rect_DEBUG: Rect2
var cell_type_DEBUG: String

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


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		visual_component.current_cursor = visual_component.HandPosture.PINCH
	elif Input.is_action_just_released("interact"):
		visual_component.current_cursor = visual_component.HandPosture.OPEN


func _physics_process(delta: float) -> void:
	global_position = get_global_mouse_position()
	
	## DEBUG
	debug_tile_grid_position(tilemap)
	debug_label.text = """
	[center][color=purple]%s[/color][/center]
	[center]%s[/center]
	""" % [
		cell_global_pos_offset_DEBUG,
		cell_type_DEBUG
	]
	queue_redraw()


#func _draw() -> void:
	#draw_rect(cell_rect_DEBUG, Color(Color.RED, 0.5))


func debug_tile_grid_position(tilemap: TileMapLayer) -> void:
	if not tilemap:
		push_error(
			"Lock to grid enabled but no tilemap is assigned to %s.%s" % [
				owner.name, self.name
			]
		)
		return
	
	var local_pos = tilemap.to_local(self.global_position)
	var cell_coords = tilemap.local_to_map(local_pos)
	var cell_local_pos = tilemap.map_to_local(cell_coords)
	var cell_global_pos = tilemap.to_global(cell_local_pos)
	var cell_global_pos_offset = cell_global_pos - Vector2(tilemap.tile_set.tile_size) / 2
	
	# Only allow placement on valid floor cells
	var cell_data: TileData = tilemap.get_cell_tile_data(cell_coords)
	if cell_data:
		## 0: Walls, 1: Floor
		var cell_type = cell_data.terrain
		match cell_type:
			0:
				cell_type_DEBUG = "[color=orange]Wall[/color]"
			1:
				cell_type_DEBUG = "[color=green]Floor[/color]"
			_:
				cell_type_DEBUG = "[color=red]Invalid[/color]"
	
	# Debug cell visualisation
	cell_global_pos_offset_DEBUG = cell_global_pos_offset
	cell_rect_DEBUG = Rect2(to_local(cell_global_pos_offset), tilemap.tile_set.tile_size)


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
