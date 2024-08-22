extends BaseComponent
class_name CursorVisualComponent

@export var current_cursor: HandPosture:
	set(_cursor):
		if _cursor != current_cursor:
			set_hand_cursor_sprite(_cursor)
		current_cursor = _cursor

@export_category("Cursor Textures")
@export var open_tex: Texture
@export var pinch_tex: Texture
@export var point_tex: Texture
@export var grab_tex: Texture

@onready var sprite: Sprite2D = $Sprite2D

# Map each texture to the mouse cursor shapes on load and swap between them 
# at runtime via signals
enum HandPosture {OPEN, PINCH, POINT, GRAB}
var HAND_CURSORS: Array[Input.CursorShape] = [
	Input.CursorShape.CURSOR_ARROW, 
	Input.CursorShape.CURSOR_CAN_DROP, 
	Input.CursorShape.CURSOR_POINTING_HAND, 
	Input.CursorShape.CURSOR_DRAG
]
var HAND_HOTSPOTS: Array[Vector2] = [
	Vector2(6, 8),
	Vector2(8, 15),
	Vector2(9, 6),
	Vector2(10, 15)
]
@onready var HAND_TEXTURES: Array[Texture] = [
	open_tex,
	pinch_tex,
	point_tex,
	grab_tex
]


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	set_hand_cursor_sprite(HandPosture.OPEN)


func set_hand_cursor_sprite(posture: HandPosture) -> void:
	sprite.texture = HAND_TEXTURES[posture]


func set_hand_cursor_mouse(posture: HandPosture) -> void:
	Input.set_custom_mouse_cursor(HAND_TEXTURES[posture])#, 0, Vector2(6, 8)) # HAND_HOTSPOTS[posture])
