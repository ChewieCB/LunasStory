extends Node


func create_ingredient_resources() -> void:
	var normal_dir = DirAccess.open("res://src/entities/ingredients/assets/normal/")
	var disabled_dir = DirAccess.open("res://src/entities/ingredients/assets/disabled/")
	var hover_dir = DirAccess.open("res://src/entities/ingredients/assets/hover/")
	var normal_files = Array(normal_dir.get_files())
	normal_files = normal_files.filter(func(x): return not x.ends_with("import"))
	var disabled_files = Array(disabled_dir.get_files())
	disabled_files = disabled_files.filter(func(x): return not x.ends_with("import"))
	var hover_files = Array(hover_dir.get_files())
	hover_files = hover_files.filter(func(x): return not x.ends_with("import"))
	for idx in normal_files.size():
		var new_resource = IngredientData.new()
		new_resource.name = normal_files[idx]
		new_resource.icon = load("res://src/entities/ingredients/assets/normal/" + normal_files[idx])
		new_resource.icon_disabled = load("res://src/entities/ingredients/assets/disabled/" + disabled_files[idx])
		new_resource.icon_hover = load("res://src/entities/ingredients/assets/hover/" + hover_files[idx])
		var save_result = ResourceSaver.save(new_resource, "res://src/entities/ingredients/resources/" + normal_files[idx].trim_suffix(".png") + ".tres")
		if save_result != OK:
			print(save_result)
