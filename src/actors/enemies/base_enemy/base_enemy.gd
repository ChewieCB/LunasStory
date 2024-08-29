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
		)
		target_node.grabbable_component.pickup.connect(
			func(_entity: Node2D):
				target_pos = self.global_position
		)


var target_pos: Vector2:
	set(value):
		target_pos = value
		ai_pathfinding_component.set_nav_target_position(target_pos)


func _ready() -> void:
	# Make sure the NavigationServer is synced
	ai_pathfinding_component.pathfinding_ready.connect(_spawn)
	attack_component.finish_attack.connect(func(attack): state_chart.send_event("finish_attack"))


func _spawn():
	pass
