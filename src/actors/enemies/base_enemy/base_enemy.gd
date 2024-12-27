extends CharacterBody2D
class_name AIAgent

signal spawned(agent: AIAgent)

@export_category("Components")
@export var target_range_hitbox_component: HitboxComponent
@export var attack_range_hitbox_component: HitboxComponent
@export var ai_pathfinding_component: AIPathfindingComponent
@export var hitbox_component: HitboxComponent
@export var health_component: HealthComponent
@export var attack_component: AttackComponent
@export var particles_component: ParticlesComponent

@export_category("Nodes")
@export var state_chart: StateChart
@export var nav_agent: NavigationAgent2D
@export var target_node: InteractibleObject: set = _set_target_node

@onready var sprite: Sprite2D = $Sprite2D

@export_category("Particles")
@export var hit_particle: ParticleResource
@export var damage_particle: ParticleResource
@export var death_particle: ParticleResource

# TODO - work this into a stats component
@export var target_search_range: float = 128.0:
	set(value):
		target_search_range = value
		await ready
		if target_range_hitbox_component:
			target_range_hitbox_component.collider.shape.radius = target_search_range

var target_pos: Vector2:
	set(value):
		target_pos = value
		ai_pathfinding_component.set_nav_target_position(target_pos)
		if target_pos != self.global_position:
			state_chart.send_event("start_moving")


func _ready() -> void:
	ai_pathfinding_component.pathfinding_ready.connect(_spawn)
	ai_pathfinding_component.nav_target_updated.connect(_on_nav_target_updated)
	ai_pathfinding_component.navigation_finished.connect(_on_navigation_finished)
	attack_component.attack_chosen.connect(_on_attack_chosen)
	attack_component.cooldown_finished.connect(_on_attack_cooldown_finished)
	attack_component.finish_attack.connect(_on_attack_finished)
	attack_component.attack_failed.connect(_on_attack_failed)
	health_component.health_changed.connect(_on_health_changed)
	health_component.died.connect(_on_died)
	await get_tree().physics_frame
	for tool in get_tree().get_nodes_in_group("tools"):
		tool.tool_damage.connect(_take_tool_damage)


func _spawn():
	await get_tree().physics_frame
	emit_signal("spawned", self)


func _hurt():
	# TODO
	pass


func _die():
	state_chart.send_event("stop_moving")
	state_chart.send_event("death")


func _set_target_node(new_target: InteractibleObject) -> void:
	# If we're clearing the target, we need to disconnect its signals from the enemy
	if new_target == null:
		_disconnect_signal_callbacks(target_node)
	
	target_node = new_target
	
	if target_node:
		_connect_signal_callbacks(target_node)
		if not ai_pathfinding_component.is_node_ready():
			await ai_pathfinding_component.pathfinding_ready
		target_pos = target_node.global_position


func _connect_signal_callbacks(target: InteractibleObject) -> void:
	pass
	#if not target_node:
		#return
	#if target_node.grabbable_component:
		#target_node.grabbable_component.drop.connect(_drop_target)
		#target_node.grabbable_component.pickup.connect(_pickup_target)
	#if target_node.health_component:
		#target_node.health_component.died.connect(_target_dead)
	#target_node.object_removed.connect(
		#func(object):
			#target_node = target_range_hitbox_component.get_target()
	#)


func _disconnect_signal_callbacks(target: InteractibleObject) -> void:
	pass
	#if not target_node:
		#return
	#if target_node.grabbable_component:
		#target_node.grabbable_component.drop.disconnect(_drop_target)
		#target_node.grabbable_component.pickup.disconnect(_pickup_target)
	#if target_node.health_component:
		#target_node.health_component.died.disconnect(_target_dead)

## ======== STATE MACHINE CALLBACKS ========

func _on_idle_state_entered():
	if velocity != Vector2.ZERO:
		ai_pathfinding_component.stop_moving()


func _on_moving_state_entered():
	if not target_node:
		state_chart.send_event("stop_moving")


func _on_attacking_idle_state_entered() -> void:
	pass


func _on_attacking_attack_state_entered():
	state_chart.send_event("stop_moving")
	attack_component.attack(target_node)


func _on_attacking_attack_state_exited():
	pass


func _on_damage_hurt_state_entered() -> void:
	# Play animation/particles/sfx
	var particles_to_spawn = [hit_particle, damage_particle]
	for _particle in particles_to_spawn:
		var particles = particles_component.spawn_one_shot_particle(_particle)
		particles_component.emit_particles(self, particles)
	# Fallback in case the damage killed the agent:
	## We always want to go from hurt -> dead instead of idle -> dead 
	## so our anims and juice play out for the impact
	if health_component.current_health == 0:
		state_chart.send_event("died")
		return
	# Wait for anims to finish
	# TODO
	# Send recover signal
	state_chart.send_event("damage_recovered")


func _on_damage_dead_state_entered() -> void:
	var particles = particles_component.spawn_one_shot_particle(death_particle)
	particles_component.emit_particles(get_parent(), particles)
	sprite.visible = false
	queue_free()

## ======== Signal Callbacks ========

func _on_nav_target_updated(_new_target_pos: Vector2) -> void:
	state_chart.send_event("start_moving")

func _on_navigation_finished() -> void:
	state_chart.send_event("stop_moving")

func _on_attack_hitbox_triggered(area: Area2D) -> void:
	if target_node:
		if area == target_node.hitbox_component.area_2d:
			state_chart.send_event("start_attack")

func _on_attack_cooldown_finished(_attack: AttackResource) -> void:
	state_chart.send_event("end_cooldown")

func _on_attack_finished(_attack: AttackResource) -> void:
	state_chart.send_event("start_cooldown")

func _on_attack_failed(_attack: AttackResource) -> void:
	state_chart.send_event("abort_attack")

func _pickup_target(_entity: Node2D) -> void:
	target_pos = self.global_position
	if velocity != Vector2.ZERO:
		ai_pathfinding_component.stop_moving()
	state_chart.send_event("abort_attack")

func _drop_target(_entity: Node2D) -> void:
	target_pos = target_node.global_position

func _on_attack_chosen(attack: AttackResource) -> void:
	attack_range_hitbox_component.collider.shape.radius = attack.attack_range

func _target_dead() -> void:
	target_node = null
	target_pos = self.global_position
	state_chart.send_event("abort_attack")

func _take_tool_damage(area: Area2D, damage: float) -> void:
	if area.get_parent() == hitbox_component:
		health_component.damage(damage)

func _on_health_changed(new_health: float, prev_health: float) -> void:
	if new_health < prev_health:
		state_chart.send_event("damage_taken")

func _on_died() -> void:
	state_chart.send_event("died")
	state_chart.send_event("stop_moving")
	state_chart.send_event("abort_attack")
	
