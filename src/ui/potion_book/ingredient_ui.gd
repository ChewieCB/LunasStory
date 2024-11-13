extends MarginContainer

@onready var ingredient_texture: TextureRect = $HBoxContainer/MarginContainer/TextureRect
@onready var ingredient_count_label: RichTextLabel = $HBoxContainer/MarginContainer2/RichTextLabel


func set_label(current: int = 0, max: int = 0) -> String:
	var label_str = "[center]%s/%s[/center]" % [current, max]
	ingredient_count_label.text = label_str
	return label_str
