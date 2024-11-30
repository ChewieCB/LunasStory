extends EntitySpawner
class_name FurnitureSpawner

@export var debug_placement_collider: bool = false


func spawn_furniture(data: FurnitureData) -> FurnitureBig:
	var new_furniture = spawn_entity(data)
	new_furniture.follow_component_tilemap = tilemap
	new_furniture.debug_placement_collider = debug_placement_collider
	add_child(new_furniture)
	
	await new_furniture.ready
	new_furniture.follow_component._move_entity_within_grid(new_furniture.global_position)
	
	return new_furniture
