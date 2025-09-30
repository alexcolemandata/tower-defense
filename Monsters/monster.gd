class_name Monster extends PathFollow2D

signal destroyed

const GOLD = preload("uid://ncncsppuo7x2")

@export var stats: MonsterStats = MonsterStats.new()

var destination_town: Town
var health: float
var loot_handler

@onready var health_bar: ProgressBar = %HealthBar
@onready var speech_box: Label = %SpeechBox
@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

const XP_GEMS = preload("uid://fqsnw6o62xo6")

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
			modulate.a = 1.

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
		if from.has_method("gain_xp"):
			from.gain_xp(stats.xp_on_death)

			var xp_gems: XPGems = XP_GEMS.instantiate()
			xp_gems.global_position = from.global_position
			xp_gems.gem_origin_global_position = global_position
			xp_gems.num_gems = stats.xp_on_death
			xp_gems.ready.connect(func(): xp_gems.fire_and_free())
			add_sibling(xp_gems)
