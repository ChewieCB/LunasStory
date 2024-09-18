extends BaseComponent
class_name AttackComponent

signal finish_attack(_attack: AttackResource)
signal cooldown_finished(_attack: AttackResource)
signal cooldown_aborted(_attack: AttackResource)
signal attack_failed(_attack: AttackResource)

@export_category("Components")
@export var attack_range_hitbox_component: HitboxComponent
@onready var attack_range_collider: CollisionShape2D = attack_range_hitbox_component.collider
@export var particles_component: ParticlesComponent

@export_category("Attack Properties")
@export var generic_cooldown_timer: Timer
@export var attacks: Array[AttackResource]
@onready var current_attack: AttackResource:
	set(value):
		current_attack = value
		var _timer = Timer.new()
		add_child(_timer)
		current_attack.cooldown_timer = _timer
		current_attack.cooldown_ended.connect(_on_cooldown_finished)
		current_attack.cooldown_aborted.connect(_on_cooldown_aborted)

var priority_targets = []

@onready var entity: Node2D = get_parent()


func _ready() -> void:
	if attacks:
		current_attack = attacks[0]


func attack(target: Node2D, attack: AttackResource = current_attack) -> void:
	if not is_attack_in_range(target, attack) or \
	not attack.cooldown_timer.is_stopped():
		emit_signal("attack_failed", attack)
		return
	
	# Create the attack particles, assign the target as the parent, and connect the cleanup
	var particles: GPUParticles2D = particles_component.spawn_one_shot_particle()
	target.add_child(particles)
	particles.global_position = entity.global_position.lerp(target.global_position, 0.5)
	particles.finished.connect(particles.queue_free)
	
	if target.health_component:
		target.health_component.damage(attack.damage)
		print("THWAK! %s attacked %s with its %s attack for %s damage!" % [entity.name, target.name, attack.name, attack.damage])
	
	# Emit the particles, sound, and other juice at the point of impact
	particles.emitting = true
	# TODO - move this out into a SFX component
	attack.play_attack_sfx()

	emit_signal("finish_attack", attack)
	
	_attack_cooldown(attack)


func is_in_cooldown(_attack: AttackResource) -> bool:
	return not _attack.cooldown_timer.is_stopped()


func is_attack_in_range(target_node: Node2D, attack: AttackResource) -> bool:
	if not attack or not generic_cooldown_timer.is_stopped():
		return false
	return entity.global_position.distance_to(target_node.global_position) <= attack.attack_range


func get_next_attack() -> AttackResource:
	var attack_priority = attacks
	for elem in attack_priority:
		if not is_in_cooldown(elem):
			return elem
	return null


func _attack_cooldown(_attack: AttackResource = current_attack) -> void:
	_attack.start_cooldown()


func _update_attack_collider(attack: AttackResource) -> void:
	if is_instance_valid(attack):
		var new_shape: Shape2D = CircleShape2D.new()
		new_shape.radius = attack.attack_range
		attack_range_collider.shape = new_shape
		await get_tree().physics_frame


func _on_cooldown_finished(_attack: AttackResource) -> void:
	if not _attack.is_cooldown_aborted:
		emit_signal("cooldown_finished", _attack)


func _on_cooldown_aborted(_attack: AttackResource) -> void:
	emit_signal("cooldown_aborted", _attack)
