extends BaseComponent
class_name FollowComponent

signal valid_placement_location
signal invalid_placement_location

@onready var entity: Node2D = get_parent()

var collision_check_area: RID
var collision_check_shape: RID
var collision_check_debug: RID
var blocked_tiles: Array[Vector2] = []

@export var target: Node2D
var follow_global_position: Vector2:
	set(value):
		follow_global_position = value
		if lock_to_grid:
			_move_entity_within_grid(follow_global_position)
		else:
			entity.global_position = follow_global_position

@export var lock_to_grid: bool = false
@export var tilemap: TileMapLayer:
	set(value): 
		tilemap = value
		var used_cells = tilemap.get_used_cells()
		valid_floor_tiles = used_cells.filter(
			func(tile):
				var data = tilemap.get_cell_tile_data(tile)
				return data.terrain == 1
		)
var valid_floor_tiles: Array[Vector2i]
var invalid_tiles: Array[Vector2]:
	set(value):
		var prev_invalid_tiles: Array[Vector2] = invalid_tiles
		invalid_tiles = value
		
		if invalid_tiles != prev_invalid_tiles:
			if invalid_tiles == []:
				emit_signal("valid_placement_location")
			else:
				emit_signal("invalid_placement_location")


func _ready():
	_setup_collision_check_area()
	
	if lock_to_grid:
		_move_entity_within_grid(self.global_position)
		
	disable()
	self.was_disabled.connect(_on_disabled)


func _setup_collision_check_area() -> void:
	# TODO - do we need a teardown for this physics server area when the object is freed?
	collision_check_area = PhysicsServer2D.area_create()
	collision_check_shape = PhysicsServer2D.rectangle_shape_create()
	PhysicsServer2D.shape_set_data(collision_check_shape, tilemap.tile_set.tile_size)
	PhysicsServer2D.area_add_shape(collision_check_area, collision_check_shape)
	PhysicsServer2D.area_set_collision_layer(collision_check_area, pow(2, 0-1))
	PhysicsServer2D.area_set_collision_mask(collision_check_area, pow(2, 3-1))
	PhysicsServer2D.area_set_monitorable(collision_check_area, false)
	PhysicsServer2D.area_set_area_monitor_callback(collision_check_area, _placement_collision_callback)
	PhysicsServer2D.area_set_space(collision_check_area, entity.get_world_2d().space)
	#
	collision_check_debug = RenderingServer.canvas_item_create()
	RenderingServer.canvas_item_set_parent(collision_check_debug, entity.get_canvas_item())
	RenderingServer.canvas_item_add_rect(
		collision_check_debug, 
		Rect2(Vector2.ZERO, tilemap.tile_set.tile_size),
		Color(Color.PURPLE, 0.6),
	)
	RenderingServer.canvas_item_set_transform(collision_check_debug, Transform2D())


func _physics_process(_delta: float) -> void:
	if is_enabled():
		follow_global_position = get_target_global_position()


func get_target_global_position() -> Vector2:
	if target:
		return target.get_current_cursor_marker().global_position
	return entity.global_position


func get_nearest_valid_placement_cell(cell_coords: Vector2, _invalid_tiles: Array[Vector2]) -> Vector2:
	var closest_valid_cells: Array[Vector2i] = valid_floor_tiles
	closest_valid_cells.sort_custom(
		func(a: Vector2i, b: Vector2i):
			var a_dist := Vector2(a).distance_to(Vector2(cell_coords))
			var b_dist := Vector2(b).distance_to(Vector2(cell_coords))
			if a_dist < b_dist:
				return true
			return false
	)
	
	for cell in closest_valid_cells:
		if not _get_invalid_placement_tiles(cell):
			return cell
	
	return cell_coords


