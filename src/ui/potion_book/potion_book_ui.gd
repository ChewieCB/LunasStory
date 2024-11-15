extends Control

@export var brewing_manager: BrewingManager
@export var ingredient_ui: PackedScene

@onready var portrait: TextureRect = $MarginContainer/TextureRect/MarginContainer/HBoxContainer/MarginContainer/TextureRect
@onready var ingredient_ui_container: VBoxContainer = $MarginContainer/TextureRect/MarginContainer/HBoxContainer/MarginContainer2/IngredientContainer


func _ready() -> void:
	if brewing_manager:
		brewing_manager.recipe_set.connect(set_potion_recipe)
		brewing_manager.ingredient_added.connect(increase_ingredient_count)


func set_potion_recipe(recipe: PotionRecipe) -> void:
	clear_ingredients()
	portrait.texture = recipe.potion.icon
	for i in range(recipe.requirements.size()):
		var requirement = recipe.requirements[i]
		set_ingredient_ui(requirement, i)


func increase_ingredient_count(requirement: PotionRecipeRequirement, index: int) -> void:
	requirement.current_count += 1
	set_ingredient_ui(requirement, index)


func set_ingredient_ui(requirement: PotionRecipeRequirement, index: int = 0) -> void:
	if index >= 3:
		push_error("Ingredient UI index exceeds maximum index.")
		return
	
	var ui = ingredient_ui_container.get_child(index)
	if not ui:
		ui = ingredient_ui.instantiate()
		ingredient_ui_container.add_child(ui)
		ingredient_ui_container.move_child(ui, index)
	
	ui.data = requirement.data
	ui.set_label(requirement.current_count, requirement.max_count)
	ui.visible = true


func clear_ingredients() -> void:
	for ui_node in ingredient_ui_container.get_children():
		ui_node.visible = false
		ui_node.set_label()
		ui_node.data = null
		ui_node.icon.texture = null
