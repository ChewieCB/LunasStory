extends BaseComponent
class_name HurtboxComponent

@onready var entity: Node2D = get_parent()
@onready var area_2d: Area2D = $Area2D
@onready var collider: CollisionShape2D = $Area2D/CollisionShape2D

signal area_entered(area: Area2D)
signal area_exited(area: Area2D)


func _on_area_2d_area_entered(area: Area2D) -> void:
	emit_signal("area_entered", area)


func _on_area_2d_area_exited(area: Area2D) -> void:
	emit_signal("area_exited", area)
