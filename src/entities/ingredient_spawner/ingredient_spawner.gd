extends EntitySpawner
class_name IngredientSpawner

signal new_ingredient_pool(ingredient_pool: Array)

@export_category("Ingredient Spawns")
@export var spawn_delay: float = 1.5
@export var max_spawned: int = 15
@export var max_ingredient_variety: int = 4

@onready var spawn_timer: Timer = $SpawnTimer

var active_ingredient_pool: Array = []
var current_spawns: Array = []
var current_spawn_pool: Array = []


func set_active_ingredients(max_variety: int = max_ingredient_variety, override_existing: bool = false) -> Array:
	if active_ingredient_pool and not override_existing:
		return active_ingredient_pool
	
	var all_ingredients = entities
	all_ingredients.shuffle()
	
	active_ingredient_pool = []
	for idx in range(max_variety):
		var ingredient = all_ingredients[idx]
		active_ingredient_pool.append(ingredient)
	
	emit_signal("new_ingredient_pool", active_ingredient_pool)
	return active_ingredient_pool


func start_spawning() -> void:
	spawn_timer.start(spawn_delay)


func stop_spawning() -> void:
	spawn_timer.stop()


func spawn_ingredient(data: IngredientData) -> Ingredient:
	var ingredient = spawn_entity(data)
	ingredient.decayed.connect(_remove_from_current_spawns)
	ingredient.consumed.connect(_remove_from_current_spawns)
	add_child(ingredient)
	
	return ingredient


func clear_all_ingredients() -> void:
	for ingredient in current_spawns:
		ingredient.decay()


func set_ingredient_pool(ingredients: Array[IngredientData]) -> void:
	active_ingredient_pool = ingredients
	current_spawn_pool = []


func _on_spawn_timer_timeout() -> void:
	if active_ingredient_pool:
		if get_child_count() <= max_spawned:
			if not current_spawn_pool:
				current_spawn_pool = active_ingredient_pool.duplicate()
				current_spawn_pool.shuffle()
			var _ingredient = current_spawn_pool.pop_front()
			current_spawns.append(spawn_ingredient(_ingredient))
		start_spawning()


func _remove_from_current_spawns(ingredient: Ingredient) -> void:
	if ingredient in current_spawns:
		current_spawns.erase(ingredient)
