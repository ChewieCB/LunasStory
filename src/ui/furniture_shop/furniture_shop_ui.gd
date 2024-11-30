extends Control
class_name FurnitureShopUI

signal furniture_purchased(data: FurnitureData)

@onready var furniture_buttons_container = $MarginContainer/FurnitureButtons
@export var furniture_button_scene: PackedScene


func clear_all_furniture_buttons() -> void:
	for container in furniture_buttons_container.get_children():
		container.queue_free()
		furniture_buttons_container.remove_child(container)


func create_furniture_button(data: FurnitureData) -> FurnitureButtonUI:
	var new_button = furniture_button_scene.instantiate()
	new_button.data = data
	
	furniture_buttons_container.add_child(new_button)
	
	return new_button


func _furniture_purchased(data: FurnitureData) -> void:
	emit_signal("furniture_purchased", data)


func _on_furniture_buttons_child_entered_tree(node: Node) -> void:
	node.purchased.connect(_furniture_purchased)


func _on_furniture_buttons_child_exiting_tree(node: Node) -> void:
	node.purchased.disconnect(_furniture_purchased)
