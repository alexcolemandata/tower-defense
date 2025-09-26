class_name Tower
extends Node2D

signal placed
signal refunded

enum State { PLACING, ACTIVE }

const BADLVLUP = preload("uid://cge6426i07hvr")

@export var stats: TowerStats

var last_shot_time: float = 0.
var level: int = 1
var placement_checker: Callable
var state = State.ACTIVE
var xp: int = 0
var xp_to_next_level = 30

@onready var current_level_display: Label = %CurrentLevelDisplay
@onready var footprint: Area2D = %Footprint
@onready var footprint_shape: CollisionShape2D = %FootprintShape
@onready var speech_box: Label = %SpeechBox
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var vision_area: Area2D = %VisionArea
@onready var vision_shape: CollisionShape2D = %VisionShape
@onready var xp_level_progress_bar: ProgressBar = %XPLevelProgressBar


func _ready() -> void:
	var shape: CircleShape2D = vision_shape.shape
	shape.radius = stats.vision_range
	sprite_2d.texture = stats.texture
	refresh_level_display()


func _process(delta: float) -> void:
	if state == State.ACTIVE:
		_process_active(delta)
	elif state == State.PLACING:
		_process_placing(delta)
	queue_redraw()
	return


func _input(event: InputEvent) -> void:
	if not state == State.PLACING:
		return

	if (event is InputEventMouseButton) and event.is_released():
		attempt_placement(get_global_mouse_position())


func _draw() -> void:
	if (state == State.PLACING) or _is_mouse_on_footprint():
		draw_circle(
			Vector2.ZERO,
			stats.vision_range,
			Color(1., 1., 1., 0.4),
			false,
			2.0,
			true,
		)


func attempt_placement(new_global_position: Vector2) -> void:
	if is_refundable():
		refunded.emit()
		queue_free()
		return
	elif not is_placeable():
		return
	global_position = new_global_position
	state = State.ACTIVE
	modulate.a = 1.
	placed.emit()
	return


func attempt_shot() -> void:
	var overlaps: Array[Area2D] = vision_area.get_overlapping_areas()
	if len(overlaps) == 0:
		return

	for overlap in overlaps:
		var target = overlap.get_parent()
		if target.has_method("take_damage") and target.has_method("die") and not target.is_dead:
			shoot_at(target)
			return
	return


func gain_xp(amount: int) -> void:
	xp += amount

	if xp >= xp_to_next_level:
		level_up()
	else:
		xp_level_progress_bar.value = xp

	speech_box.text = "+" + str(amount) + "XP!"
	await get_tree().create_timer(1.).timeout
	speech_box.text = ""

	return


func is_placeable() -> bool:
	var overlapping = footprint.get_overlapping_areas()
	for overlap in overlapping:
		if footprint != overlap:
			return false
	return true


func is_refundable() -> bool:
	var overlapping = footprint.get_overlapping_areas()
	for overlap in overlapping:
		if overlap.has_method("refund_tower"):
			return true
	return false


func level_up() -> void:
	AudioManager.play_sound_at_location(
		global_position,
		AudioManager.sounds.tower_level_up,
	)
	level += 1
	xp_to_next_level = xp_to_next_level * level
	xp = 0

	refresh_level_display()
	return


func refresh_level_display() -> void:
	current_level_display.text = "Level: " + str(level)
	xp_level_progress_bar.max_value = xp_to_next_level
	xp_level_progress_bar.value = xp


func shoot_at(target) -> void:
	stats.attack_strategy.shoot_at_target(target, self, stats.damage_per_shot)
	last_shot_time = 0.
	return


func _is_mouse_on_footprint() -> bool:
	var mouse_pos = get_global_mouse_position()
	var overlap_shape: CircleShape2D = footprint_shape.shape
	var distance = mouse_pos.distance_to(footprint.global_position)
	return distance <= overlap_shape.radius


func _process_active(delta):
	last_shot_time += delta
	if last_shot_time >= 1 / stats.shoots_per_second:
		attempt_shot()


func _process_placing(_delta) -> void:
	var can_place = is_placeable()
	if can_place:
		modulate = Color(1, 1, 1, 0.3)
	else:
		modulate = Color(1, 0, 0, 0.3)
	global_position = get_global_mouse_position()
