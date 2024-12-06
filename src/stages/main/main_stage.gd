extends Node2D


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("reset"):
		CurrencyManager.current_gold = CurrencyManager.starting_gold
		get_tree().reload_current_scene()
