extends EntitySpawner
class_name FurnitureSpawner

@export var furniture_shop_ui: Control


func _ready() -> void:
	furniture_shop_ui.furniture_purchased.connect(spawn_furniture)


func spawn_furniture(data: FurnitureData) -> FurnitureBig:
	var new_furniture = spawn_entity(data)
	new_furniture.follow_component_tilemap = tilemap
	add_child(new_furniture)
	
	return new_furniture
