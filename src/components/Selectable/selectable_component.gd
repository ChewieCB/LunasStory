extends BaseComponent
class_name SelectableComponent

signal hover(entity: Node2D, state: bool)

@export var sprite: Sprite2D

@onready var entity := get_parent()


func _ready():
	add_to_group("selectable")


func _on_area_entered(area: Area2D) -> void:
	if is_enabled():
		emit_signal("hover", entity, true)


func _on_area_exited(area: Area2D) -> void:
	if is_enabled():
		emit_signal("hover", entity, false)
