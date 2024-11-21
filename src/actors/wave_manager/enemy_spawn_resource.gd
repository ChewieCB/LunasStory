extends Resource
class_name EnemySpawn

@export var enemy: PackedScene
@export_range(0.1, 1.0) var spawn_chance: float
@export var spawn_cost: float = 1.0
