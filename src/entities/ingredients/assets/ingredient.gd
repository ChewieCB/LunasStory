extends InteractibleObject
class_name Ingredient

signal decayed(ingredient: Ingredient)
signal consumed(ingredient: Ingredient)

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
	emit_signal("decayed", self)
	queue_free()


func _on_hover(entity: Node2D, state: bool) -> void:
	super(entity, state)
	if state == true:
		decay_timer.stop()
	else:
		decay_timer.start(decay_time)


func _on_drop(entity: Node2D) -> void:
	super(entity)
	if entity == self:
		if await consumable_component.can_be_consumed():
			emit_signal("consumed", self)


func _on_died() -> void:
	super()
	decay()


func _on_decay_timer_timeout() -> void:
	decay()
