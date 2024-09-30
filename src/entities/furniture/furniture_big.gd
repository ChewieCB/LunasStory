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
var cell_rect_DEBUG: Rect2


func _ready() -> void:
	super()
	add_to_group("furniture_big")


func _draw() -> void:
	draw_rect(cell_rect_DEBUG, Color(Color.RED, 0.5))


func _process(delta: float) -> void:
	queue_redraw()


func _on_pickup(entity: Node2D) -> void:
	super(entity)
	if entity == self:
		dynamic_nav_obstacle.remove_previous_obstacle()


func _on_drop(entity: Node2D) -> void:
	super(entity)
	if entity == self:
		dynamic_nav_obstacle.create_obstacle()
