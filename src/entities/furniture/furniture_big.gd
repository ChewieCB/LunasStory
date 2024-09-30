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

@onready var sprite_size: Vector2 = Vector2(
	sprite.texture.get_width(),
	sprite.texture.get_height()
)
@onready var sprite_offset: Vector2 = sprite_size / 2
var sprite_tiles: Array[Vector2]

## DEBUG
var cell_rect_DEBUG: Rect2
var cell_rect_color_DEBUG: Color


func _ready() -> void:
	super()
	add_to_group("furniture_big")
	sprite_tiles = get_tiles_for_sprite(follow_component_tilemap)


func _draw() -> void:
	draw_rect(cell_rect_DEBUG, cell_rect_color_DEBUG)


func _process(delta: float) -> void:
	queue_redraw()


func get_tiles_for_sprite(tilemap: TileMapLayer) -> Array[Vector2]:
		var tile_size: Vector2 = follow_component_tilemap.tile_set.tile_size
		var x_tiles_per_sprite: int = sprite_size.x / tile_size.x
		var y_tiles_per_sprite: int = sprite_size.y / tile_size.y
		
		var tiles: Array[Vector2] = []
		for x_tile in range(x_tiles_per_sprite):
			for y_tile in range(y_tiles_per_sprite):
				tiles.append(Vector2(tile_size.x * x_tile, tile_size.y * y_tile))
		
		return tiles


func _on_pickup(entity: Node2D) -> void:
	super(entity)
	if entity == self:
		dynamic_nav_obstacle.remove_previous_obstacle()


func _on_drop(entity: Node2D) -> void:
	super(entity)
	if entity == self:
		dynamic_nav_obstacle.create_obstacle()
