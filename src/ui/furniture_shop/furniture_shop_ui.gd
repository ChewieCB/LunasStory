extends Control
class_name FurnitureShopUI

signal furniture_purchased(data: FurnitureData)


func _furniture_purchased(data: FurnitureData) -> void:
	emit_signal("furniture_purchased", data)


func _on_furniture_buttons_child_entered_tree(node: Node) -> void:
	node.purchased.connect(_furniture_purchased)


func _on_furniture_buttons_child_exiting_tree(node: Node) -> void:
	node.purchased.disconnect(_furniture_purchased)
