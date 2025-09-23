class_name Monster extends PathFollow2D

const GOLD = preload("uid://ncncsppuo7x2")

@onready var health_bar: ProgressBar = %HealthBar
@onready var speech_box: Label = %SpeechBox

@export var percent_per_second: float = 5.0
@export var max_health: float = 10.0
@export var xp_on_death: int = 10
@export var gold_on_death: int = 5

var health: float = max_health
var is_dead: bool = false

var destination_town: Town
var loot_handler

signal destroyed

func _ready() -> void:
	health_bar.max_value = max_health
	health_bar.value = health
	
func _process(delta: float) -> void:
	if is_dead:
		return
	
	var movement = percent_per_second * delta / 100.0
	if progress_ratio + movement >= 1.:
		attack_town()
	else:
		progress_ratio += percent_per_second * delta / 100.0
		global_rotation = 0.
		
func attack_town() -> void:
	destination_town.take_damage()
	die()

func take_damage(damage: float, from: Node2D) -> void:
	health -= damage
	health_bar.value = health
	if health <= 0:
		die()
		if from.has_method("gain_xp"):
			from.gain_xp(xp_on_death)
		
func die() -> void:
	is_dead = true
	health_bar.visible = false
	speech_box.text = "I'm Slain!"
	spawn_loot()
	await get_tree().create_timer(2).timeout
	destroyed.emit()
	queue_free()
	
func spawn_loot() -> void:
	var new_loot: Gold = GOLD.instantiate()
	new_loot.global_position = global_position
	new_loot.money_value = gold_on_death
	new_loot.z_index = 80
	new_loot.collected.connect(loot_handler.collect_loot)
	add_sibling(new_loot)
