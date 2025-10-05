class_name Town extends Node2D

@export var max_health: int = 20
@export var town_sprite_parts: TownSpriteParts

var death_manager
var health: int

@onready var health_bar: ProgressBar = %HealthBar
@onready var speech_bubble: Label = %SpeechBubble


func _ready() -> void:
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health

	speech_bubble.text = ""

	return

func die() -> void:
	death_manager.handle_death(self)


func start_celebrating() -> void:
	AudioManager.play_sound_at_location(
		global_position,
		AudioManager.sounds.town_celebrate,
	)
	speech_bubble.text = "Hooray, Hoorah!"


func take_damage(damage: int = 1) -> void:
	AudioManager.play_sound_at_location(global_position, AudioManager.sounds.town_ouch)
	health -= damage
	health_bar.value = health
	town_sprite_parts.hp_ratio = health / (max_health as float)
	
	if health <= 0:
		die()
	return
