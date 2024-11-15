extends Node
class_name BrewingManager

signal recipe_set(recipe: PotionRecipe)
signal ingredient_added(requirement: PotionRecipeRequirement, index: int)
signal wrong_ingredient(data: IngredientData)
signal potion_brewed(potion: Potion)
signal potion_failed(potion: Potion)

@export var initial_recipe: PotionRecipe

var current_recipe: PotionRecipe:
	set(value):
		current_recipe = value
		emit_signal("recipe_set", current_recipe)


func _ready() -> void:
	for node in get_tree().get_nodes_in_group("consumer"):
		node.ingredient_consumed.connect(_handle_ingredient)
	
	if initial_recipe:
		current_recipe = initial_recipe


func _handle_ingredient(ingredient: Ingredient) -> void:
	var data = ingredient.data
	var req = current_recipe.get_ingredient_requirement(data)
	if req:
		if req.current_count < req.max_count:
			var idx = current_recipe.get_requirement_idx(req)
			if idx != -1:
				emit_signal("ingredient_added", req, idx)
				return
	emit_signal("wrong_ingredient", data)
