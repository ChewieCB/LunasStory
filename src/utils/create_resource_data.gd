@tool
extends EditorScript
class_name CreateEntityResources


func create_entity_resources_from_assets(root_entity_dirpath: String) -> void:
	var normal_dir = DirAccess.open("%s/assets/normal/" % [root_entity_dirpath])
	var disabled_dir = DirAccess.open("%s/assets/disabled/" % [root_entity_dirpath])
	var hover_dir = DirAccess.open("%s/assets/hover/" % [root_entity_dirpath])
	
	var normal_files = Array(normal_dir.get_files())
	var disabled_files = Array(disabled_dir.get_files())
	var hover_files = Array(hover_dir.get_files())
	# Filter out any import files, we only want the actual resources
	for file_arr in [normal_files, disabled_files, hover_files]:
		file_arr = file_arr.filter(func(x): return not x.ends_with("import"))
	
	for idx in normal_files.size():
		var new_resource = IngredientData.new()
		new_resource.name = normal_files[idx]
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
