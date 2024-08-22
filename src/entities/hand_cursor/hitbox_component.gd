extends BaseComponent
class_name HitboxComponent

signal body_entered
signal body_exited


func _on_body_entered(body: Node2D) -> void:
	emit_signal("body_entered")


func _on_body_exited(body: Node2D) -> void:
	emit_signal("body_exited")
