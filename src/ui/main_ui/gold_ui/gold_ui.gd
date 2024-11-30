extends Control
class_name GoldUI

@onready var current_gold_label: Label = $MarginContainer/HBoxContainer/Label


func _ready() -> void:
	CurrencyManager.gold_changed.connect(_on_gold_changed)
	_on_gold_changed(CurrencyManager.current_gold)


func _on_gold_changed(current_gold: int) -> void:
	current_gold_label.text = "%s" % current_gold
