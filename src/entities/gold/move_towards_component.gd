extends BaseComponent
class_name MoveTowardsComponent

@export var collection_radius: float = 100
@export var move_speed: float = 440

@onready var entity := get_parent()
@onready var range_collider: CollisionShape2D = $CollisionShape2D

@export var toggleable: bool = true
var is_moving: bool = false


func _ready() -> void:
	range_collider.shape.radius = collection_radius
	disable()


func _physics_process(delta: float) -> void:
	if is_moving:
		entity.global_position = _move_towards(
			entity.global_position,
			entity.follow_target.global_position,
			collection_radius,
			move_speed,
			delta
		)


func _move_towards(
	entity_pos: Vector2, target_pos: Vector2, 
	max_range: float, move_speed: float, 
	delta: float
) -> Vector2:
	var direction_to_target = entity_pos.direction_to(target_pos)
	var distance_to_target = entity_pos.distance_to(target_pos)
	var move_speed_mod = remap(distance_to_target, 0, max_range, 0.1, 1)
	
	return entity_pos + direction_to_target * move_speed * move_speed_mod * delta


func enable() -> void:
	enabled = true
	is_moving = true


func disable() -> void:
	enabled = false
	if not toggleable:
		is_moving = false


func _on_area_entered(area: Area2D) -> void:
	if area.owner is HandCursor:
		enable()


func _on_area_exited(area: Area2D) -> void:
	if area.owner is HandCursor:
		disable()
