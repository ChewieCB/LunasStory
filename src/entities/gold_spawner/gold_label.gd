extends Node2D

@export var value: int

@onready var label: Label = $Label
@onready var anim_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	label.text = "+%s" % value
	anim_player.play("collect")
	await anim_player.animation_finished
	self.queue_free()
