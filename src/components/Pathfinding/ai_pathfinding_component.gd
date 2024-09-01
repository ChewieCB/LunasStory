extends BaseComponent
class_name AIPathfindingComponent

signal pathfinding_ready
signal nav_target_updated(position: Vector2)
signal navigation_finished

@export_category("Components")
@export var nav_agent: NavigationAgent2D
#@export var velocity_component
@export_category("Movement")
@export var current_speed: float = 10.0
@export var acceleration: float = 7.0

@onready var entity: CharacterBody2D = get_parent()


func _ready() -> void:
	nav_agent.navigation_finished.connect(emit_signal.bind("navigation_finished"))
	process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().physics_frame
	call_deferred("_wait_for_navigation_setup")
	emit_signal("pathfinding_ready")


func _wait_for_navigation_setup() -> void:
	await get_tree().physics_frame
	process_mode = Node.PROCESS_MODE_INHERIT


func _physics_process(_delta) -> void:
	if is_enabled():
		var new_velocity = get_new_nav_agent_velocity()
		if nav_agent.avoidance_enabled:
			nav_agent.set_velocity(new_velocity)
		else:
			_on_navigation_agent_2d_velocity_computed(new_velocity)


func set_nav_target_position(pos: Vector2) -> void:
	if pos != nav_agent.target_position:
		nav_agent.target_position = pos
		emit_signal("nav_target_updated", nav_agent.target_position)


func stop_moving() -> void:
	set_nav_target_position(entity.global_position)
	entity.velocity = Vector2.ZERO
	emit_signal("navigation_finished")


func get_new_nav_agent_velocity() -> Vector2:
	if nav_agent.is_navigation_finished():
		return entity.global_position

	var current_agent_position: Vector2 = entity.global_position
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	var direction: Vector2 = current_agent_position.direction_to(next_path_position)
	var intended_velocity: Vector2 = direction * current_speed
	
	return intended_velocity


func _unstick_pathfinding() -> void:
	set_nav_target_position(nav_agent.target_position)


func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	entity.velocity = safe_velocity
	entity.move_and_slide()
