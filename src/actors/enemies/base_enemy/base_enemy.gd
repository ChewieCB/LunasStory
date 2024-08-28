extends CharacterBody2D
class_name BaseEnemy

#var target_node: Node2D
var target_pos: Vector2:
	set(value):
		target_pos = value
		ai_pathfinding_component.set_nav_target_position(target_pos)
		print("%s moving to %s" % [self.name, target_pos])

@export_category("Components")
@export var attack_range_hitbox_component: HitboxComponent
@export var ai_pathfinding_component: AIPathfindingComponent

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


func _ready() -> void:
	ai_pathfinding_component.pathfinding_ready.connect(spawn)


#func _input(event: InputEvent) -> void:
	#if Input.is_action_just_released("interact"):
		#target_pos = get_global_mouse_position()

#func _physics_process(delta: float) -> void:
	#var mouse_pos = get_global_mouse_position()
	#nav_agent.target_position = mouse_pos
	#
	#var current_agent_position: Vector2 = global_position
	#var next_path_position: Vector2 = nav_agent.get_next_path_position()
	#var direction: Vector2 = current_agent_position.direction_to(next_path_position)
	#var intended_velocity: Vector2 = direction * 50.0
	#
	#if nav_agent.is_navigation_finished():
		#return
	#
	#if nav_agent.avoidance_enabled:
		#nav_agent.set_velocity(intended_velocity)
	#else:
		#_on_navigation_agent_2d_velocity_computed(intended_velocity)
	#
	#print(velocity)
	#move_and_slide()


func spawn():
	# TODO - SFX hook
	# TODO - enemy UI hook
	# TODO - attacks hook
	# TODO - spawn animnation
	pass
	

func hurt():
	# TODO - hurt visuals
	# TODO - sfx hook
	pass


func die():
	state_chart.send_event("stop_moving")
	#state_chart.send_event("death")
	# TODO - SFX Hook
	# TODO - particle effects
	# TODO - drop debris

# <======================= STATE LOGIC =======================>

func _on_spawning_state_entered():
	# TODO - animation
	print("spawned %s" % self.name)
	state_chart.send_event("finish_spawn")


func _on_idle_state_entered():
	ai_pathfinding_component.disable()
	print("%s idle" % self.name)
	nav_agent.target_position = global_position

func _on_idle_state_physics_processing(_delta):
	if nav_agent.target_position != global_position:
		state_chart.send_event("start_moving")
	return


func _on_moving_state_entered() -> void:
	ai_pathfinding_component.enable()

func _on_moving_state_physics_processing(_delta):
	pass
	#if not target_pos:
		#return
	#
	#var current_agent_position: Vector2 = global_position
	#var next_path_position: Vector2 = nav_agent.get_next_path_position()
	#var direction: Vector2 = current_agent_position.direction_to(next_path_position)
	#var intended_velocity: Vector2 = direction * 7.0
	#nav_agent.set_velocity(intended_velocity)
	#
	#if nav_agent.is_navigation_finished():
		#return


func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	velocity = safe_velocity
	move_and_slide()
