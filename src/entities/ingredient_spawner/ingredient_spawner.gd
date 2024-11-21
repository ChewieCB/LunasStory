extends Node2D

@export_category("Nodes")
@export var tilemap: TileMapLayer
@export var portal_spawn_parent: Node2D
@export var hand_cursor: HandCursor
@export_category("Spawning")
@export var ingredient_scene: PackedScene
@export var ingredients: Array[IngredientData]
@export var spawn_delay: float = 1.5
@export var max_spawned: int = 10
@export_category("Debug")
@export var show_valid_placements: bool = false

@onready var spawn_timer: Timer = $SpawnTimer

var active_ingredient_pool = []


func _ready() -> void:
	start_spawn_timer()
	# TODO - replace with signal to wave spawner start


func _draw() -> void:
	if show_valid_placements:
		for point in get_valid_placements():
			draw_circle(point, 2.0, Color.RED)


func _process(_delta) -> void:
	queue_redraw()


func spawn_ingredient(ingredient_data: IngredientData) -> Vector2:
	var ingredient = ingredient_scene.instantiate()
	var valid_positions = get_valid_placements()
	valid_positions.shuffle()
	var spawn_pos = valid_positions.pop_front()
	ingredient.position = spawn_pos
	ingredient.data = ingredient_data
	ingredient.follow_target = hand_cursor
	add_child(ingredient)
	
	return spawn_pos


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


func set_ingredient_pool(ingredients: Array[IngredientData]) -> void:
	active_ingredient_pool = ingredients


func start_spawn_timer() -> void:
	spawn_timer.start(spawn_delay)


func _on_spawn_timer_timeout() -> void:
	if get_child_count() <= max_spawned:
		spawn_ingredient(ingredients.pick_random())
	start_spawn_timer()
