extends EntitySpawner
class_name FurnitureSpawner

@export var cauldron_target: Cauldron
@export var max_spawn_distance_tiles: int = 4
@export var debug_placement_collider: bool = false


func spawn_furniture(data: FurnitureData) -> FurnitureBig:
	var new_furniture = spawn_entity(data)
	new_furniture.follow_component_tilemap = tilemap
	new_furniture.debug_placement_collider = debug_placement_collider
	add_child(new_furniture)
	
	await new_furniture.ready
	new_furniture.follow_component._move_entity_within_grid(new_furniture.global_position)
	
	return new_furniture


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
	
	# Only spawn within X tiles of the cauldron
	var cauldron_tile = cauldron_target.position
	var tile_size = tilemap.tile_set.tile_size.x
	# TODO - optimize this: instead of checking all floor tiles, 
	#  just search radially outwards from the target.
	valid_tiles = valid_tiles.filter(
		func(x):
			var dist_to_cauldron = x.distance_to(cauldron_tile)
			# +1 since we have a buffer radius of 1 to prevent things spawning
			# over the cauldron.
			return dist_to_cauldron / tile_size <= max_spawn_distance_tiles + 1
	)
	
	return valid_tiles
