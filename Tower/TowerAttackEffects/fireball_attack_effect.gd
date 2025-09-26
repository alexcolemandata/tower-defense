class_name FireballAttackEffect
extends Node2D

signal damaged_monster(monster: Monster)

enum State { IDLE, FIRED, EXPLODED }

var damage: float
# we only want to hit a monster once per fireball
var hit_monsters: Array[Monster] = []
var speed: float = 400.
var state: State = State.IDLE

@onready var explosion: Node2D = %Explosion
@onready var explosion_hit_box: Area2D = %ExplosionHitBox
@onready var fireball_sprite: Sprite2D = $FireballSprite
@onready var target_coord: Marker2D = $TargetCoord


func _ready() -> void:
	explosion.visible = false
	explosion_hit_box.monitoring = false


func _process(delta: float) -> void:
	if state == State.EXPLODED:
		check_monsters_in_blast_radius()
		return
	elif not state == State.FIRED:
		return
	fireball_sprite.look_at(target_coord.global_position)
	var movement_vector = (
		target_coord.global_position
		- fireball_sprite.global_position ).normalized() * speed * delta

	fireball_sprite.global_position = fireball_sprite.global_position + movement_vector

	if fireball_sprite.global_position.distance_to(target_coord.global_position) < (speed * delta):
		explode()
		AudioManager.play_sound_at_location(
			target_coord.global_position,
			AudioManager.sounds.tower_attack_fireball_explosion,
		)


func check_monsters_in_blast_radius() -> void:
	var overlapping: Array[Area2D] = explosion_hit_box.get_overlapping_areas()
	for overlap in overlapping:
		var overlap_parent = overlap.get_parent()
		if is_instance_of(overlap_parent, Monster) and not (overlap_parent in hit_monsters):
			var monster: Monster = overlap_parent
			hit_monsters.append(monster)
			damaged_monster.emit(monster)


func explode():
	state = State.EXPLODED
	var tween = get_tree().create_tween()

	fireball_sprite.visible = false
	explosion.scale = Vector2.ZERO
	explosion.visible = true
	explosion_hit_box.monitoring = true
	tween.tween_property(explosion, "scale", Vector2(1., 1.), 0.2)
	tween.tween_property(explosion, "modulate", Color(1., 1., .1, 0.), 0.3)

	await tween.finished
	queue_free()


func fire() -> void:
	AudioManager.play_sound_at_location(global_position, AudioManager.sounds.tower_attack_fireball_shoot)
	state = State.FIRED
