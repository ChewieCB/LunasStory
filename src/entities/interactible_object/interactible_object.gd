extends Node2D
class_name InteractibleObject

signal item(_item: Node2D, state: bool)
signal object_removed(object: InteractibleObject)

@export_category("Components")
@export var hitbox_component: HitboxComponent
@export var health_component: HealthComponent
@export var selectable_component: SelectableComponent
@export var grabbable_component: GrabbableComponent
@export var follow_component: FollowComponent
@export var follow_target: Node2D

@export var data: Data

@export_category("Particles")
@export var pickup_particle: ParticleResource
@export var drop_particle: ParticleResource
@export var hit_particle: ParticleResource
@export var damage_particle: ParticleResource
@export var death_particle: ParticleResource

@onready var sprite := $Sprite2D


func _ready() -> void:
	add_to_group("interactible")
	_set_sprite_texture()
	#self.name = self.data.name if self.data.name != "" else get_class()
	
	# TODO - further decouple these components if possible
	if follow_component:
		follow_component.target = follow_target
	
	if grabbable_component:
		selectable_component.hover.connect(_on_hover)
		selectable_component.was_disabled.connect(toggle_hover_texture.bind(false))
	
	if grabbable_component:
		grabbable_component.pickup.connect(_on_pickup)
		grabbable_component.drop.connect(_on_drop)
	
	if health_component:
		health_component.died.connect(_on_died)
		health_component.health_changed.connect(_on_health_changed)


func _set_sprite_texture() -> void:
	sprite.texture = data.icon


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		emit_signal("object_removed", self)


func toggle_hover_texture(state: bool):
	if data:
		if state == true:
			sprite.texture = data.icon_hover
		else:
			sprite.texture = data.icon


func get_tiles_for_sprite(tilemap: TileMapLayer) -> Array[Vector2]:
		var tile_size: Vector2 = tilemap.tile_set.tile_size
		var x_tiles_per_sprite: int = data.sprite_size.x / tile_size.x
		var y_tiles_per_sprite: int = data.sprite_size.y / tile_size.y
		
		var tiles: Array[Vector2] = []
		for x_tile in range(x_tiles_per_sprite):
			for y_tile in range(y_tiles_per_sprite):
				tiles.append(Vector2(tile_size.x * x_tile, tile_size.y * y_tile))
		
		return tiles


func _handle_item(state: bool) -> void:
	emit_signal("item", self, state)


func _on_hover(entity: Node2D, state: bool) -> void:
	if entity == self:
		toggle_hover_texture(state)


func _on_pickup(entity: Node2D) -> void:
	if entity == self and grabbable_component.is_enabled():
		hitbox_component.disable()
		follow_component.enable()
		selectable_component.disable()
		_handle_item(true)


func _on_drop(entity: Node2D) -> void:
	if entity == self:
		hitbox_component.enable()
		follow_component.disable()
		selectable_component.enable()
		grabbable_component.disable()
		# Re-enables grabbing if the cursor is still over the object
		selectable_component.query_hover()
		_handle_item(false)


func _on_health_changed(new_health: float, prev_health: float) -> void:
		# TODO
		pass


func _on_died() -> void:
	selectable_component.disable()
	if grabbable_component:
		grabbable_component.disable()
	if follow_component:
		follow_component.disable()
	if hitbox_component:
		hitbox_component.disable()
	
	if data.icon_disabled:
		sprite.texture = data.icon_disabled
