extends BaseComponent
class_name HitboxComponent

@onready var entity: Node2D = get_parent()
@onready var area_2d: Area2D = $Area2D

signal area_entered(area: Area2D)
signal area_exited(area: Area2D)


func _ready() -> void:
	was_disabled.connect(_set_collision_state.bind(false))
	was_enabled.connect(_set_collision_state.bind(true))


func _set_collision_state(state: bool) -> void:
	area_2d.monitoring = state
	area_2d.monitorable = state
	print("%s hitbox is %s" % [entity.name, ("enabled" if state else "disabled")])


func check_in_area(area: Area2D) -> bool:
	await get_tree().physics_frame
	await get_tree().physics_frame
	if area_2d.overlaps_area(area):
		print("%s overlaps %s" % [area_2d.get_parent().get_parent().name, area.get_parent().get_parent().name])
		return true
	print("%s does not overlap %s" % [area_2d.get_parent().get_parent().name, area.get_parent().get_parent().name])
	return false


func _on_area_2d_area_entered(area: Area2D) -> void:
	print("%s entered %s area" % [area.get_parent().name, get_parent().name])
	emit_signal("area_entered", area)


func _on_area_2d_area_exited(area: Area2D) -> void:
	emit_signal("area_exited", area)
