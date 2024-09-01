extends Resource
class_name AttackResource

signal cooldown_started(_attack: AttackResource)
signal cooldown_ended(_attack: AttackResource)
signal cooldown_aborted(_attack: AttackResource)

enum TargetingMode {
	SINGLE,
	MULTIPLE,
	AREA,
}

@export_category("Targeting")
@export var targeting_mode: TargetingMode = TargetingMode.SINGLE
@export var max_targets: int = 1

@export_category("Stats")
@export var attack_range: int = 40
@export var attack_delay: float = 0.0
@export var cooldown: float = 1.0
@export var damage: int = 10
@export var armour_penetration: int = 0

@export_category("Display")
@export var name: String = "UNKNOWN"
@export var particle_size: int = 64
@export var attack_particle: ParticleResource
@export var attack_sfx: Array[AudioStream]
var _attack_sfx_full = []

var cooldown_timer: Timer:
	set(value):
		cooldown_timer = value
		cooldown_timer.wait_time = cooldown
		cooldown_timer.one_shot = true
		cooldown_timer.timeout.connect(_finish_cooldown)
var is_cooldown_aborted: bool = false


func _ready():
	randomize()
	_attack_sfx_full = attack_sfx.duplicate()
	_attack_sfx_full.shuffle()


func get_target_areas(attacker: AIAgent) -> Array[Area2D]:
	# Get target
	var areas_in_range = attacker.attack_range_hitbox_component.area_2d.get_overlapping_areas()
	
	if not areas_in_range:
		return []
	
	areas_in_range.sort_custom(
		func(a, b):
			if a.global_position.distance_to(attacker.global_position) < b.global_position.distance_to(attacker.global_position):
				return true
			return false
	)
	
	return areas_in_range
	
	## Sort again to prioritise targets
	#if attacker.priority_targets:
		#bodies_in_range.sort_custom(
			#func(a, b):
				#if a in attacker.priority_targets and b not in attacker.priority_targets:
					#return true
				#return false
		#)
	## Prioritise by enemy health
	#bodies_in_range.sort_custom(
		#func(a, b):
			## Both enemies at max health, prioritise the higher health one
			#if a.current_health == a.attributes.health and b.current_health == b.attributes.health:
				#if a.current_health > b.current_health:
					#return true
				#return false
			## If both or one enemies damaged, prioritise the lower health one
			##elif a.current_health < a.attributes.health and b.current_health < b.attributes.health:
			#else:
				#if a.current_health < b.current_health:
					#return true
				#return false
	#)
	#
	#match targeting_mode:
		#TargetingMode.SINGLE:
			#return [bodies_in_range.front()]
		#TargetingMode.MULTIPLE:
			#return bodies_in_range.slice(0, max_targets)
		#TargetingMode.AREA:
			#return bodies_in_range


func play_attack_sfx():
	pass
	#GameManager.play_sfx_shuffled(_attack_sfx_full, attack_sfx)


func play_block_sfx():
	pass
	#GameManager.play_sfx_shuffled(_block_sfx_full, block_sfx)


func start_cooldown() -> void:
	cooldown_timer.start()
	emit_signal("cooldown_started", self)


func abort_cooldown() -> void:
	emit_signal("cooldown_aborted", self)
	is_cooldown_aborted = true


func _finish_cooldown() -> void:
	emit_signal("cooldown_ended", self)
	is_cooldown_aborted = false
