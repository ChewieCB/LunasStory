extends BaseComponent
class_name ParticlesComponent

@onready var particles: GPUParticles2D = $GPUParticles2D


func emit():
	particles.emitting = true


func stop():
	particles.emitting = false
