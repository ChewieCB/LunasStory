extends BaseComponent
class_name SelectableComponent

signal hover(entity: Node2D, state: bool)

@export var sprite: Sprite2D
@export var area_2d: Area2D

@onready var entity := get_parent()


func _ready():
	add_to_group("selectable")
	area_2d.area_entered.connect(_on_area_entered)
	area_2d.area_exited.connect(_on_area_exited)


func query_hover() -> void:
	if is_enabled():
		var overlaps := area_2d.get_overlapping_areas()
		for area in overlaps:
			if area.get_parent() is HandCursor:
				_on_area_entered(area)


func _on_area_entered(area: Area2D) -> void:
	if is_enabled():
		emit_signal("hover", entity, true)


func _on_area_exited(area: Area2D) -> void:
	if is_enabled():
		emit_signal("hover", entity, false)
