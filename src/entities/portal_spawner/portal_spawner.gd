@tool
extends Node2D

signal portal_opened
signal portal_closed

@export_category("Nodes")
@export var anim_sprite: AnimatedSprite2D
@export var state_chart: StateChart
@export var spawn_timer: Timer

@export_category("Spawn Settings")
@export var spawn_type: PackedScene
@export var spawn_time: float = 1.0:
	set(value):
		spawn_time = value
		spawn_timer.wait_time = spawn_time

@export_category("Editor Debug")
@export var is_open: bool = false:
	set(value):
		var prev_value: bool = is_open
		is_open = value
		if prev_value != is_open:
			state_chart.send_event("open") if is_open else state_chart.send_event("close")
@export_enum("Dormant", "Active", "Extinct") var portal_state: String = "Dormant":
	set(value):
		var prev_state: String = portal_state
		portal_state = value
		
		if prev_state != portal_state:
			match portal_state:
				"Dormant":
					state_chart.send_event("deactivate")
				"Active":
					state_chart.send_event("activate")
			


func spawn_agent(agent_type: PackedScene = spawn_type) -> AIAgent:
	var new_agent: AIAgent = agent_type.instantiate()
	new_agent.global_position = self.global_position
	
	get_parent().add_child(new_agent)
	
	return new_agent


func open_portal() -> void:
	state_chart.send_event("open")


func close_portal() -> void:
	state_chart.send_event("close")


func activate() -> void:
	state_chart.send_event("activate")


func deactivate() -> void:
	state_chart.send_event("deactivate")


func _on_dormant_state_entered() -> void:
	if is_open:
		anim_sprite.play("dormant")
	state_chart.send_event("finish_spawn")

func _on_active_state_entered() -> void:
	if not is_open:
		state_chart.send_event("open")
	await portal_opened
	anim_sprite.play("active")

func _on_extinct_state_entered() -> void:
	state_chart.send_event("disable_spawn")


func _on_open_state_entered() -> void:
	is_open = true
	
	anim_sprite.play("open")
	await anim_sprite.animation_finished
	
	state_chart.send_event("finish_spawn")
	emit_signal("portal_opened")

func _on_closed_state_entered() -> void:
	is_open = false
	
	anim_sprite.play("close")
	await anim_sprite.animation_finished
	
	state_chart.send_event("disable_spawn")
	emit_signal("portal_closed")


func _on_spawner_idle_state_entered() -> void:
	spawn_timer.start()

func _on_spawner_spawning_state_entered() -> void:
	spawn_timer.stop()
	
	var new_agent: AIAgent = spawn_agent()
	await new_agent.ready
	
	state_chart.send_event("finish_spawn")

func _on_spawner_disabled_state_entered() -> void:
	spawn_timer.stop()


func _on_spawn_timer_timeout() -> void:
	state_chart.send_event("start_spawn")
