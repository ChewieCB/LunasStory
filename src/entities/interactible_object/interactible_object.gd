extends Node2D
class_name InteractibleObject

signal item(_item: Node2D, state: bool)

@export_category("Components")
@export var hitbox_component: HitboxComponent
@export var selectable_component: SelectableComponent
@export var grabbable_component: GrabbableComponent
@export var follow_component: FollowComponent
@export var follow_target: Node2D

@export_category("Sprites")
@export var sprite: Sprite2D
@export var object_texture: Texture
@export var hover_texture: Texture
@export var texture_index: int = 1




func _ready() -> void:	
	sprite.texture = object_texture
	texture_index = randi_range(1, 50)
	sprite.frame = texture_index
	
	follow_component.target = follow_target
	
	selectable_component.hover.connect(toggle_hover_texture)
	selectable_component.hover.connect(
		func(state: bool): 
			grabbable_component.enable() if state == true else grabbable_component.disable()
	)
	#
	selectable_component.was_disabled.connect(toggle_hover_texture.bind(false))
	
	grabbable_component.pickup.connect(follow_component.enable)
	grabbable_component.pickup.connect(selectable_component.disable)
	grabbable_component.pickup.connect(_handle_item.bind(true))
	grabbable_component.pickup.connect(hitbox_component.disable)
	#
	grabbable_component.drop.connect(follow_component.disable)
	grabbable_component.drop.connect(selectable_component.enable)
	grabbable_component.drop.connect(_handle_item.bind(false))
	grabbable_component.drop.connect(hitbox_component.enable)


func toggle_hover_texture(state: bool):
	if state == true:
		sprite.texture = hover_texture
	else:
		sprite.texture = object_texture


func _handle_item(state: bool) -> void:
	emit_signal("item", self, state)
