extends InteractibleObject
class_name Gold

signal collected(value: int, global_pos: Vector2)

@export_category("Components")
@export var collectible_component: CollectibleComponent
@export var move_to_component: MoveTowardsComponent

@export var value: int
@export var gold_sprite_texures: Array[Texture]

@onready var anim_player: AnimationPlayer = $AnimationPlayer

var move_to_cursor: bool = false


func _ready() -> void:
	move_to_component.range_collider.set_deferred("disabled", true)
	collectible_component.disable()
	
	value = randi_range(1, 20)
	if randf() < 0.1:
		value += randi_range(10, 20)
	
	super()
	add_to_group("gold")
	
	# Disable collection until spawn anim is finished
	collectible_component.collected.connect(_collect)
	await _show()
	move_to_component.range_collider.set_deferred("disabled", false)
	collectible_component.enable()


func _show() -> bool:
	anim_player.play("spawn")
	await anim_player.animation_finished
	return true


func _hide() -> bool:
	anim_player.play("collect")
	await anim_player.animation_finished
	return true


func _set_sprite_texture() -> void:
	var texture_idx = int(remap(value, 0, 50, 0, gold_sprite_texures.size() - 1))
	sprite.texture = gold_sprite_texures[texture_idx]


func _collect() -> void:
	# TODO - add particles
	#var particles = particles_component.spawn_one_shot_particle()
	#add_child(particles)
	#particles.finished.connect(func(): 
		#remove_child(particles) 
		#particles.queue_free()
	#)
	#particles.emitting = true
	emit_signal("collected", value, self.global_position)
	collectible_component.disable()
	move_to_component.range_collider.set_deferred("disabled", true)
	CurrencyManager.add_gold(value)
	await _hide()
	# TODO - disable collision and implement object pooling instead of freeing this
	self.queue_free()
