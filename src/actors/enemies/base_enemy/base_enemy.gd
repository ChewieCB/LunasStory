extends CharacterBody2D
class_name AIAgent

@export_category("Components")
@export var attack_range_hitbox_component: HitboxComponent
@export var ai_pathfinding_component: AIPathfindingComponent
@export var attack_component: AttackComponent
@export var particles_component: ParticlesComponent

@export_category("Nodes")
@export var state_chart: StateChart
@export var nav_agent: NavigationAgent2D
@export var target_node: InteractibleObject:
	set(value):
		target_node = value
		if target_node:
			if target_node.grabbable_component:
				target_node.grabbable_component.drop.connect(_drop_target)
				target_node.grabbable_component.pickup.connect(_pickup_target)
			await ai_pathfinding_component.pathfinding_ready
			target_pos = target_node.global_position


var target_pos: Vector2:
	set(value):
		target_pos = value
		ai_pathfinding_component.set_nav_target_position(target_pos)


func _ready() -> void:
	ai_pathfinding_component.pathfinding_ready.connect(_spawn)
	ai_pathfinding_component.nav_target_updated.connect(_on_nav_target_updated)
	ai_pathfinding_component.navigation_finished.connect(_on_navigation_finished)
	attack_component.cooldown_finished.connect(_on_attack_cooldown_finished)
	attack_component.finish_attack.connect(_on_attack_finished)
	attack_component.attack_failed.connect(_on_attack_failed)
	ai_pathfinding_component.enable()


func _spawn():
	# TODO - get target
	pass


func _hurt():
	# TODO
	pass


func _die():
	state_chart.send_event("stop_moving")
	state_chart.send_event("death")


func _on_idle_state_entered():
	if velocity != Vector2.ZERO:
		ai_pathfinding_component.stop_moving()


func _on_moving_state_entered():
	if not target_node:
		state_chart.send_event("stop_moving")


func _on_attacking_idle_state_entered() -> void:
	pass
	#attack_component.current_attack.abort_cooldown()


func _on_attacking_attack_state_entered():
	state_chart.send_event("stop_moving")
	attack_component.attack(target_node)


func _on_attacking_attack_state_exited():
	pass


func _on_dead_state_entered():
	queue_free()


func _on_nav_target_updated(_new_target_pos: Vector2) -> void:
	state_chart.send_event("start_moving")

func _on_navigation_finished() -> void:
	state_chart.send_event("stop_moving")

func _on_attack_hitbox_triggered(area: Area2D) -> void:
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
