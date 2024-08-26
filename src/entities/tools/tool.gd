extends Node2D

@export_category("Components")
@export var selectable_component: SelectableComponent
@export var grabbable_component: GrabbableComponent
@export var follow_component: FollowComponent
@export var follow_target: Node2D

@export_category("Sprites")
@export var object_texture: Texture
@export var hover_texture: Texture
@export var texture_index: int = 1

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	add_to_group("tools")
	
	#sprite.texture = object_texture
	#texture_index = randi_range(1, 50)
	#sprite.frame = texture_index
	
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
	#
	grabbable_component.drop.connect(follow_component.disable)
	grabbable_component.drop.connect(selectable_component.enable)
	grabbable_component.drop.connect(_handle_item.bind(false))


func _physics_process(delta: float) -> void:
	if follow_component.is_enabled():
		global_position = follow_component.follow_global_position


func toggle_hover_texture(state: bool):
	if state == true:
		sprite.texture = hover_texture
	else:
		sprite.texture = object_texture


func _handle_item(state: bool) -> void:
	emit_signal("item", self, state)