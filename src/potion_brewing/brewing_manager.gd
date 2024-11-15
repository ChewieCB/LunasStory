extends Node
class_name BrewingManager

signal recipe_set(recipe: PotionRecipe)
signal ingredient_added(ingredient: IngredientData, new_count: int)
signal wrong_ingredient(ingredient: IngredientData)
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
	#if true:
		#emit_signal("ingredient_added", ingredient.data, ic.count)
	#else:
		#emit_signal("wrong_ingredient", ingredient.data)
	
