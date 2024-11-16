extends Node
class_name WaveManager

@export var waves: Array[Wave]
@export var portal_parent: Node2D
@export var portal_scene: PackedScene
var active_portals: Array = []
var active_enemies: Array = []
var current_wave: Wave
var valid_portal_spawns: Array
var last_portal_spawn: Marker2D


func _ready() -> void:
	valid_portal_spawns = portal_parent.get_children()
	if waves:
		start_wave()


func next_wave() -> Wave:
	return waves.pop_front()


func start_wave(wave: Wave = next_wave()) -> void:
	if current_wave:
		end_wave(current_wave)
	
	active_portals = spawn_portals(wave.num_portals, wave.portal_max_spawns, wave.spawn_delay)
	#get_parent().state_debugger.debug_node(active_portals.front().state_chart)
	activate_portals(active_portals)
	
	current_wave = wave


func end_wave(wave: Wave) -> void:
	deactivate_portals(active_portals)
	await get_tree().create_timer(0.5).timeout
	clear_portals(active_portals)
	current_wave = null
	await get_tree().create_timer(1.5).timeout
	start_wave()


func clear_portals(portals: Array) -> void:
	deactivate_portals(portals)
	for portal in portals:
		portal.get_parent().remove_child(portal)
		portal.queue_free()
	
	valid_portal_spawns = portal_parent.get_children()


func spawn_portals(count: int, max_spawns: int, spawn_time: float) -> Array:
	var portals = []
	
	for i in count:
		var _portal = portal_scene.instantiate()
		_portal.max_spawns = max_spawns
		_portal.spawn_time = spawn_time
		_portal.is_open = true
		_portal.portal_state = "Active"
		
		var portal_spawn = get_portal_spawn()
		if not portal_spawn:
			return portals
		portal_spawn.add_child(_portal)
		
		_portal.spawning_finished.connect(_on_portal_finished)
		_portal.agent_spawned.connect(_on_enemy_spawned)
		
		portals.append(_portal)
	
	return portals


func get_portal_spawn() -> Marker2D:
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


func activate_portals(portals: Array) -> bool:
	for portal in portals:
		await _activate_portal(portal)
	return true


func deactivate_portals(portals: Array) -> bool:
	for portal in portals:
		await _deactivate_portal(portal)
	return true


func _activate_portal(portal: PortalSpawner) -> bool:
	if not portal.is_node_ready():
		await portal.ready
	portal.open_portal()
	return await portal.activate()


func _deactivate_portal(portal: PortalSpawner) -> bool:
	if not portal.is_node_ready():
		await portal.ready
	portal.close_portal()
	return await  portal.deactivate()


func _on_portal_finished(portal: PortalSpawner) -> void:
	valid_portal_spawns.erase(portal)
	#if valid_portal_spawns == []:
		#end_wave(current_wave)


func _on_enemy_spawned(enemy: AIAgent, _portal: PortalSpawner) -> void:
	active_enemies.append(enemy)
	enemy.health_component.died.connect(_remove_enemy.bind(enemy))


func _remove_enemy(enemy: AIAgent) -> void:
	active_enemies.erase(enemy)
	if active_enemies == []:
		end_wave(current_wave)
