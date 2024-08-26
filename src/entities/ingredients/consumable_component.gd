extends BaseComponent
class_name ConsumableComponent

signal can_consume(object: InteractibleObject)

@onready var entity: Node2D = get_parent()

@export_category("Components")
@export var hitbox_component: HitboxComponent


func _ready() -> void:
	add_to_group("consumable")
	self.can_consume.connect(consume_object)


func can_be_consumed() -> bool:
	for object in get_tree().get_nodes_in_group("consumer"):
		if await hitbox_component.check_in_area(object.hitbox_component.area_2d):
			emit_signal("can_consume", object)
			return true
	return false


func consume_object(object: InteractibleObject) -> void:
	object._consume_ingredient(entity)
	entity.queue_free()
