extends BaseComponent
class_name CollectibleComponent

signal collected()

@export var selectable_component: SelectableComponent
@export var collider: CollisionShape2D
@onready var entity := get_parent()


func _ready() -> void:
	add_to_group("collectible")


func _on_area_entered(area: Area2D) -> void:
	if is_enabled():
		if area.owner is HandCursor:
			collected.emit()
