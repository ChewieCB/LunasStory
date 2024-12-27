@tool
extends BaseComponent
class_name ParticlesComponent

@export var default_particle: ParticleResource
@export var test_particle_in_editor: bool = false:
	set(value):
		test_particle_in_editor = value
		if test_particle_in_editor:
			_test_particle_in_editor()


func spawn_one_shot_particle(particle: ParticleResource = default_particle) -> GPUParticles2D:
	var particles = GPUParticles2D.new()
	
	particles.amount = 1
	particles.process_material = particle.process_material
	particles.material = particle.canvas_material
	particles.texture = particle.texture
	# If we don't explicitly set emitting to false before we set one shot,
	# the finished signal wont emit for some reason.
	particles.emitting = false
	particles.one_shot = true
	particles.lifetime = particle.lifetime
	
	return particles


func emit_particles(node: Node2D, particles: GPUParticles2D) -> void:
	node.add_child(particles)
	particles.finished.connect(func(): 
		node.remove_child(particles) 
		particles.queue_free()
	)
	particles.emitting = true


func _test_particle_in_editor() -> void:
	if Engine.is_editor_hint():
		var test_particle = spawn_one_shot_particle()
		add_child(test_particle)
		test_particle.finished.connect(test_particle.queue_free)
		test_particle.emitting = true
		test_particle_in_editor = false
