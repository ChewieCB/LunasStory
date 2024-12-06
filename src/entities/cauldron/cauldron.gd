extends InteractibleObject
class_name Cauldron

signal ingredient_consumed(ingredient: Ingredient)

@export_category("Components")
@export var dynamic_nav_obstacle: DynamicNavObstacleComponent
@export var particles_component: ParticlesComponent

#@export var consumption_particle: ParticleResource


func _ready() -> void:
	super()
	add_to_group("consumer")


func emit_particles(particle = particles_component.default_particle) -> void:
	var particles = particles_component.spawn_one_shot_particle(particle)
	add_child(particles)
	particles.finished.connect(func(): 
		remove_child(particles) 
		particles.queue_free()
	)
	particles.emitting = true


func _consume_ingredient(ingredient: Ingredient) -> void:
	print_rich("%s [color=purple]consumed[/color]!" % ingredient.name)
	emit_particles()
	emit_signal("ingredient_consumed", ingredient)


func _on_pickup(entity: Node2D) -> void:
	super(entity)
	if entity == self:
		dynamic_nav_obstacle.remove_previous_obstacle()


func _on_drop(entity: Node2D) -> void:
	super(entity)
	if entity == self:
		dynamic_nav_obstacle.create_obstacle()
