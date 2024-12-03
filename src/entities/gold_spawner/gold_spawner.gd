extends EntitySpawner
class_name GoldSpawner

@export var wave_manager: WaveManager
@export var value_label_scene: PackedScene


func _ready() -> void:
	wave_manager.enemy_killed.connect(_on_enemy_killed)


func spawn_gold_around_pos(pos: Vector2) -> InteractibleObject:
	var entity = entity_scene.instantiate()
	#var spawn_pos = get_new_spawn(pos)
	
	entity.global_position = pos
	entity.follow_target = hand_cursor
	entity.collected.connect(_on_gold_collected)
	
	return entity


func get_new_spawn(pos: Vector2) -> Vector2:
	var floor_tiles = _get_floor_tiles()
	floor_tiles.duplicate()
	floor_tiles.sort_custom(
		func(a, b):
			if a.distance_to(pos) > b.distance_to(pos):
				return true
			return false
	)
	
	var nearest_tiles = floor_tiles.slice(0, 2)
	nearest_tiles.shuffle()
	
	return nearest_tiles.pop_front()


func _on_enemy_killed(enemy: AIAgent) -> void:
	var new_gold = spawn_gold_around_pos(enemy.global_position)
	call_deferred("add_child", new_gold)


func _on_gold_collected(value: int, global_pos: Vector2) -> void:
	var value_label = value_label_scene.instantiate()
	value_label.global_position = global_pos
	value_label.value = value
	add_child(value_label)
