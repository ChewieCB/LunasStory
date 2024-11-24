extends InteractibleObject
class_name Ingredient

@export_category("Components")
@export var consumable_component: ConsumableComponent

@export var decay_time: float = 8.0

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var decay_timer: Timer = $DecayTimer


func _ready() -> void:
	super()
	add_to_group("ingredients")
	anim_player.play("spawn")
	await anim_player.animation_finished
	decay_timer.start(decay_time)


func decay() -> void:
	decay_timer.stop()
	anim_player.play("decay")
	await anim_player.animation_finished
	queue_free()

func _on_drop(entity: Node2D) -> void:
	super(entity)
	if entity == self:
		consumable_component.can_be_consumed()


func _on_decay_timer_timeout() -> void:
	decay()
