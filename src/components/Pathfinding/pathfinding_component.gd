extends BaseComponent
class_name PathfindingComponent

signal pathfinding_ready
signal nav_target_updated(position: Vector2)
signal navigation_finished

@export_category("Components")
@export var nav_agent: NavigationAgent2D
#@export var velocity_component
@export_category("Movement")
@export var current_speed: float = 10.0
@export var acceleration: float = 7.0

@export_category("Target Finding")
@export var search_radius: float = 128
@export var max_intersect_results := 8

@export_category("Avoidance")
@export var avoid_radius: float = 4.0

var target: InteractibleObject: set = set_target
var path: PackedVector2Array
var nav_map_rid: RID
var nav_agent_rid: RID

var query: PhysicsShapeQueryParameters2D


# TODO - make weighting exportable for enemies with different target priorities
enum TARGET_WEIGHT {
	Cauldron, 
	FurnitureBig, 
	Ingredient,
	Tool,
	Node2D
}

@onready var entity: CharacterBody2D = get_parent()


func _ready() -> void:
	nav_agent.navigation_finished.connect(emit_signal.bind("navigation_finished"))
	process_mode = Node.PROCESS_MODE_DISABLED
	call_deferred("_wait_for_navigation_setup")
	emit_signal("pathfinding_ready")


func _wait_for_navigation_setup() -> void:
	# Build the target query
	query = PhysicsShapeQueryParameters2D.new()
	query.collide_with_bodies = false
	query.collide_with_areas = true
	# TODO - make some global vars to track the collision layers
	query.collision_mask = pow(2, 3-1)
	query.shape = CircleShape2D.new()
	query.shape.radius = search_radius
	#query.exclude = [(separation_area as Area2D).get_rid()]
	query.transform = Transform2D.IDENTITY
	
	# Setup the nav server RIDs
	nav_map_rid = entity.get_world_2d().get_navigation_map()
	nav_agent_rid = NavigationServer2D.agent_create()
	NavigationServer2D.agent_set_map(nav_agent_rid, nav_map_rid)
	NavigationServer2D.agent_set_avoidance_enabled(nav_agent_rid, true)
	NavigationServer2D.agent_set_radius(nav_agent_rid, avoid_radius)
	NavigationServer2D.agent_set_avoidance_callback(nav_agent_rid, self._on_velocity_computed)
	nav_agent.velocity_computed.connect(self._on_velocity_computed)
	
	process_mode = Node.PROCESS_MODE_INHERIT


func _physics_process(_delta) -> void:
	if is_enabled():
		if not target:
			target = _get_target()
		
		var new_velocity = get_new_nav_agent_velocity()
		if nav_agent.avoidance_enabled:
			nav_agent.set_velocity(new_velocity)
		else:
			_on_velocity_computed(new_velocity)
	
	# Lock enemies to the nav region
	entity.global_position = NavigationServer2D.map_get_closest_point(
		nav_map_rid,
		entity.global_position,
	)


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


#func _unstick_pathfinding() -> void:
	#set_nav_target_position(nav_agent.target_position)


func _on_velocity_computed(safe_velocity: Vector2) -> void:
	entity.velocity = safe_velocity
	entity.move_and_slide()


func _get_target(_entity: Node2D = null) -> Node2D:
	# Update the position for our dynamic query, since it isn't
	# linked to our node in any way
	query.transform.origin = entity.position
	
	# Look for intersecting shapes, which means looking for all overlaps
	# between our Separation Shape and other enemies root Area.
	# the amount of results can be tweaked with "max_intersect_results": 
	# - with more results the separation becomes more precise, potentially
	# accounting for more nearby enemies.
	# - less results should mean more performance
	var query_result = entity.get_world_2d().direct_space_state.intersect_shape(
		query, max_intersect_results
	)
	
	if query_result:
		var targets: Array = []
		for item in query_result:
			targets.append(item.collider.owner)
		
		# Sort by distance
		targets.sort_custom(
			func(a, b):
				var a_dist: float = a.global_position.distance_to(entity.global_position)
				var b_dist: float = b.global_position.distance_to(entity.global_position)
				if a_dist < b_dist:
					return true
				return false
		)
		# Sort by target type weight
		targets.sort_custom(
			func(a, b):
				var a_class_str = String(a.get_script().get_global_name())
				var b_class_str = String(b.get_script().get_global_name())
				var a_weight = TARGET_WEIGHT[a_class_str]
				var b_weight = TARGET_WEIGHT[b_class_str]
				if a_weight < b_weight:
					return true
				return false
		)
		
		for node in targets:
			# TODO - check if we can actually reach the path
			if true:
				target = node
				break
		return target
		
	return null


func set_target(value):
	# Disconnect previous signals
	#if target:
		#if target.grabbable_component:
			#target.grabbable_component.pickup.disconnect(_get_target)
			##target.grabbable_component.drop.disconnect(update_path)
		#if target.health_component:
			#target.health_component.died.disconnect(_get_target)
	
	target = value
	entity.target_node = target
	
	# Connect signals
	#if target.grabbable_component:
		#target.grabbable_component.pickup.connect(_get_target)
		##target.grabbable_component.drop.connect(update_path)
	#if target.health_component:
		#target.health_component.died.connect(_get_target)
	
	set_nav_target_position(target.global_position)
