extends InteractibleObject
class_name Tool

signal tool_damage(area: Area2D, damage: float)

@export var _tool_damage: float = 10.0


func _ready() -> void:
	super()
	add_to_group("tools")
	hitbox_component.area_entered.connect(_on_tool_hitbox_entered)


func _on_pickup(entity: Node2D) -> void:
	if entity == self:
		follow_component.enable()
		selectable_component.disable()
		hitbox_component.enable()
		_handle_item(true)


func _on_drop(entity: Node2D) -> void:
	if entity == self:
		follow_component.disable()
		selectable_component.enable()
		grabbable_component.disable()
		hitbox_component.disable()
		# Re-enables grabbing if the cursor is still over the object
		selectable_component.query_hover()
		_handle_item(false)


func _on_tool_hitbox_entered(area: Area2D) -> void:
	emit_signal("tool_damage", area, _tool_damage)
