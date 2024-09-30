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

var local_pos_DEBUG: Vector2
var cell_local_pos_DEBUG: Vector2
var cell_global_pos_DEBUG: Vector2
var cell_rect_DEBUG: Rect2


func _ready() -> void:
	super()
	add_to_group("furniture_big")


func _draw() -> void:
	draw_circle(local_pos_DEBUG, 1.0, Color.ORANGE)
	draw_circle(cell_local_pos_DEBUG, 1.0, Color.YELLOW)
	draw_circle(cell_global_pos_DEBUG, 1.0, Color.GREEN)
	draw_rect(cell_rect_DEBUG, Color(Color.RED), 0.5)


func _process(_delta: float) -> void:
	queue_redraw()


func _on_pickup(entity: Node2D) -> void:
	super(entity)
	if entity == self:
		dynamic_nav_obstacle.remove_previous_obstacle()


func _on_drop(entity: Node2D) -> void:
	super(entity)
	if entity == self:
		dynamic_nav_obstacle.create_obstacle()
