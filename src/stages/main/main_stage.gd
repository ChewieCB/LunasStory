extends Node2D

@export var state_debugger: Control

var is_debugger_attached: bool = false


func _ready() -> void:
	for portal in get_tree().get_nodes_in_group("spawner"):
		portal.agent_spawned.connect(_on_agent_spawn)


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()


func _on_agent_spawn(agent: AIAgent, portal: PortalSpawner) -> void:
	if not is_debugger_attached:
		state_debugger.debug_node(agent.state_chart)
		is_debugger_attached = true
