extends MarginContainer
class_name FurnitureButtonUI

signal purchased(data: FurnitureData)

@export var data: FurnitureData

@onready var button: TextureButton = $VBoxContainer/ButtonArea
@onready var icon_rect: TextureRect = $VBoxContainer/ButtonArea/FurnitureIcon
@onready var cost_label: Label = $VBoxContainer/MarginContainer/HBoxContainer/Label
@onready var label_container: Container = $VBoxContainer/MarginContainer/HBoxContainer


func _ready() -> void:
	icon_rect.texture = data.icon
	cost_label.text = str(data.cost)
	CurrencyManager.gold_changed.connect(_on_gold_changed)
	_on_gold_changed(CurrencyManager.current_gold)


func disable() -> void:
	icon_rect.texture = data.icon_disabled
	button.disabled = true
	label_container.modulate = Color("#575757")


func enable() -> void:
	icon_rect.texture = data.icon
	button.disabled = false
	label_container.modulate = Color("#ffffff")


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
