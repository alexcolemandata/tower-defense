class_name SlowSpell extends Node2D

signal placed

@export var aoe_radius: float = 100.0
@export var active_time_sec: float = 3.0
@export_range(0.0, 1.0, 0.05) var slow_factor: float = 0.3

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var spell_area: Area2D = $SpellArea
@onready var spell_area_shape: CollisionShape2D = $SpellArea/SpellAreaShape
@onready var area_sprite: Sprite2D = $AreaSprite
var active_timer: float = 0.0

enum State { TARGETTING, ACTIVE, FINISHING }
var current_state = State.TARGETTING

var affected_monsters: Array[Monster] = []

const sprite_scale_per_unit_radius: float = 0.00068

var _spell_sound_stream: AudioStreamPlayer2D


func _ready() -> void:
	var sprite_scaling_factor: float = aoe_radius * sprite_scale_per_unit_radius
	animation_player.play("idle")
	animation_player.speed_scale = 2.0
	area_sprite.scale = Vector2(sprite_scaling_factor, sprite_scaling_factor)

	var spell_circle: CircleShape2D = spell_area_shape.shape
	spell_circle.radius = aoe_radius
	spell_area.area_entered.connect(process_area_entered)
	spell_area.area_exited.connect(process_area_exited)


func _process(delta: float) -> void:
	match current_state:
		State.TARGETTING:
			process_targetting_state(delta)
		State.ACTIVE:
			process_active_state(delta)
	return


func _input(event: InputEvent) -> void:
	if current_state == State.TARGETTING:
		input_targetting_state(event)


func input_targetting_state(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_released():
		place_spell()


func process_targetting_state(_delta: float) -> void:
	global_position = get_global_mouse_position()


func process_active_state(delta: float) -> void:
	active_timer += delta
	animation_player.speed_scale = 1.0 - (active_timer / active_time_sec)
	if active_timer >= active_time_sec:
		finish_spell()
		return


func process_area_entered(area: Area2D) -> void:
	if current_state != State.ACTIVE:
		return

	var area_parent = area.get_parent()
	if is_instance_of(area_parent, Monster):
		add_affected_monster(area_parent)


func process_area_exited(area: Area2D) -> void:
	if current_state != State.ACTIVE:
		return

	var area_parent = area.get_parent()
	if is_instance_of(area_parent, Monster):
		remove_affected_monster(area_parent)


func add_affected_monster(monster: Monster) -> void:
	if monster in affected_monsters:
		return
	affected_monsters.append(monster)
	monster.apply_slow(slow_factor)


func remove_affected_monster(monster: Monster) -> void:
	var monster_idx: int = affected_monsters.find(monster)
	if monster_idx > -1:
		affected_monsters.pop_at(monster_idx)
		monster.apply_slow(-slow_factor)


func finish_spell() -> void:
	current_state = State.FINISHING
	for monster in affected_monsters:
		remove_affected_monster(monster)

	var tween: Tween = get_tree().create_tween()
	const ANIM_TIME: float = 1.0
	tween.set_parallel(true)
	tween.tween_property(self, "cale", Vector2.ZERO, ANIM_TIME)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), ANIM_TIME)
	if _spell_sound_stream:
		tween.tween_property(_spell_sound_stream, "volume_linear", 0.0, ANIM_TIME)
	tween.finished.connect(delete_spell)


func delete_spell() -> void:
	for monster in affected_monsters:
		if monster:
			monster.apply_slow(-slow_factor)
	queue_free()


func place_spell() -> void:
	placed.emit()
	spell_area.monitoring = true
	current_state = State.ACTIVE

	_spell_sound_stream = AudioManager.play_sound_at_location(global_position, AudioManager.sounds.spell_slow_drone)

	var overlapping: Array[Area2D] = spell_area.get_overlapping_areas()
	for overlap in overlapping:
		var overlap_parent = overlap.get_parent()
		if is_instance_of(overlap_parent, Monster):
			add_affected_monster(overlap_parent)
