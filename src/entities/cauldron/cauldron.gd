extends InteractibleObject
class_name Cauldron


@export_category("Components")
@export var particles_component: ParticlesComponent


func _ready() -> void:
	super()
	add_to_group("consumer")


func _consume_ingredient(ingredient: Ingredient) -> void:
	print("%s consumed!" % ingredient.name)
	particles_component.emit()
