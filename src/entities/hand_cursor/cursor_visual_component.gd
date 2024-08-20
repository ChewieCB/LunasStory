extends BaseComponent
class_name CursorVisualComponent

@export var current_cursor: HandPosture:
	set(_cursor):
		if _cursor != current_cursor:
			set_hand_cursor(_cursor)
		current_cursor = _cursor

@export_category("Cursor Textures")
@export var open_tex: Texture
@export var pinch_tex: Texture
@export var point_tex: Texture
@export var grab_tex: Texture

# Map each texture to the mouse cursor shapes on load and swap between them 
# at runtime via signals
enum HandPosture {OPEN, PINCH, POINT, GRAB}
var HAND_CURSORS: Array[Input.CursorShape] = [
	Input.CursorShape.CURSOR_ARROW, 
	Input.CursorShape.CURSOR_CAN_DROP, 
	Input.CursorShape.CURSOR_POINTING_HAND, 
	Input.CursorShape.CURSOR_DRAG
]
@onready var HAND_TEXTURES: Array[Texture] = [
	open_tex,
	pinch_tex,
	point_tex,
	grab_tex
]


func _ready() -> void:
	set_hand_cursor(HandPosture.OPEN)


func set_hand_cursor(posture: HandPosture) -> void:
	Input.set_custom_mouse_cursor(HAND_TEXTURES[posture])
