extends BaseComponent
class_name ParticlesComponent

@export var default_particle: ParticleResource


func spawn_one_shot_particle(particle: ParticleResource = default_particle) -> GPUParticles2D:
	var particles = GPUParticles2D.new()
	
	particles.amount = 1
	particles.process_material = particle.process_material
	particles.material = particle.canvas_material
	particles.texture = particle.texture
	particles.one_shot = true
	
	return particles
