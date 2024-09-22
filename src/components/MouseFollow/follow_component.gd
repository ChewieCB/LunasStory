extends BaseComponent
class_name FollowComponent

@onready var entity: Node2D = get_parent()

@export var target: Node2D
var follow_global_position: Vector2


func _ready():
	disable()


func _physics_process(delta: float) -> void:
	if is_enabled():
		entity.global_position = get_target_global_position()
	else:
		# TODO - lerp towards nearest valid position
		pass


func get_target_global_position() -> Vector2:
	if target:
		return target.get_current_cursor_marker().global_position
	return entity.global_position
