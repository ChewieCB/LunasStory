extends BaseComponent
class_name AttackComponent

signal finish_attack(_attack: AttackResource)

@export_category("Components")
@export var attack_range_hitbox_component: HitboxComponent
@onready var attack_range_collider: CollisionShape2D = attack_range_hitbox_component.collider
@export var particles_component: ParticlesComponent

@export_category("Attack Properties")
@export var generic_cooldown_timer: Timer
@export var attacks: Array[AttackResource]
var current_attack: AttackResource
var in_cooldown: Array[AttackResource]
var cooldown_timers: Array
var priority_targets = []

@onready var entity: Node2D = get_parent()


func attack(_attack: AttackResource):
	# Update the attack area
	attack_range_collider.shape.radius = _attack.attack_range
	await get_tree().physics_frame
	
	var targets = _attack.get_targets(entity)
	
	emit_signal("finish_attack", _attack)
	
	if targets:
		var particles = particles_component.spawn_one_shot_particle(
			_attack.attack_particle
		)
		
		if _attack.targeting_mode == AttackResource.TargetingMode.SINGLE:
			var _target = targets.front()
			# TODO - work out scale
			#attack_particles.scale = attack.attack_range
			_target.add_child(particles)
			particles.position = entity.position - _target.position
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
			var modified_damage = _attack.damage * entity.attributes.strength
			# TODO - figure out an intuitive armour/armour penetration system
			if _attack.armour_penetration < target.attributes.armour:
				modified_damage = clamp(
					modified_damage / target.attributes.armour,
					0,
					modified_damage
				)
			target.health_component.damage(modified_damage)
			
			if modified_damage > 0:
				# TODO - spawn a particle emitter for each attack instance
				particles.emitting = true
				#anim_player.play("attack")
				_attack.play_attack_sfx()
			else:
				#anim_player.play("block")
				_attack.play_block_sfx()
			
			target_count += 1
	
		_attack_cooldown(_attack)
		#status_ui._spawn_attack_indicator(attack.name, 0.6)
		current_attack = null
		
		# Generic cooldown to prevent spamming inputs each frame
		generic_cooldown_timer.start(0.4)


func _attack_cooldown(_attack: AttackResource):
	in_cooldown.append(_attack)
	var cd_timer = get_tree().create_timer(
		_attack.cooldown * remap(entity.attributes.dexterity, 0, 1, 3, 0.25)
	)
	cooldown_timers.append(cd_timer)
	
	await cd_timer.timeout
	
	in_cooldown.erase(_attack)
	cooldown_timers.erase(cd_timer)


func is_in_cooldown(_attack: AttackResource):
	return in_cooldown.has(_attack)
