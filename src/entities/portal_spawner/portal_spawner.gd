@tool
extends Node2D
class_name PortalSpawner

signal init_state_ready
signal portal_opened(portal: PortalSpawner)
signal portal_closed(portal: PortalSpawner)
signal agent_spawned(agent: AIAgent, portal: PortalSpawner)
signal spawning_finished(portal: PortalSpawner)
signal spawn_limit_reached(portal: PortalSpawner)

@export_category("Nodes")
@export var anim_sprite: AnimatedSprite2D
@export var state_chart: StateChart
@export var spawn_timer: Timer

@export_category("Spawn Settings")
@export var spawns: Array[EnemySpawn]
@export var spawn_time: float = 2.0:
	set(value):
		spawn_time = value
		spawn_timer.wait_time = spawn_time
@export var max_spawns: int = -1
@export var agent_target: InteractibleObject
var current_spawns: int = 0


func _ready() -> void:
	add_to_group("spawner")


func open_portal() -> void:
	state_chart.send_event("open_portal")


func close_portal() -> void:
	state_chart.send_event("close_portal")


func activate() -> void:
	state_chart.send_event("enable")


func deactivate() -> void:
	state_chart.send_event("disable")


func spawn_agent(agent_type: PackedScene) -> AIAgent:
	var new_agent: AIAgent = agent_type.instantiate()
	get_parent().add_child(new_agent)
	new_agent.target_node = agent_target
	new_agent._spawn()
	emit_signal("agent_spawned", new_agent, self)
	return new_agent


## STATUS State logic
# A portal can be:
#   - idle - waiting to spawn the next enemy (particles anim)
#   - active - currently spawning an enemy (particles anim)
#   - disabled - finished spawning (no particles anim)
#   - TODO: telegraphing - indicating where a portal will spawn in the next wave

func _on_status_idle_state_entered() -> void:
	if anim_sprite.animation not in ["close", "default"]:
		anim_sprite.play("active")
	spawn_timer.start()


func _on_status_active_state_entered() -> void:
	spawn_timer.stop()
	
	if spawns and (max_spawns == -1 or current_spawns < max_spawns):
		
		# Select a random enemy type to spawn based on the spawn chance
		var spawn_roll: float = randf()
		var valid_spawns = spawns.filter(func(x): return spawn_roll <= x.spawn_chance)
		valid_spawns.sort_custom(
			func(a, b):
				if a.spawn_chance > b.spawn_chance:
					return true
				return false
		)
		var spawn_type = valid_spawns[0]
		
		var new_agent: AIAgent = await spawn_agent(spawn_type.enemy)
		await new_agent.spawned
		current_spawns += 1
		
		state_chart.send_event("finish_spawn")
	else:
		state_chart.send_event("disable")


func _on_status_disabled_state_entered() -> void:
	if anim_sprite.animation not in ["close", "default"]:
		anim_sprite.play("dormant")
	spawn_timer.stop()
	current_spawns = 0


## APERTURE State logic

func _on_open_state_entered() -> void:
	if anim_sprite.animation not in ["open"]:
		anim_sprite.play("open")
		await anim_sprite.animation_finished
	emit_signal("portal_opened", self)


func _on_closed_state_entered() -> void:
	if anim_sprite.animation not in ["default", "close"]:
		anim_sprite.play("close")
		await anim_sprite.animation_finished
	state_chart.send_event("disable_spawn")
	emit_signal("portal_closed", self)


func _on_spawn_timer_timeout() -> void:
	state_chart.send_event("start_spawn")
