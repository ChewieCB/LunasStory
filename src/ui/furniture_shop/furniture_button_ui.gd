extends MarginContainer
class_name FurnitureButtonUI

@export var data: FurnitureData

@onready var icon_rect: TextureRect = $ButtonFrame/FurnitureIcon


func _ready() -> void:
	icon_rect.texture = data.icon


func _on_button_area_mouse_entered() -> void:
	icon_rect.texture = data.icon_hover


func _on_button_area_mouse_exited() -> void:
	icon_rect.texture = data.icon


func _on_button_area_pressed() -> void:
	# TODO - check currency, remove currency, spawn furniture object
	pass
