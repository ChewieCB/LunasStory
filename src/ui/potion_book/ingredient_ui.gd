extends MarginContainer
class_name IngredientUIContainer

@export var data: IngredientData:
	set(value):
		data = value
		if not is_node_ready():
			await self.ready
		if data:
			icon.texture = data.icon

@onready var icon: TextureRect = $MarginContainer/HBoxContainer/MarginContainer/TextureRect
@onready var count_label: RichTextLabel = $MarginContainer/HBoxContainer/MarginContainer2/RichTextLabel


func set_label(current: int = 0, max: int = 0) -> String:
	if not is_node_ready():
		await self.ready
	var label_str = "[center]%s/%s[/center]" % [current, max]
	count_label.text = label_str
	return label_str


func set_icon_disabled(state: bool = true) -> void:
	if state == true:
		icon.texture = data.icon_disabled
	else:
		icon.texture = data.icon
