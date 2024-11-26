extends Control

@onready var ingredient_container = $MarginContainer/HBoxContainer

@export var ingredient_spawner: IngredientSpawner

func _ready() -> void:
	ingredient_spawner.new_ingredient_pool.connect(_regenerate_ui)


func add_ingredient_ui(ingredient_data: IngredientData) -> void:
	var new_rect = TextureRect.new()
	new_rect.texture = ingredient_data.icon
	new_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	ingredient_container.add_child(new_rect)


func clear_ingredient_ui() -> void:
	for child in ingredient_container.get_children():
		ingredient_container.remove_child(child)
		child.queue_free()


func _regenerate_ui(ingredient_pool: Array) -> void:
	clear_ingredient_ui()
	for ingredient in ingredient_pool:
		add_ingredient_ui(ingredient)
