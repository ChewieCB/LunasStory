extends BaseComponent
class_name AttackComponent

signal finish_attack(_attack: AttackResource)
signal cooldown_finished(_attack: AttackResource)
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
var in_cooldown: Array[AttackResource]
var cooldown_timers: Array
var priority_targets = []

@onready var entity: Node2D = get_parent()


func _ready() -> void:
	if attacks:
		current_attack = attacks[0]


func attack(target: Node2D, attack: AttackResource = current_attack) -> void:
	if not is_attack_in_range(target, attack):
		emit_signal("attack_failed", attack)
		return
	
	# Create the attack particles, assign the target as the parent, and connect the cleanup
	var particles: GPUParticles2D = particles_component.spawn_one_shot_particle()
	target.add_child(particles)
	particles.global_position = entity.global_position.lerp(target.global_position, 0.5)
	particles.finished.connect(particles.queue_free)
	
	## DAMAGE GOES HERE - when we have the health component implemented
	print("THWAK! %s attacked %s with its %s attack!" % [entity.name, target.name, attack.name])
	#
	
	# Emit the particles, sound, and other juice at the point of impact
	particles.emitting = true
	# TODO - move this out into a SFX component
	attack.play_attack_sfx()

	emit_signal("finish_attack", attack)
	_attack_cooldown(attack)


func is_in_cooldown(_attack: AttackResource) -> bool:
	return in_cooldown.has(_attack)


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


## This is needlessly complicated for our current use case, return to this if we have AoE attacks
func attack_complex(_attack: AttackResource = current_attack) -> void:
	var targets = _attack.get_target_areas(entity)
	if targets:
		var particles: GPUParticles2D = particles_component.spawn_one_shot_particle()
		
		if _attack.targeting_mode == AttackResource.TargetingMode.SINGLE:
			var _target = targets.front()
			# TODO - work out scale
			#attack_particles.scale = attack.attack_range
			_target.add_child(particles)
			particles.position = _target.position
		elif _attack.targeting_mode == AttackResource.TargetingMode.MULTIPLE:
			for _target in targets:
				var _particles_clone = particles.duplicate()
				_target.add_child(_particles_clone)
				_particles_clone.finished.connect(
					func():
					particles.queue_free()
				)
				particles.queue_free()
		else:
			add_child(particles)
		
		if particles:
			particles.finished.connect(
				func():
				particles.queue_free()
			)
		
		var target_count: int = 0
		for target in targets:
			#if target.health_component.current_health <= 0:
				#if target in priority_targets:
					#priority_targets.erase(target)
				#continue
			
			if _attack.targeting_mode == AttackResource.TargetingMode.MULTIPLE:
				if target_count >= _attack.max_targets:
					break
				
			# Damage and armour penetration
			# TODO - playtest and tweak armour damage reduction 
			var modified_damage = _attack.damage #* entity.attributes.strength
			# TODO - figure out an intuitive armour/armour penetration system
			#if _attack.armour_penetration < target.attributes.armour:
				#modified_damage = clamp(
					#modified_damage / target.attributes.armour,
					#0,
					#modified_damage
				#)
			#target.health_component.damage(modified_damage)
			
			if modified_damage > 0:
				# TODO - spawn a particle emitter for each attack instance
				particles.emitting = true
				#anim_player.play("attack")
				_attack.play_attack_sfx()
			else:
				#anim_player.play("block")
				_attack.play_block_sfx()
			
			target_count += 1
		
		emit_signal("finish_attack", _attack)
	
		_attack_cooldown(_attack)
		#status_ui._spawn_attack_indicator(attack.name, 0.6)
		#current_attack = null
		
		# Generic cooldown to prevent spamming inputs each frame
		generic_cooldown_timer.start(0.4)


func _attack_cooldown(_attack: AttackResource = current_attack) -> void:
	in_cooldown.append(_attack)
	var cd_timer = get_tree().create_timer(
		_attack.cooldown# * remap(entity.attributes.dexterity, 0, 1, 3, 0.25)
	)
	cooldown_timers.append(cd_timer)
	
	await cd_timer.timeout
	
	in_cooldown.erase(_attack)
	cooldown_timers.erase(cd_timer)
	emit_signal("cooldown_finished", _attack)


func _update_attack_collider(attack: AttackResource) -> void:
	if is_instance_valid(attack):
		var new_shape: Shape2D = CircleShape2D.new()
		new_shape.radius = attack.attack_range
		attack_range_collider.shape = new_shape
		await get_tree().physics_frame
