extends BaseComponent
class_name FollowComponent

@onready var entity: Node2D = get_parent()

@export var target: Node2D
var follow_global_position: Vector2:
	set(value):
		follow_global_position = value
		if lock_to_grid:
			move_entity_within_grid(follow_global_position)
		else:
			entity.global_position = follow_global_position

@export var lock_to_grid: bool = false
@export var tilemap: TileMapLayer:
	set(value): 
		tilemap = value


func _ready():
	disable()


func _physics_process(delta: float) -> void:
	if is_enabled():
		follow_global_position = get_target_global_position()
	else:
		# TODO - lerp towards nearest valid position
		pass


func get_target_global_position() -> Vector2:
	if target:
		return target.get_current_cursor_marker().global_position
	return entity.global_position


func move_entity_within_grid(pos: Vector2) -> void:
	if not tilemap:
		push_error(
			"Lock to grid enabled but no tilemap is assigned to %s.%s" % [
				owner.name, self.name
			]
		)
		return
	
	var local_pos = tilemap.to_local(pos)
	var cell_coords = tilemap.local_to_map(local_pos)
	var cell_local_pos = tilemap.map_to_local(cell_coords)
	var cell_global_pos = tilemap.to_global(cell_local_pos)
	var cell_global_pos_offset = cell_global_pos - Vector2(tilemap.tile_set.tile_size) / 2
	
	# Only allow placement on valid floor cells
	if check_valid_grid_placement(cell_coords):
		entity.cell_rect_color_DEBUG = Color(Color.GREEN, 0.5)
	else:
		entity.cell_rect_color_DEBUG = Color(Color.RED, 0.5)
	
	entity.global_position = cell_global_pos_offset + entity.sprite_offset
	
	entity.cell_rect_DEBUG = Rect2(
		entity.to_local(cell_global_pos_offset), 
		entity.sprite_size
	)


func check_valid_grid_placement(cell_coords: Vector2) -> bool:
	var tile_size: Vector2 = tilemap.tile_set.tile_size
	var tiles_to_check = entity.sprite_tiles
	
	for tile in tiles_to_check:
		var cell: Vector2 = Vector2(tile.x / tile_size.x, tile.y / tile_size.y)
		var cell_pos = cell_coords + cell
		var cell_data: TileData = tilemap.get_cell_tile_data(cell_pos)
		if not cell_data:
			return false
		# 0: Walls, 1: Floor
		var cell_type: int = cell_data.terrain
		if cell_type != 1:
			return false
	return true
		
