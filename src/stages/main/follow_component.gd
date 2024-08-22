extends BaseComponent
class_name FollowComponent


@export var entity: Node2D
@export var target: Node2D


func _ready():
	disable()
	entity.pickup.connect(enable)
	entity.drop.connect(disable)


func _physics_process(delta: float) -> void:
	if is_enabled():
		entity.global_position = target.get_current_cursor_marker().global_position
	else:
		# TODO - lerp towards nearest valid position
		pass
