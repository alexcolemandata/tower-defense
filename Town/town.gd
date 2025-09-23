class_name Town extends Node2D

@onready var health_bar: ProgressBar = %HealthBar
@onready var fire_sprites: Node2D = %FireSprites
@onready var celebrate_sprites: Node2D = %CelebrateSprites
@onready var speech_bubble: Label = %SpeechBubble

@export var max_health: int = 20
var is_on_fire: bool = false
var health: int

var death_manager

func _ready() -> void:
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health
	
	speech_bubble.text = ""
	fire_sprites.visible = false
	celebrate_sprites.visible = false
	
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
	
func start_celebrating() -> void:
	speech_bubble.text = "Hooray, Hoorah!"
	celebrate_sprites.visible = true
	
func stop_celebrating() -> void:
	speech_bubble.text = ""
	celebrate_sprites.visible = false
	
	
