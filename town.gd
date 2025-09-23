class_name Town extends Node2D

@onready var health_bar: ProgressBar = %HealthBar
@onready var fire_sprites: Node2D = %FireSprites

@export var max_health: int = 20
var is_on_fire: bool = false
var health: int

var death_manager

func _ready() -> void:
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health
	return
	
func take_damage(damage: int = 1) -> void:
	health -= damage
	health_bar.value = health
	
	if health <= max_health / 2:
		is_on_fire = true
	if health <= 0:
		die()
	return
	
func _process(_delta: float) -> void:
	fire_sprites.visible = is_on_fire

func die() -> void:
	death_manager.handle_death(self)
	
