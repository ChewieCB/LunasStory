extends InteractibleObject
class_name Ingredient

@export_category("Components")
@export var consumable_component: ConsumableComponent


func _ready() -> void:
	super()
	grabbable_component.drop.connect(consumable_component.can_be_consumed)
	add_to_group("ingredients")
