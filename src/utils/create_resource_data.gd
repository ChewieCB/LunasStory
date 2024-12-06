@tool
extends EditorScript
class_name CreateEntityResources


func create_entity_resources_from_assets(root_entity_dirpath: String, data_type_str: String = "") -> void:
	var normal_dir = DirAccess.open("%s/assets/normal/" % [root_entity_dirpath])
	var disabled_dir = DirAccess.open("%s/assets/disabled/" % [root_entity_dirpath])
	var hover_dir = DirAccess.open("%s/assets/hover/" % [root_entity_dirpath])
	
	var normal_files = Array(normal_dir.get_files()).filter(func(x): return not x.ends_with("import"))
	var disabled_files = Array(disabled_dir.get_files()).filter(func(x): return not x.ends_with("import"))
	var hover_files = Array(hover_dir.get_files()).filter(func(x): return not x.ends_with("import"))
	
	for idx in normal_files.size():
		var new_resource
		match data_type_str:
			"FurnitureData":
				new_resource = FurnitureData.new()
			"IngredientData":
				new_resource = IngredientData.new()
			"_":
				new_resource = Data.new()
		
		var filename = normal_files[idx]
		var resource_name = filename.split(":")[-1] \
			.trim_suffix(".png") \
			.capitalize()
		new_resource.name = resource_name
		
		new_resource.icon = load(
			"%s/assets/normal/%s" % [root_entity_dirpath, normal_files[idx]]
		)
		new_resource.icon_disabled = load(
			"%s/assets/disabled/%s" % [root_entity_dirpath, disabled_files[idx]]
		)
		new_resource.icon_hover = load(
			"%s/assets/hover/%s" % [root_entity_dirpath, hover_files[idx]]
		)
		
		var save_result = ResourceSaver.save(
			new_resource,
			"%s/resources/%s.tres" % [root_entity_dirpath, normal_files[idx].trim_suffix(".png")]
		)
		
		if save_result != OK:
			push_error(save_result)
