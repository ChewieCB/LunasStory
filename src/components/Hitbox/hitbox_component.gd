extends BaseComponent
class_name HitboxComponent

@onready var entity: Node2D = get_parent()
@onready var area_2d: Area2D = $Area2D
@onready var collider: CollisionShape2D = $Area2D/CollisionShape2D

signal area_entered(area: Area2D)
signal area_exited(area: Area2D)


func _ready() -> void:
	was_disabled.connect(_set_collision_state.bind(false))
	was_enabled.connect(_set_collision_state.bind(true))


func _set_collision_state(state: bool) -> void:
	area_2d.monitoring = state
	area_2d.monitorable = state
	print_rich(
		"%s.%s %s" % [
			entity.name, self.name, 
			("[color=green]enabled[/color]" if state else "[color=red]disabled[/color]")
			]
	)


func check_in_area(area: Area2D) -> bool:
	await get_tree().physics_frame
	await get_tree().physics_frame
	if area_2d.overlaps_area(area):
		print("%s overlaps %s" % [area_2d.get_parent().get_parent().name, area.get_parent().get_parent().name])
		return true
	print("%s does not overlap %s" % [area_2d.get_parent().get_parent().name, area.get_parent().get_parent().name])
	return false


func get_target() -> Node2D:
	var targets = area_2d.get_overlapping_areas()
	
	var target_nodes = targets.map(func(element): return element.owner)
	# Remove any duplicates
	var unique_targets: Array = []
	for node in target_nodes:
		if not unique_targets.has(node):
			unique_targets.append(node)
	# Remove any freed nodes
	unique_targets = unique_targets.filter(func(target): return is_instance_valid(target))
	# Split by type
	var cauldron_targets = unique_targets.filter(func(target): return target is Cauldron)
	var ingredient_targets = unique_targets.filter(func(target): return target is Ingredient)
	# Sort closest
	#targets.sort_custom(func(a, b):
		#if a.global_position.distance_to(self.global_position)\
		 #< b.global_position.distance_to(self.global_position):
			#return true
		#return false
	#)
	var weighted_targets = cauldron_targets + ingredient_targets
	if weighted_targets:
		return weighted_targets[0]
	return null


func _on_area_2d_area_entered(area: Area2D) -> void:
	if is_instance_valid(area.owner):
		print_rich(
			"%s.%s [color=green]entered[/color] %s.%s area" % [
				area.owner.name, area.get_parent().name, 
				get_parent().name, self.name
			]
		)
		emit_signal("area_entered", area)


func _on_area_2d_area_exited(area: Area2D) -> void:
	if is_instance_valid(area.owner):
		print_rich(
			"%s.%s [color=red]exited[/color] %s.%s area" % [
				area.owner.name, area.get_parent().name, 
				get_parent().name, self.name
			]
		)
		emit_signal("area_exited", area)
