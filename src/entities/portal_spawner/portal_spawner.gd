@tool
extends Node2D
class_name PortalSpawner

signal portal_opened
signal portal_closed
signal agent_spawned(agent: AIAgent, portal: PortalSpawner)

@export_category("Nodes")
@export var anim_sprite: AnimatedSprite2D
@export var state_chart: StateChart
@export var spawn_timer: Timer

@export_category("Spawn Settings")
@export var spawn_type: PackedScene
@export var spawn_time: float = 2.0:
	set(value):
		spawn_time = value
		spawn_timer.wait_time = spawn_time
@export var max_spawns: int = -1
var current_spawns: int = 0

@export_category("Editor Debug")
@export var is_open: bool = false:
	set(value):
		if not is_node_ready():
			await ready
			await get_tree().process_frame
		
		var prev_value: bool = is_open
		is_open = value
		
		if prev_value != is_open:
			open_portal() if is_open else close_portal()
@export_enum("Dormant", "Active", "Extinct") var portal_state: String = "Dormant":
	set(value):
		if not is_node_ready():
			await ready
			await get_tree().process_frame
		
		var prev_state: String = portal_state
		portal_state = value
		
		if prev_state != portal_state:
			match portal_state:
				"Dormant":
					deactivate()
				"Active":
					activate()


func spawn_agent(agent_type: PackedScene = spawn_type) -> AIAgent:
	var new_agent: AIAgent = agent_type.instantiate()
	new_agent.global_position = self.global_position
	
	get_parent().add_child(new_agent)
	
	emit_signal("agent_spawned", new_agent, self)
	return new_agent

## DEBUG
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		is_open = !is_open
	elif Input.is_action_just_pressed("ui_cancel"):
		if portal_state == "Dormant":
			portal_state = "Active"
		elif portal_state == "Active":
			portal_state = "Dormant"


func open_portal() -> void:
	state_chart.send_event("open_portal")


func close_portal() -> void:
	state_chart.send_event("close_portal")


func activate() -> void:
	state_chart.send_event("activate")


func deactivate() -> void:
	state_chart.send_event("deactivate")


func _on_dormant_state_entered() -> void:
	if is_open:
		anim_sprite.play("dormant")
	state_chart.send_event("disable_spawn")

func _on_dormant_event_received(event: StringName) -> void:
	match event:
		"open_portal":
			await anim_sprite.animation_finished
			anim_sprite.play("dormant")

func _on_active_state_entered() -> void:
	if not is_open:
		is_open = true
		await portal_opened
	
	anim_sprite.play("active")
	state_chart.send_event("finish_spawn")

func _on_active_event_received(event: StringName) -> void:
	match event:
		"open_portal":
			await anim_sprite.animation_finished
			anim_sprite.play("active")

func _on_extinct_state_entered() -> void:
	state_chart.send_event("disable_spawn")


func _on_open_state_entered() -> void:
	anim_sprite.play("open")
	await anim_sprite.animation_finished
	emit_signal("portal_opened")

func _on_closed_state_entered() -> void:
	anim_sprite.play("close")
	await anim_sprite.animation_finished
	state_chart.send_event("disable_spawn")
	emit_signal("portal_closed")


func _on_spawner_idle_state_entered() -> void:
	spawn_timer.start()

func _on_spawner_spawning_state_entered() -> void:
	spawn_timer.stop()
	
	if spawn_type and (max_spawns == -1 or current_spawns < max_spawns):
		var new_agent: AIAgent = spawn_agent()
		await new_agent.spawned
		
		current_spawns += 1
		
		state_chart.send_event("finish_spawn")
	else:
		state_chart.send_event("disable_spawn")

func _on_spawner_disabled_state_entered() -> void:
	spawn_timer.stop()
	current_spawns = 0


func _on_spawn_timer_timeout() -> void:
	state_chart.send_event("start_spawn")
