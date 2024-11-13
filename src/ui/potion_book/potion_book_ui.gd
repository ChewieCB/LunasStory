extends Control

@onready var portrait: TextureRect = $PortraitMargin/Portrait
@onready var ingredient_ui_container: VBoxContainer = $MarginContainer/TextureRect/MarginContainer/HBoxContainer/IngredientContainer


func set_potion_recipe(recipe: PotionRecipe) -> void:
	clear_ingredients()
	portrait.texture = recipe.potion.icon
	for i in range(recipe.ingredient_counts.size()):
		var ic = recipe.ingredient_counts[i]
		set_ingredient_ui(ic.ingredient.icon, 0, ic.count, i)


func set_ingredient_ui(icon: Texture2D, current_count: int = 0, max_count: int = 0, index: int = 0) -> void:
	if index >= 3:
		push_error("Ingredient UI index exceeds maximum index.")
		return
	
	var ui = ingredient_ui_container.get_child(index)
	ui.ingredient_texture = icon
	ui.set_label(current_count, max_count)
	ui.visible = true


func clear_ingredients() -> void:
	for ui_node in ingredient_ui_container.get_children():
		ui_node.visible = false
		ui_node.set_label()
		ui_node.ingredient_texture = null
