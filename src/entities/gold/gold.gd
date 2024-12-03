extends InteractibleObject
class_name Gold

signal collected(value: int)

@export_category("Components")
@export var collectible_component: CollectibleComponent
@export var move_to_component: MoveTowardsComponent

@export var value: int
@export var gold_sprite_texures: Array[Texture]

@onready var value_label: Label = $Label
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var move_to_cursor: bool = false


func _ready() -> void:
	value = randi_range(1, 30)
	if randf() < 0.3:
		value += randi_range(10, 20)
	value_label.text = str(value)
	
	super()
	add_to_group("gold")
	
	# Disable collection until spawn anim is finished
	move_to_component.range_collider.disabled = true
	collectible_component.collected.connect(_collect)
	await _show()
	move_to_component.range_collider.disabled = false


func _show() -> bool:
	anim_player.play("spawn")
	await anim_player.animation_finished
	await get_tree().create_timer(1.0).timeout
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
	collectible_component.disable()
	CurrencyManager.add_gold(value)
	await _hide()
	# TODO - disable collision and implement object pooling instead of freeing this
	self.queue_free()
