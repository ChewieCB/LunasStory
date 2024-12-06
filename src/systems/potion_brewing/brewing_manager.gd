extends Node
class_name BrewingManager

signal recipe_set(recipe: PotionRecipe)
signal ingredient_added(requirement: PotionRecipeRequirement, index: int)
signal wrong_ingredient(data: IngredientData)
signal recipe_completed(recipe: PotionRecipe)
signal recipe_failed(recipe: PotionRecipe)

@export var initial_recipe: PotionRecipe
@export var ingredient_spawner: IngredientSpawner

var current_recipe: PotionRecipe:
	set(value):
		current_recipe = value
		emit_signal("recipe_set", current_recipe)


func _ready() -> void:
	for node in get_tree().get_nodes_in_group("consumer"):
		node.ingredient_consumed.connect(_handle_ingredient)
	
	await ingredient_spawner.new_ingredient_pool
	current_recipe = randomize_recipe()
	

func randomize_recipe() -> PotionRecipe:
	var requirements = []
	var ingredient_pool = ingredient_spawner.active_ingredient_pool.duplicate()
	ingredient_pool.shuffle()
	for i in range(3):
		var req = _create_requirement(
			ingredient_pool.pop_front(),
			randi_range(1, 3),
		)
		requirements.append(req)
	
	return _create_recipe(requirements)


func _create_recipe(requirements: Array) -> PotionRecipe:
	var new_recipe = PotionRecipe.new()
	new_recipe.requirements = requirements
	new_recipe.potion = load("res://src/systems/potion_brewing/resources/DefaultPotion.tres")
	return new_recipe


func _create_requirement(ingredient_data: IngredientData, count: int) -> PotionRecipeRequirement:
	var new_requirement = PotionRecipeRequirement.new()
	new_requirement.data = ingredient_data
	new_requirement.max_count = count
	return new_requirement


func _handle_ingredient(ingredient: Ingredient) -> void:
	var data = ingredient.data
	var req = current_recipe.get_ingredient_requirement(data)
	if req:
		if req.current_count < req.max_count:
			var idx = current_recipe.get_requirement_idx(req)
			if idx != -1:
				emit_signal("ingredient_added", req, idx)
				if current_recipe.is_completed():
					emit_signal("recipe_completed", current_recipe)
					ingredient_spawner.clear_all_ingredients()
				return
	emit_signal("wrong_ingredient", data)
	fail_potion(current_recipe)


func fail_potion(recipe: PotionRecipe) -> void:
	for req in recipe.requirements:
		req.current_count = 0
	
	emit_signal("recipe_failed", recipe)
