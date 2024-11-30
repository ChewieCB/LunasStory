extends MarginContainer
class_name FurnitureButtonUI

signal purchased(data: FurnitureData)

@export var data: FurnitureData

@onready var button: Button = $VBoxContainer/ButtonFrame/ButtonArea
@onready var icon_rect: TextureRect = $VBoxContainer/ButtonFrame/FurnitureIcon
@onready var cost_label: Label = $VBoxContainer/MarginContainer/HBoxContainer/Label


func _ready() -> void:
	icon_rect.texture = data.icon
	cost_label.text = str(data.cost)
	CurrencyManager.gold_changed.connect(_on_gold_changed)


func disable() -> void:
	icon_rect.texture = data.icon_disabled
	button.disabled = true


func enable() -> void:
	icon_rect.texture = data.icon
	button.disabled = false


func _on_gold_changed(current_gold: int) -> void:
	if current_gold >= data.cost:
		enable()
	else:
		disable()


func _on_button_area_mouse_entered() -> void:
	if not button.disabled:
		icon_rect.texture = data.icon_hover


func _on_button_area_mouse_exited() -> void:
	if not button.disabled:
		icon_rect.texture = data.icon


func _on_button_area_pressed() -> void:
	emit_signal("purchased", data)
	# TODO - check currency, remove currency, spawn furniture object
