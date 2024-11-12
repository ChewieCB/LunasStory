extends Control

@export var health_component: HealthComponent

@onready var anim_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	if health_component:
		health_component.died.connect(game_over)


func game_over() -> void:
	for node in get_tree().get_nodes_in_group("selectable"):
		node.disable()
	for node in get_tree().get_nodes_in_group("grabbable"):
		node.disable()
	
	anim_player.play("game_over_in")
	await anim_player.animation_finished


func _on_restart_button_pressed() -> void:
	anim_player.play("game_over_out")
	await anim_player.animation_finished
	get_tree().reload_current_scene()


func _on_quit_button_pressed() -> void:
	anim_player.play("game_over_out")
	await anim_player.animation_finished
	get_tree().quit()