func _get_invalid_placement_tiles(cell_coords: Vector2) -> Array[Vector2]:
	var tile_size: Vector2 = tilemap.tile_set.tile_size
	var tiles_to_check: Array[Vector2] = entity.sprite_tiles
	var _invalid_tiles: Array[Vector2] = []
	
	PhysicsServer2D.area_set_monitorable(collision_check_area, true)
	for tile in tiles_to_check:
		var cell := Vector2(tile.x / tile_size.x, tile.y / tile_size.y)
		var cell_pos: Vector2 = cell_coords + cell
		var cell_data: TileData = tilemap.get_cell_tile_data(cell_pos)
		if not cell_data:
			_invalid_tiles.append(cell_pos)
			continue
		# 0: Walls, 1: Floor
		var cell_type: int = cell_data.terrain
		if cell_type != 1:
			_invalid_tiles.append(cell_pos)
			continue
		# Get placed object locations and map to tiles
		var cell_local_pos = tile - entity.sprite_offset
		PhysicsServer2D.area_set_transform(collision_check_area, Transform2D(0, cell_local_pos))
		RenderingServer.canvas_item_set_transform(collision_check_debug, Transform2D(0, cell_local_pos))
		
		for blocked_tile in blocked_tiles:
			_invalid_tiles.append(blocked_tile)
	PhysicsServer2D.area_set_monitorable(collision_check_area, false)
	return _invalid_tiles


func _move_entity_within_grid(global_pos: Vector2) -> void:
	if not tilemap:
		push_error(
			"Lock to grid enabled but no tilemap is assigned to %s.%s" % [
				owner.name, self.name
			]
		)
		return
	
	var cell_coords: Vector2 = _get_cell_coords(global_pos)
	# Only allow placement on valid floor cells
	invalid_tiles = _get_invalid_placement_tiles(cell_coords)
	var cell_global_pos_offset: Vector2 = _get_cell_global_position_offset(cell_coords)
	
	entity.global_position = cell_global_pos_offset + entity.sprite_offset


func _get_cell_global_position_offset(cell_coords: Vector2, validate_cell: bool = false) -> Vector2:
	if validate_cell:
		cell_coords = get_nearest_valid_placement_cell(cell_coords, invalid_tiles)
	
	var cell_local_pos: Vector2 = tilemap.map_to_local(cell_coords)
	var cell_global_pos: Vector2 = tilemap.to_global(cell_local_pos)
	var cell_global_pos_offset := cell_global_pos - Vector2(tilemap.tile_set.tile_size) / 2
	
	return cell_global_pos_offset


func _get_cell_coords(global_pos: Vector2) -> Vector2:
	var local_pos: Vector2 = tilemap.to_local(global_pos)
	return tilemap.local_to_map(local_pos)


func _get_local_pos_from_cell(cell_coords: Vector2) -> Vector2:
	var local_pos: Vector2 = tilemap.map_to_local(cell_coords)
	return local_pos


func _get_global_pos_from_cell(cell_coords: Vector2) -> Vector2:
	var local_pos: Vector2 = tilemap.map_to_local(cell_coords)
	var global_pos = tilemap.to_global(local_pos)
	return global_pos


func _on_disabled() -> void:
	if invalid_tiles:
		var cell_coords: Vector2 = _get_cell_coords(self.global_position)
		var global_pos_tile_offset: Vector2 = _get_cell_global_position_offset(cell_coords, true)
		entity.global_position = global_pos_tile_offset + entity.sprite_offset


func _placement_collision_callback(status: int, area_rid: RID, instance_id: int, area_shape_idx: int, self_shape_idx: int) -> void:
	var collision_area = instance_from_id(instance_id)
	var object = collision_area.owner
	if object is FurnitureBig and object != entity:
		var tiles = object.sprite_tiles
		match status:
			PhysicsServer2D.AreaBodyStatus.AREA_BODY_ADDED:
				for tile in tiles:
					var offset_tile = tile + object.global_position - object.sprite_offset
					if not blocked_tiles.has(offset_tile):
						blocked_tiles.append(offset_tile)
						print("%s (%s) added to blocked tiles" % [offset_tile, object.name])
			PhysicsServer2D.AreaBodyStatus.AREA_BODY_REMOVED:
				for tile in tiles:
					var offset_tile = tile + object.global_position - object.sprite_offset
					if blocked_tiles.has(offset_tile):
						blocked_tiles.erase(offset_tile)
						print("%s (%s) added to blocked tiles" % [offset_tile, object.name])
