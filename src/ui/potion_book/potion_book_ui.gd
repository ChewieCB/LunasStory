extends Control

@export var brewing_manager: BrewingManager
@export var ingredient_ui: PackedScene

@onready var portrait: TextureRect = $MarginContainer/TextureRect/MarginContainer/HBoxContainer/MarginContainer/TextureRect
@onready var ingredient_ui_container: VBoxContainer = $MarginContainer/TextureRect/MarginContainer/HBoxContainer/MarginContainer2/IngredientContainer
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var current_recipe: PotionRecipe


func _ready() -> void:
	if brewing_manager:
		brewing_manager.recipe_set.connect(set_potion_recipe)
		brewing_manager.ingredient_added.connect(increase_ingredient_count)
		brewing_manager.recipe_completed.connect(succeed_recipe)
		brewing_manager.recipe_failed.connect(fail_recipe)


func set_potion_recipe(recipe: PotionRecipe) -> void:
	current_recipe = recipe
	clear_ingredients()
	set_potion_icon(recipe.potion.icon_in_progress)
	set_requirements_ui(recipe.requirements)


func set_requirements_ui(requirements: Array) -> void:
	for i in range(requirements.size()):
		var requirement = requirements[i]
		set_ingredient_ui(requirement, i)


func set_potion_icon(_texture: Texture2D) -> void:
	portrait.texture = _texture


func _set_potion_icon_complete(potion: Potion) -> void:
	set_potion_icon(potion.icon_complete)


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
	if requirement.current_count == requirement.max_count:
		ui.set_icon_disabled(true)
	ui.visible = true


func clear_ingredients() -> void:
	for ui_node in ingredient_ui_container.get_children():
		ui_node.visible = false
		ui_node.set_label()
		ui_node.data = null
		ui_node.icon.texture = null


func succeed_recipe(recipe: PotionRecipe) -> void:
	anim_player.play("shake_potion")
	_set_potion_icon_complete(recipe.potion)


func fail_recipe(recipe: PotionRecipe) -> void:
	set_requirements_ui(recipe.requirements)
	set_potion_icon(recipe.potion.icon_disabled)
	anim_player.play("shake_potion")
	await anim_player.animation_finished
	set_potion_icon(recipe.potion.icon_in_progress)


func _on_potion_icon_mouse_entered() -> void:
	match portrait.texture:
		current_recipe.potion.icon_in_progress:
			portrait.texture = current_recipe.potion.icon_in_progress_hover
		current_recipe.potion.icon_disabled:
			portrait.texture = current_recipe.potion.icon_disabled_hover
		current_recipe.potion.icon_complete:
			portrait.texture = current_recipe.potion.icon_complete_hover


func _on_potion_icon_mouse_exited() -> void:
	match portrait.texture:
		current_recipe.potion.icon_in_progress_hover:
			portrait.texture = current_recipe.potion.icon_in_progress
		current_recipe.potion.icon_disabled_hover:
			portrait.texture = current_recipe.potion.icon_disabled
		current_recipe.potion.icon_complete_hover:
			portrait.texture = current_recipe.potion.icon_complete
