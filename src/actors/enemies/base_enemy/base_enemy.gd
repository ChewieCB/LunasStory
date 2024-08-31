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
		target_node.grabbable_component.drop.connect(
			func(_entity: Node2D):
				target_pos = target_node.global_position
				ai_pathfinding_component.set_nav_target_position(target_pos)
		)
		target_node.grabbable_component.pickup.connect(
			func(_entity: Node2D):
				target_pos = self.global_position
				if velocity != Vector2.ZERO:
					ai_pathfinding_component.stop_moving()
		)


var target_pos: Vector2:
	set(value):
		target_pos = value
		ai_pathfinding_component.set_nav_target_position(target_pos)


func _ready() -> void:
	# Make sure the NavigationServer is synced
	ai_pathfinding_component.pathfinding_ready.connect(_spawn)
	ai_pathfinding_component.nav_target_updated.connect(_on_nav_target_updated)
	ai_pathfinding_component.navigation_finished.connect(_on_navigation_finished)
	attack_component.cooldown_finished.connect(_on_attack_cooldown_finished)
	attack_component.finish_attack.connect(_on_attack_finished)


func _spawn():
	# TODO
	ai_pathfinding_component.enable()
	pass


func _hurt():
	# TODO
	pass


func _die():
	state_chart.send_event("stop_moving")
	state_chart.send_event("death")


func _on_idle_state_entered():
	ai_pathfinding_component.stop_moving()


func _on_moving_state_entered():
	if not target_node:
		state_chart.send_event("stop_moving")


func _on_attacking_attack_state_entered():
	state_chart.send_event("stop_moving")
	attack_component.attack(target_node)


func _on_attacking_attack_state_exited():
	pass
	#attack_component.disable()


func _on_dead_state_entered():
	#anim_player.play("death")
	#await anim_player.animation_finished
	queue_free()


#func _on_walking_state_entered():
	#anim_player.play("walk")
#
#
#func _on_walking_state_exited():
	#anim_player.stop()


func _on_nav_target_updated(_new_target_pos: Vector2) -> void:
	state_chart.send_event("start_moving")

func _on_navigation_finished() -> void:
	state_chart.send_event("stop_moving")

func _on_attack_hitbox_triggered(area: Area2D) -> void:
	if area == target_node.hitbox_component.area_2d:
		state_chart.send_event("start_attack")

func _on_attack_cooldown_finished(_attack: AttackResource) -> void:
	if attack_component.is_attack_in_range(target_node, _attack):
		state_chart.send_event("start_attack")

func _on_attack_finished(_attack: AttackResource) -> void:
	state_chart.send_event("finish_attack")
