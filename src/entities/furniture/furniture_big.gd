extends InteractibleObject
# TODO - extend new class for PlaceableObjects that update navs
class_name FurnitureBig

@export_category("Components")
@export var dynamic_nav_obstacle: DynamicNavObstacleComponent
@export var particles_component: ParticlesComponent

@export var follow_component_tilemap: TileMapLayer:
	set(value):
		follow_component_tilemap = value
		follow_component.tilemap = follow_component_tilemap

var sprite_offset: Vector2
var sprite_tiles: Array[Vector2]

@export var debug_placement_collider: bool = false

@onready var state_chart: StateChart =  $StateChart

var spawn_movement_target: Marker2D


func _ready() -> void:
	super()
	add_to_group("furniture_big")
	sprite_offset = data.sprite_offset
	sprite_tiles = get_tiles_for_sprite(follow_component_tilemap)
	follow_component.valid_placement_location.connect(_hide_invalid_placement)
	follow_component.invalid_placement_location.connect(_show_invalid_placement)
	follow_component.was_disabled.connect(_hide_invalid_placement)
	hitbox_component.collider.shape.size = data.sprite_size


func _draw() -> void:
	for tile in follow_component.invalid_tiles:
		var tile_local = tile - sprite_offset
		draw_rect(
			Rect2(tile_local, follow_component.tilemap.tile_set.tile_size), 
			Color.RED,
		)
	for tile in follow_component.blocked_tiles:
		var tile_local = tile + sprite_offset
		draw_rect(
			Rect2(tile_local, follow_component.tilemap.tile_set.tile_size), 
			Color.ORANGE,
		)
	#if follow_component.debug_collision_check:
		#draw_rect(
			#follow_component.debug_collision_check,
			#Color(Color.DARK_ORANGE, 0.6),
		#)


func _process(_delta: float) -> void:
	queue_redraw()


func _physics_process(_delta: float) -> void:
	if spawn_movement_target:
		self.global_position = spawn_movement_target.global_position


func get_tiles_for_sprite(tilemap: TileMapLayer) -> Array[Vector2]:
		var tile_size: Vector2 = follow_component_tilemap.tile_set.tile_size
		var x_tiles_per_sprite: int = data.sprite_size.x / tile_size.x
		var y_tiles_per_sprite: int = data.sprite_size.y / tile_size.y
		
		var tiles: Array[Vector2] = []
		for x_tile in range(x_tiles_per_sprite):
			for y_tile in range(y_tiles_per_sprite):
				tiles.append(Vector2(tile_size.x * x_tile, tile_size.y * y_tile))
		
		return tiles


func enable_preview() -> void:
	state_chart.send_event("preview")


func _show_invalid_placement() -> void:
	sprite.modulate = Color.RED


func _hide_invalid_placement() -> void:
	sprite.modulate = Color(1, 1, 1, 1)


func _on_pickup(entity: Node2D) -> void:
	super(entity)
	if entity == self:
		dynamic_nav_obstacle.remove_previous_obstacle()


func _on_drop(entity: Node2D) -> void:
	super(entity)
	if entity == self:
		dynamic_nav_obstacle.create_obstacle()
		follow_component.invalid_tiles = []
		follow_component.blocked_tiles = []


func _on_placement_preview_state_entered() -> void:
	sprite.modulate = Color(Color.GREEN, 0.5)
	selectable_component.disable()
	grabbable_component.disable()
	hitbox_component.disable()
	follow_component.enable()


func _on_placement_preview_state_exited() -> void:
	sprite.modulate = Color.WHITE
	selectable_component.enable()
	grabbable_component.enable()
	hitbox_component.enable()
	follow_component.disable()


func _on_placement_preview_state_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		state_chart.send_event("drop")
		state_chart.send_event("place_furniture")
