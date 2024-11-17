extends Node2D

@export var tilemap: TileMapLayer
@export var portal_spawn_parent: Node2D

var active_ingredient_pool = []


# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#get_valid_placement()


func _draw() -> void:
	for point in get_valid_placement():
		draw_circle(point, 2.0, Color.RED)


func _process(_delta) -> void:
	queue_redraw()


func get_valid_placement() -> Array:
	var floor_tiles = _get_floor_tiles()
	# If there's an object with collision on a floor tile, don't spawn on that tile
	var blockers = get_tree().get_nodes_in_group("interactible")
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
	var blocker_tiles = []
	for node in blockers:
		if node is FurnitureBig:
			for tile in node.sprite_tiles:
				var cell = tilemap.map_to_local(
					tilemap.local_to_map(node.position - node.sprite_offset + tile)
				)
				blocker_tiles.append(cell)
		else:
			blocker_tiles.append(node.position)
			var map_pos = tilemap.local_to_map(node.position)
			for offset in surrounding_tiles:
				blocker_tiles.append(tilemap.map_to_local(map_pos + offset))
	
	var valid_tiles = floor_tiles.filter(
		func(x):
			return x not in blocker_tiles
	)
	# TODO - treat only open portals as blockers
	
	return valid_tiles
	


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


func set_ingredient_pool(ingredients: Array[IngredientData]) -> void:
	active_ingredient_pool = ingredients
