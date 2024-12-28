extends BaseComponent
class_name PathfindingComponent

signal pathfinding_ready
signal nav_target_updated(target: InteractibleObject)
signal nav_target_pos_updated(position: Vector2)
signal navigation_finished

@export_category("Components")
@export var attack_component: AttackComponent
@export var nav_agent: NavigationAgent2D
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
@onready var target_search_area: Area2D = $Area2D


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


func _wait_for_navigation_setup() -> void:
	# Build the target query
	query = PhysicsShapeQueryParameters2D.new()
	query.collide_with_bodies = false
	query.collide_with_areas = true
	# TODO - make some global vars to track the collision layers
	query.collision_mask = pow(2, 3-1)
	query.shape = CircleShape2D.new()
	query.shape.radius = search_radius
	query.transform = Transform2D.IDENTITY
	
	# Setup the nav server RIDs
	nav_map_rid = entity.get_world_2d().get_navigation_map()
	nav_agent_rid = NavigationServer2D.agent_create()
	NavigationServer2D.agent_set_map(nav_agent_rid, nav_map_rid)
	NavigationServer2D.agent_set_avoidance_enabled(nav_agent_rid, true)
	NavigationServer2D.agent_set_radius(nav_agent_rid, avoid_radius)
	NavigationServer2D.agent_set_avoidance_callback(nav_agent_rid, self._on_velocity_computed)
	nav_agent.velocity_computed.connect(self._on_velocity_computed)
	NavigationServer2D.map_changed.connect(_on_map_changed)
	
	process_mode = Node.PROCESS_MODE_INHERIT
	emit_signal("pathfinding_ready")


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
		emit_signal("nav_target_pos_updated", nav_agent.target_position)


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


func _on_velocity_computed(safe_velocity: Vector2) -> void:
	entity.velocity = safe_velocity
	entity.move_and_slide()


func _on_map_changed(map: RID) -> void:
	if map == nav_map_rid:
		# TODO - make this if statement configurable via target priority?
		#if not can_path_to_target(target):
		target = _get_target()


func _get_target(_entity: Node2D = null) -> Node2D:
	# FIXME - intersect_shape query only works with items that are currently picked up?
	#query.transform.origin = entity.position
	#var area_2d_shape: Shape2D = target_search_area.get_node("CollisionShape2D").shape
	#query.shape = area_2d_shape
	#
	#var query_result = entity.get_world_2d().direct_space_state.intersect_shape(
		#query, max_intersect_results
	#)
	var query_result = target_search_area.get_overlapping_areas()
	
	if query_result:
		var targets: Array = []
		print_rich(
			"[color=orange]Potential targets[/color] found for [color=purple]%s.%s[/color] in range [color=teal]%s[/color]:" % [
				entity.name, entity.get_instance_id(),
				search_radius
			]
		)
		for item in query_result:
			var item_owner = item.owner
			print_rich(
				"\t[color=orange]%s.%s[/color] %s: %s" % [
					item_owner.name, item_owner.get_instance_id(), 
					"" if item.monitorable else "([color=red]disabled[/color])",
					item_owner.global_position.distance_to(entity.global_position)
				]
			)
			if item.monitorable:
				targets.append(item_owner)
		
		if not targets:
			return null
		
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
		
		if log_events:
			print_rich(
				"[color=orange]Targets[/color] found for [color=purple]%s.%s[/color] in range [color=teal]%s[/color]:" % [
					entity.name, entity.get_instance_id(),
					search_radius
				]
			)
			for target in targets:
				print_rich(
					"\t[color=yellow]%s.%s[/color]" % [
						target.name, target.get_instance_id()
					]
				)
		
		for node in targets:
			if can_path_to_target(node, attack_component.current_attack.attack_range):
				target = node
				break
		return target
		
	return null


func set_target(value):
	if value != null:
		if log_events:
			print_rich(
				"[color=purple]%s.%s[/color] setting target to [color=orange]%s.%s[/color]" % [
					entity.name, entity.get_instance_id(),
					value.name, value.get_instance_id()
				]
			)
		if can_path_to_target(value, attack_component.current_attack.attack_range):
			target = value
			set_nav_target_position(target.global_position)
			emit_signal("nav_target_updated", target)
			
			if log_events:
				print_rich(
					"[color=purple]%s.%s[/color] is targeting [color=orange]%s.%s[/color]" % [
						entity.name, entity.get_instance_id(),
						target.name, target.get_instance_id()
					]
				)
			return
	if log_events:
		print_rich(
			"[color=red]No targets found[/color] for [color=purple]%s.%s[/color]" % [
				entity.name, entity.get_instance_id(),
			]
		)


func can_path_to_target(node: Node2D, max_range: float) -> bool:
	if not node:
		return false
	
	var test_nav_regions = NavigationServer2D.map_get_regions(nav_map_rid)
	var test_nav_links = NavigationServer2D.map_get_links(nav_map_rid)
	
	var path_query := NavigationPathQueryParameters2D.new()
	var query_result := NavigationPathQueryResult2D.new()
	path_query.map = nav_map_rid
	path_query.start_position = entity.global_position
	path_query.target_position = node.global_position
	NavigationServer2D.query_path(path_query, query_result)
	
	var result_path = query_result.path
	var result: bool
	if result_path.size() <= 0:
		result = false
	else:
		result = query_result.path[-1].distance_to(node.global_position) < max_range
	
	if log_events:
		var debug_str = "[color=purple]%s.%s[/color] can path to [color=teal]%s.%s[/color] = " % [
			entity.name, entity.get_instance_id(), 
			node.name, node.get_instance_id()
		]
		var result_colour = "green" if result else "red"
		debug_str = debug_str + "[color=%s]%s[/color]" % [result_colour, result]
		print_rich(debug_str)
	
	return result
