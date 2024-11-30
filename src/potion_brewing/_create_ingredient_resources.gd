@tool
extends CreateEntityResources


func _run() -> void:
	create_entity_resources_from_assets("res://src/entities/ingredients")
