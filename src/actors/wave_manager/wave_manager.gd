extends Node
class_name WaveManager

@export var waves: Array[Wave]
@export var portal_parent: Node2D
@export var portal_scene: PackedScene
@export var ingredient_spawner: IngredientSpawner
@export var brewing_manager: BrewingManager
var active_portals: Array = []
var active_enemies: Array = []
var current_wave: Wave
var valid_portal_spawns: Array
var last_portal_spawn: Marker2D


func _ready() -> void:
	valid_portal_spawns = portal_parent.get_children()
	brewing_manager.recipe_completed.connect(_on_recipe_completed)
	if waves:
		start_wave()


func next_wave() -> Wave:
	return waves.pop_front()


func start_wave(wave: Wave = next_wave()) -> void:
	if current_wave:
		end_wave(current_wave)
	
	if wave:
		active_portals = spawn_portals(wave.num_portals, wave.portal_max_spawns, wave.spawn_delay)
		#get_parent().state_debugger.debug_node(active_portals.front().state_chart)
		await get_tree().create_timer(1.5).timeout
		activate_portals(active_portals)
		ingredient_spawner.set_active_ingredients()
		ingredient_spawner.start_spawning()
		
		current_wave = wave


func end_wave(wave: Wave = current_wave) -> void:
	clear_portals(active_portals)
	current_wave = null
	ingredient_spawner.stop_spawning()
	#ingredient_spawner.clear_all_ingredients()
	
	await get_tree().create_timer(1.5).timeout
	start_wave()


func spawn_portals(count: int, max_spawns: int, spawn_time: float) -> Array:
	var portals = []
	
	for i in count:
		var _portal = portal_scene.instantiate()
		_portal.max_spawns = max_spawns
		_portal.spawn_time = spawn_time
		
		var portal_spawn = _get_portal_spawn()
		if not portal_spawn:
			return portals
		portal_spawn.add_child(_portal)
		
		_portal.spawning_finished.connect(_on_portal_finished)
		_portal.agent_spawned.connect(_on_enemy_spawned)
		
		portals.append(_portal)
	
	return portals


func activate_portals(portals: Array) -> void:
	for portal in portals:
		_activate_portal(portal)


func deactivate_portals(portals: Array) -> void:
	for portal in portals:
		_deactivate_portal(portal)
		await portal.portal_closed


func clear_portals(portals: Array) -> void:
	deactivate_portals(portals)
	valid_portal_spawns = portal_parent.get_children()


func _free_portal(portal: PortalSpawner) -> void:
	portal.queue_free()


func _get_portal_spawn() -> Marker2D:
	var spawns = valid_portal_spawns
	if last_portal_spawn:
		spawns.sort_custom(
			func(a, b):
				return a.global_position.distance_to(last_portal_spawn.global_position) \
				> b.global_position.distance_to(last_portal_spawn.global_position)
		)
	else:
		spawns.shuffle()
	
	var new_spawn = spawns.pop_front()
	last_portal_spawn = new_spawn
	
	return new_spawn


func _activate_portal(portal: PortalSpawner) -> void:
	if not portal.is_node_ready():
		await portal.ready
	portal.open_portal()
	await portal.portal_opened
	portal.activate()


func _deactivate_portal(portal: PortalSpawner) -> void:
	if not portal.is_node_ready():
		await portal.ready
	portal.deactivate()
	portal.close_portal()


func _on_portal_finished(portal: PortalSpawner) -> void:
	valid_portal_spawns.erase(portal)
	_free_portal(portal)


func _on_enemy_spawned(enemy: AIAgent, _portal: PortalSpawner) -> void:
	active_enemies.append(enemy)
	enemy.health_component.died.connect(_remove_enemy.bind(enemy))


func _remove_enemy(enemy: AIAgent) -> void:
	active_enemies.erase(enemy)
	#if active_enemies == []:
		#end_wave(current_wave)


func _on_recipe_completed(_recipe: PotionRecipe) -> void:
	end_wave()
