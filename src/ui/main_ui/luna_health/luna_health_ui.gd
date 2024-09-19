extends Control

@export var health_component: HealthComponent
@export var damage_portrait_texures: Array[Texture]

@onready var health_bar: TextureProgressBar = $PortraitMargin/HealthBar
@onready var portrait: TextureRect = $PortraitMargin/Portrait


func _ready() -> void:
	if health_component:
		health_component.health_changed.connect(_on_health_changed)
		health_bar.health_component = health_component
		portrait.texture = damage_portrait_texures[0]


func _on_health_changed(new_health: float, prev_health: float) -> void:
	if new_health > 0:
		var portrait_idx: int = remap(
			new_health, 
			health_component.max_health, 0,
			0, damage_portrait_texures.size()
		)
		portrait.texture = damage_portrait_texures[portrait_idx]
		print("Portrait idx = %s at %s health" % [portrait_idx, new_health])
