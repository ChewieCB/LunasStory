extends InteractibleObject
class_name Cauldron


@export_category("Components")
@export var dynamic_nav_obstacle: DynamicNavObstacleComponent
@export var particles_component: ParticlesComponent


func _ready() -> void:
	super()
	add_to_group("consumer")


func _consume_ingredient(ingredient: Ingredient) -> void:
	print("%s consumed!" % ingredient.name)
	particles_component.emit()


func _on_pickup(entity: Node2D) -> void:
	super(entity)
	if entity == self:
		dynamic_nav_obstacle.remove_previous_obstacle()


func _on_drop(entity: Node2D) -> void:
	super(entity)
	if entity == self:
		dynamic_nav_obstacle.create_obstacle()
