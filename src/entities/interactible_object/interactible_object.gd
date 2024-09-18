extends Node2D
class_name InteractibleObject

signal item(_item: Node2D, state: bool)

@export_category("Components")
@export var hitbox_component: HitboxComponent
@export var health_component: HealthComponent
@export var selectable_component: SelectableComponent
@export var grabbable_component: GrabbableComponent
@export var follow_component: FollowComponent
@export var follow_target: Node2D

@export_category("Sprites")
@export var sprite: Sprite2D
@export var object_texture: Texture
@export var hover_texture: Texture
@export var disabled_texture: Texture
@export var randomize_texture: bool = false
@export var texture_index: int = 1


func _ready() -> void:
	sprite.texture = object_texture
	if randomize_texture:
		texture_index = randi_range(1, 50)
		sprite.frame = texture_index
	
	# TODO - further decouple these components if possible
	if follow_component:
		follow_component.target = follow_target
	
	selectable_component.hover.connect(_on_hover)
	selectable_component.was_disabled.connect(toggle_hover_texture.bind(false))
	
	if grabbable_component:
		grabbable_component.pickup.connect(_on_pickup)
		grabbable_component.drop.connect(_on_drop)
	
	if health_component:
		health_component.died.connect(_on_died)


func toggle_hover_texture(state: bool):
	if state == true:
		sprite.texture = hover_texture
	else:
		sprite.texture = object_texture


func _handle_item(state: bool) -> void:
	emit_signal("item", self, state)


func _on_hover(entity: Node2D, state: bool) -> void:
	if entity == self:
		toggle_hover_texture(state)


func _on_pickup(entity: Node2D) -> void:
	if entity == self:
		follow_component.enable()
		selectable_component.disable()
		hitbox_component.disable()
		_handle_item(true)


func _on_drop(entity: Node2D) -> void:
	if entity == self:
		follow_component.disable()
		selectable_component.enable()
		grabbable_component.disable()
		hitbox_component.enable()
		# Re-enables grabbing if the cursor is still over the object
		selectable_component.query_hover()
		_handle_item(false)


func _on_died() -> void:
	selectable_component.disable()
	grabbable_component.disable()
	follow_component.disable()
	hitbox_component.disable()
	
	if disabled_texture:
		sprite.texture = disabled_texture
