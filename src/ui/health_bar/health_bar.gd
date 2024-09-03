extends TextureProgressBar

@export_category("Components")
@export var health_component: HealthComponent

@onready var timer: Timer = $Timer
@onready var damage_bar: TextureProgressBar = $DamageBar


func _ready() -> void:
	init_health_ui(health_component.current_health)
	health_component.health_changed.connect(_on_health_changed)


func init_health_ui(_health) -> void:
	self.max_value = _health
	self.value = _health
	damage_bar.max_value = _health
	damage_bar.value = _health


func _on_health_changed(new_health: float, prev_health: float) -> void:
	self.value = new_health
	
	if new_health < prev_health:
		timer.start()
	else:
		damage_bar.value = new_health


func _on_timer_timeout():
	damage_bar.value = health_component.current_health
	
