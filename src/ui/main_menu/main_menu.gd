extends Control

@export var level_scene: PackedScene

@onready var anim_player: AnimationPlayer = $AnimationPlayer


func _on_play_button_pressed() -> void:
	#anim_player.play("game_over_out")
	#await anim_player.animation_finished
	get_tree().change_scene_to_packed(level_scene)


func _on_quit_button_pressed() -> void:
	#anim_player.play("game_over_out")
	#await anim_player.animation_finished
	get_tree().quit()
