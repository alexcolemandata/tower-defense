class_name Monster extends PathFollow2D

signal destroyed

const GOLD = preload("uid://ncncsppuo7x2")
const XP_GEM = preload("uid://b6illm4ixruiy")

@export var stats: MonsterStats = MonsterStats.new()

var destination_town: Town
var health: float
var loot_handler
var slow_amount: float = 0.0

@onready var health_bar: ProgressBar = %HealthBar
@onready var speech_box: Label = %SpeechBox
@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

enum State { SPAWNING, ACTIVE, DEAD }

enum MonsterVariation { LOLLY_GAGGER, NINJA, ZOMBIE }

const VARIATION_LOOKUP: Dictionary[MonsterVariation, MonsterStats] = {
	MonsterVariation.LOLLY_GAGGER: preload("uid://bd2fp73xxonbw"),
	MonsterVariation.NINJA: preload("uid://cbublyn32ri4m"),
	MonsterVariation.ZOMBIE: preload("uid://dob1w53owrhg4"),
}

var state = State.SPAWNING

const INVUL_TIME_S: float = 0.8
var invul_time: float = 0


func _ready() -> void:
	health_bar.max_value = stats.max_health
	health_bar.value = stats.max_health
	health = stats.max_health
	sprite_2d.texture = stats.sprite_texture
	modulate.a = 0.5
	animation_player.current_animation = "idle"


func _process(delta: float) -> void:
	if state == State.DEAD:
		return

	if state == State.SPAWNING:
		invul_time += delta
		if invul_time >= INVUL_TIME_S:
			state = State.ACTIVE
			modulate.a = 1.0

	var movement = get_movement(delta)
	if progress_ratio + movement >= 1:
		attack_town()
	else:
		progress_ratio += movement
		global_rotation = 0

	return


func get_movement(delta: float) -> float:
	return stats.speed_perc_per_sec * (1.0 - clamp(slow_amount, 0.0, 1.0)) * delta / 100.0


func apply_slow(slow_factor: float) -> void:
	slow_amount += slow_factor
	var tween: Tween = get_tree().create_tween()
	const anim_time: float = 0.3
	tween.set_parallel(true)
	tween.tween_property(self, "modulate", Color.WHITE.lerp(Color.CYAN, slow_amount), anim_time)
	tween.tween_property(
		animation_player,
		"speed_scale",
		clamp(1.0 - slow_amount, 0.0, 1.0),
		anim_time,
	)

	return


func attack_town() -> void:
	destination_town.take_damage()
	destroy()


func death_animation() -> void:
	speech_box.text = stats.death_speech

	var tween = get_tree().create_tween()
	const ANIM_TIME: float = 2.0
	tween.set_parallel(true)
	tween.tween_property(sprite_2d, "global_rotation", PI / 2.0, ANIM_TIME)
	tween.tween_property(self, "modulate", Color(1., 1., 1., 0.), ANIM_TIME)
	tween.tween_property(self, "global_skew", PI / 8.0, ANIM_TIME)
	tween.tween_property(self, "scale", Vector2(0.7, 0.7), ANIM_TIME)
	tween.finished.connect(destroy)
	await tween.finished
	return


func destroy() -> void:
	destroyed.emit()
	queue_free()
	return


func die() -> void:
	state = State.DEAD
	health_bar.visible = false

	if stats.sounds_death:
		AudioManager.play_sound_at_location(global_position, stats.sounds_death)

	spawn_loot()
	death_animation()
	return


func spawn_loot() -> void:
	var new_loot: Gold = GOLD.instantiate()
	new_loot.global_position = global_position + Vector2.from_angle(randf() * 2 * PI) * randf_range(20.0, 80.0)
	new_loot.money_value = stats.gold_on_death
	new_loot.z_index = 80
	new_loot.collected.connect(loot_handler.collect_loot)
	add_sibling(new_loot)


func take_damage(damage: float, from: Node2D) -> void:
	health -= damage
	health_bar.value = health
	if health <= 0:
		die()
		if is_instance_of(from, Tower):
			spawn_xp_gems(from)


func spawn_xp_gems(target: Tower) -> void:
	var time_between_gems = 0.5 / stats.xp_on_death
	for n in range(stats.xp_on_death):
		var xp_gem: XPGem = XP_GEM.instantiate()
		xp_gem.target_position = target.global_position
		xp_gem.global_position = global_position
		xp_gem.target = target
		add_sibling(xp_gem)
		await get_tree().create_timer(time_between_gems).timeout
