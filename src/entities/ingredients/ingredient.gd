extends InteractibleObject
class_name Ingredient

@export_category("Components")
@export var consumable_component: ConsumableComponent

@export var data: IngredientData


func _ready() -> void:
	super()
	add_to_group("ingredients")


func _on_drop(entity: Node2D) -> void:
	super(entity)
	if entity == self:
		consumable_component.can_be_consumed()
