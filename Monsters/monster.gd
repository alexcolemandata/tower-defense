class_name Monster extends PathFollow2D

signal destroyed

const GOLD = preload("uid://ncncsppuo7x2")

@export var stats: MonsterStats = MonsterStats.new()

var destination_town: Town
var health: float
var is_dead: bool = false
var loot_handler

@onready var health_bar: ProgressBar = %HealthBar
@onready var speech_box: Label = %SpeechBox
@onready var sprite_2d: Sprite2D = %Sprite2D


func _ready() -> void:
	health_bar.max_value = stats.max_health
	health_bar.value = stats.max_health
	health = stats.max_health
	sprite_2d.texture = stats.sprite_texture


func _process(delta: float) -> void:
	if is_dead:
		return

	var movement = stats.speed_perc_per_sec * delta / 100.0
	if progress_ratio + movement >= 1.:
		attack_town()
	else:
		progress_ratio += stats.speed_perc_per_sec * delta / 100.0
		global_rotation = 0.


func attack_town() -> void:
	destination_town.take_damage()
	destroy()


func death_animation() -> void:
	sprite_2d.rotate(PI / 2.)
	speech_box.text = stats.death_speech

	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1., 1., 1., 0.), 2.0)
	await tween.finished
	destroy()
	return


func destroy() -> void:
	destroyed.emit()
	queue_free()
	return


func die() -> void:
	is_dead = true
	health_bar.visible = false

	if stats.sounds_death:
		AudioManager.play_sound_at_location(global_position, stats.sounds_death)

	spawn_loot()
	death_animation()
	return


func spawn_loot() -> void:
	var new_loot: Gold = GOLD.instantiate()
	new_loot.global_position = global_position + Vector2.from_angle(randf()) * 50.
	new_loot.money_value = stats.gold_on_death
	new_loot.z_index = 80
	new_loot.collected.connect(loot_handler.collect_loot)
	add_sibling(new_loot)


func take_damage(damage: float, from: Node2D) -> void:
	health -= damage
	health_bar.value = health
	if health <= 0:
		die()
		if from.has_method("gain_xp"):
			from.gain_xp(stats.xp_on_death)
