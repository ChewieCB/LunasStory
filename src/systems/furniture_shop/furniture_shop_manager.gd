extends Node
class_name FurnitureShopManager

signal new_shop_contents(furniture_pool: Array)

@export var furniture_spawner: FurnitureSpawner
@export var furniture_shop_ui: FurnitureShopUI
@export var starting_furniture: int = 1

var current_furniture_pool: Array = []


func _ready() -> void:
	furniture_shop_ui.furniture_purchased.connect(_on_furniture_purchased)
	
	generate_shop_contents()
	populate_shop_contents()
	
	for idx in range(starting_furniture):
		furniture_spawner.spawn_furniture(current_furniture_pool.pick_random())


func generate_shop_contents(max_items: int = 3) -> Array:
	var all_furniture = furniture_spawner.entities
	all_furniture.shuffle()
	
	current_furniture_pool = []
	for idx in range(max_items):
		var furniture = all_furniture[idx]
		current_furniture_pool.append(furniture)
	
	emit_signal("new_shop_contents", current_furniture_pool)
	return current_furniture_pool


func populate_shop_contents() -> void:
	furniture_shop_ui.clear_all_furniture_buttons()
	for item in current_furniture_pool:
		furniture_shop_ui.create_furniture_button(item)


func _on_furniture_purchased(data: FurnitureData) -> void:
	furniture_spawner.spawn_furniture(data)
	CurrencyManager.current_gold -= data.cost
