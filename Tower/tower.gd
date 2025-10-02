class_name Tower extends Node2D

signal placed
signal refunded

enum State { PLACING, ACTIVE }

const BADLVLUP = preload("uid://cge6426i07hvr")

@export var stats: TowerStats
@export_range(2, 4) var max_level: int = 5

var last_shot_time: float = 0.
var level: int = 1
var placement_checker: Callable
var state = State.ACTIVE
var xp: int = 0
var xp_to_next_level = 30
var displayed_xp_amount: int = 0
var time_since_last_xp: float = 0
const xp_display_time: float = 1.0

@onready var footprint: Area2D = %Footprint
@onready var footprint_shape: CollisionShape2D = %FootprintShape
@onready var gain_xp_display: Label = %GainXPDisplay
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var vision_area: Area2D = %VisionArea
@onready var vision_shape: CollisionShape2D = %VisionShape
@onready var xp_level_progress_bar: ProgressBar = %XPLevelProgressBar
@onready var lvl_up_shader_sprite: Sprite2D = $LvlUpShaderSprite
@onready var tower_level_stars: TowerLevelStars = $TowerLevelStars


func _ready() -> void:
	var shape: CircleShape2D = vision_shape.shape
	shape.radius = stats.vision_range
	sprite_2d.texture = stats.texture
	lvl_up_shader_sprite.texture = stats.texture
	lvl_up_shader_sprite.visible = false
	tower_level_stars.max_stars = max_level -2

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
	
	if not is_placeable() or is_refundable():
		draw_circle(
			Vector2.ZERO,
			footprint_shape.shape.radius,
			Color.WHITE,
			false,
			2.0,
			true
		)


func attempt_placement(new_global_position: Vector2) -> void:
	if is_refundable():
		refunded.emit()
		AudioManager.play_sound(AudioManager.sounds.tower_refund)
		queue_free()
		return
	elif not is_placeable():
		return
	global_position = new_global_position
	state = State.ACTIVE
	modulate.a = 1.
	placed.emit()
	AudioManager.play_sound_at_location(
		new_global_position,
		AudioManager.sounds.tower_place,
	)
	return


func attempt_shot() -> void:
	var overlaps: Array[Area2D] = vision_area.get_overlapping_areas()
	if len(overlaps) == 0:
		return

	for overlap in overlaps:
		var target = overlap.get_parent()
		if (
			target.has_method("take_damage")
			and target.has_method("die")
			and (target.state == Monster.State.ACTIVE)
		):
			shoot_at(target)
			return
	return


func gain_xp(amount: int) -> void:
	if level >= max_level:
		return

	time_since_last_xp = 0.0
	xp += amount

	if xp >= xp_to_next_level:
		level_up()

	xp_level_progress_bar.value = xp
	displayed_xp_amount += amount

	return


func is_placeable() -> bool:
	var overlapping: Array[Area2D] = footprint.get_overlapping_areas()
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

	lvl_up_shader_sprite.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2.ONE * 1.2, 0.8)
	tween.tween_property(self, "scale", Vector2.ONE * 1, 0.3)
	tween.finished.connect(func(): lvl_up_shader_sprite.visible = false)

	return


func refresh_level_display() -> void:
	xp_level_progress_bar.max_value = xp_to_next_level
	xp_level_progress_bar.value = xp
	tower_level_stars.num_stars = level - 1

	if level >= max_level:
		xp_level_progress_bar.visible = false


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

	time_since_last_xp += delta
	if time_since_last_xp > xp_display_time:
		displayed_xp_amount = 0
		gain_xp_display.visible = false

	if displayed_xp_amount > 0:
		gain_xp_display.visible = true
		gain_xp_display.text = "+" + str(displayed_xp_amount) + " XP!"
		gain_xp_display.add_theme_font_size_override(
			"font_size",
			clamp(displayed_xp_amount / 1.4, 14.0, 80.0),
		)


func _process_placing(_delta) -> void:
	var can_place = is_placeable()
	if can_place:
		modulate = Color(1, 1, 1, 0.3)
	else:
		modulate = Color(1, 0, 0, 0.3)
	global_position = get_global_mouse_position()
