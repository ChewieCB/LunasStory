extends Node2D
class_name EntitySpawner

@export_category("Nodes")
@export var tilemap: TileMapLayer
@export var hand_cursor: HandCursor
@export_category("Spawning")
@export var entity_scene: PackedScene
@export var entity_resources_path: String
var entities: Array[Data] = []
@export_category("Debug")
@export var show_valid_placements: bool = false
var debug_central_tile: Vector2



func _ready() -> void:
	var resource_files = Array(DirAccess.get_files_at(entity_resources_path))
	for filename in resource_files:
		var entity = load(entity_resources_path + filename)
		entities.append(entity)


func _draw() -> void:
	if show_valid_placements:
		for point in get_valid_placements():
			draw_circle(point, 2.0, Color.RED)
	if debug_central_tile:
		draw_circle(debug_central_tile, 4.0, Color.PURPLE)


func _process(_delta) -> void:
	queue_redraw()


func spawn_entity(data: Data) -> InteractibleObject:
	var entity = entity_scene.instantiate()
	var valid_positions = get_valid_placements()
	valid_positions.shuffle()
	
	entity.data = data
	entity.follow_target = hand_cursor
	
	# Check we have enough space based on entity size
	var entity_tiles: Array[Vector2] = entity.get_tiles_for_sprite(tilemap)
	valid_positions = valid_positions.filter(
		func(x):
			# Check that we can place all of the tiles if we place that position
			for tile in entity_tiles:
				var check_cell = x + tile
				if check_cell not in valid_positions:
					return false
			return true
	)
	
	var spawn_pos = valid_positions.pop_front()
	entity.position = spawn_pos
	
	return entity


func get_valid_placements() -> Array:
	var floor_tiles = _get_floor_tiles()
	# If there's an object with collision on a floor tile, don't spawn on that tile
	var objects = get_tree().get_nodes_in_group("interactible")
	var portals = get_tree().get_nodes_in_group("spawner")
	var blockers = objects + portals
	var blocker_tiles = []
	for node in blockers:
		if node is FurnitureBig:
			for tile in node.sprite_tiles:
				var cell = tilemap.map_to_local(
					tilemap.local_to_map(node.position - node.sprite_offset + tile)
				)
				blocker_tiles.append(cell)
		else:
			for tile in get_surrounding_tiles(node.global_position):
				blocker_tiles.append(tile)
	
	var valid_tiles = floor_tiles.filter(
		func(x):
			return x not in blocker_tiles
	)
	
	# TODO - add exclusion radius component to block spawning too close
	
	return valid_tiles


func get_surrounding_tiles(pos: Vector2) -> Array:
	var output = []
	var surrounding_tiles = [
		Vector2i(1, 0),
		Vector2i(1, -1),
		Vector2i(0, -1),
		Vector2i(-1, -1),
		Vector2i(-1, 0),
		Vector2i(-1, 1),
		Vector2i(0, 1),
		Vector2i(1, 1),
	]
	
	output.append(pos)
	var map_pos = tilemap.local_to_map(pos)
	for offset in surrounding_tiles:
		output.append(tilemap.map_to_local(map_pos + offset))
	
	return output


func _get_floor_tiles() -> Array:
	var floor_tiles = tilemap.get_used_cells().filter(
		func(x):
			return tilemap.get_cell_tile_data(x).terrain == 1
	)
	var floor_tiles_local = floor_tiles.map(
		func(x):
			return tilemap.map_to_local(x)
	)
	return floor_tiles_local
