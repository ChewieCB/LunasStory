extends BaseComponent
class_name DynamicNavObstacleComponent

@export var obstacle_collider: CollisionShape2D

@onready var entity: Node2D = get_parent()

var previous_obstacle: NavigationObstacle2D
var default_map_rid: RID


func _ready() -> void:
	default_map_rid = entity.get_world_2d().get_navigation_map()
	await NavigationServer2D.map_changed
	_get_current_nav_region()
	await create_obstacle()


func create_obstacle(collision_shape: Shape2D = obstacle_collider.shape) -> void:
	var new_obstacle := NavigationObstacle2D.new()
	RectangleShape2D
	var collider_class = collision_shape.get_class()
	match collider_class:
		"CircleShape2D":
			new_obstacle.vertices = _create_circular_obstacle_outline(collision_shape.radius)
		"RectangleShape2D":
			var rect_size: Vector2 = collision_shape.size
			new_obstacle.vertices = [
				Vector2(-rect_size.x/2, -rect_size.y/2), Vector2(rect_size.x/2, -rect_size.y/2),
				rect_size/2, Vector2(-rect_size.x/2, rect_size.y/2)
			]
		_:
			push_error("%s not supported to create navigation obstacle!" % [collider_class])
	
	new_obstacle.global_position = entity.global_position
	new_obstacle.affect_navigation_mesh = true
	new_obstacle.carve_navigation_mesh = true
	
	var current_nav_region: NavigationRegion2D = _get_current_nav_region()
	
	# We only want one obstacle at a time, so make sure to 
	# remove any existing ones before we create the new one.
	if is_instance_valid(previous_obstacle):
		remove_previous_obstacle()
	
	current_nav_region.add_child(new_obstacle)
	_rebake_nav()
	
	previous_obstacle = new_obstacle


func remove_previous_obstacle() -> void:
	_remove_obstacle(previous_obstacle)


func _remove_obstacle(obstacle: NavigationObstacle2D) -> void:
	var current_nav_region: NavigationRegion2D = _get_current_nav_region()
	current_nav_region.remove_child(obstacle)
	_rebake_nav()
	obstacle.queue_free()


func _rebake_nav() -> void:
	var current_nav_region: NavigationRegion2D = _get_current_nav_region()
	current_nav_region.bake_navigation_polygon()


func _get_current_nav_region() -> NavigationRegion2D:
	var map_regions: Array[RID] = NavigationServer2D.map_get_regions(default_map_rid)
	if map_regions:
		var current_region_instance_id: int = NavigationServer2D.region_get_owner_id(map_regions[0])
		var current_nav_region: NavigationRegion2D = instance_from_id(current_region_instance_id)
		return current_nav_region
	return null


func _create_circular_obstacle_outline(obstacle_radius: float, points: int = 8) -> PackedVector2Array:
	var outline = PackedVector2Array()
	var angle_increment_rad: float = TAU / points
	
	for point in points:
		outline.append(
			Vector2(0, obstacle_radius).rotated(
				(angle_increment_rad * point) - angle_increment_rad
			)
		)
	
	return outline
