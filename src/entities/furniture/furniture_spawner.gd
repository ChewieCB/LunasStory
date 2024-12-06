extends EntitySpawner
class_name FurnitureSpawner

@export var cauldron_target: Cauldron
@export var max_spawn_distance_tiles: int = 4
@export var debug_placement_collider: bool = false

@export var spawn_time: float = 0.4
@onready var spawn_arc_path: Path2D = $SpawnArc
@onready var spawn_arc_follow: PathFollow2D = $SpawnArc/SpawnArcFollow
@onready var spawn_target: Marker2D = $SpawnArc/SpawnArcFollow/SpawnTarget


func spawn_furniture(data: FurnitureData) -> FurnitureBig:
	var new_furniture = spawn_entity(data)
	new_furniture.follow_component_tilemap = tilemap
	new_furniture.debug_placement_collider = debug_placement_collider
	
	add_child(new_furniture)
	new_furniture.follow_component._move_entity_within_grid(new_furniture.global_position)
	
	
	# Tween the object in an arc from the cauldron from it's placement point
	var final_pos: Vector2 = new_furniture.global_position
	var spawn_pos: Vector2 = cauldron_target.global_position
	# TODO - tweak the arc direction based on the angle between positions
	spawn_arc_path.curve.set_point_position(0, spawn_pos)
	spawn_arc_path.curve.set_point_position(1, final_pos)
	new_furniture.spawn_movement_target = spawn_target
	
	var tween = get_tree().create_tween()
	new_furniture.selectable_component.disable()
	new_furniture.sprite.scale = Vector2.ZERO
	tween.tween_property(
		spawn_arc_follow, "progress_ratio", 1.0, spawn_time
	).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(
		new_furniture.sprite, "scale", Vector2.ONE, spawn_time
	).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func():
		new_furniture.spawn_movement_target = null
		new_furniture.selectable_component.enable()
		new_furniture.selectable_component.query_hover()
		new_furniture.global_position = final_pos
		spawn_arc_follow.progress_ratio = 0.0
	)
	
	cauldron_target.emit_particles(load("res://assets/particles/poof/PoofParticle.tres"))
	
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
