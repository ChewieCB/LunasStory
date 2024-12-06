extends Node

signal gold_changed(current_gold: int)

@export var starting_gold: int = 0

var current_gold: int = starting_gold:
	set(value):
		current_gold = max(0, value)
		emit_signal("gold_changed", current_gold)


func add_gold(amount: int) -> int:
	current_gold += abs(amount)
	return current_gold
	
