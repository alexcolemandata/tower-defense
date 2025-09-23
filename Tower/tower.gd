class_name Tower extends Node2D

@export var vision_range: float = 200.
@export var shoots_per_second: float = 1.2
@export var damage_per_shot: float = 1.

@export var cost: int = 10
@export var tower_name: String = "Basic Tower"

@onready var vision_shape: CollisionShape2D = %VisionShape
@onready var vision_area: Area2D = %VisionArea
@onready var speech_box: Label = %SpeechBox
@onready var current_level_display: Label = %CurrentLevelDisplay
@onready var xp_level_progress_bar: ProgressBar = %XPLevelProgressBar
@onready var footprint: Area2D = %Footprint
@onready var footprint_shape: CollisionShape2D = %FootprintShape

signal placed
signal refunded

enum State {PLACING, ACTIVE}
var state = State.ACTIVE

var xp: int = 0
var level: int = 1
var xp_to_next_level = 30

var last_shot_time: float = 0.

var placement_checker: Callable

func _ready() -> void:
	var shape: CircleShape2D = vision_shape.shape
	shape.radius = vision_range
	refresh_level_display()

func _process(delta: float) -> void:
	if state == State.ACTIVE:
		_process_active(delta)
	elif state == State.PLACING:
		_process_placing(delta)
	queue_redraw()
	return
	
func _process_active(delta):
	last_shot_time += delta
	if last_shot_time >= 1/shoots_per_second:
		attempt_shot()

func _process_placing(_delta) -> void:
	var can_place = is_placeable()
	if can_place:
		modulate = Color(1, 1, 1, 0.3)
	else:
		modulate = Color(1, 0, 0, 0.3)
	global_position = get_global_mouse_position()
	
func is_refundable() -> bool:
	var overlapping = footprint.get_overlapping_areas()
	for overlap in overlapping:
		if overlap.has_method("refund_tower"):
			return true
	return false
			
	
func is_placeable() -> bool:
	var overlapping = footprint.get_overlapping_areas()
	for overlap in overlapping:
		if footprint != overlap:
			return false
	return true
	
func _draw() -> void:
	if (state == State.PLACING) or _is_mouse_on_footprint():
		draw_circle(Vector2.ZERO, vision_range, Color(1., 1., 1., 0.4), false, 2.0, true)
	
func _is_mouse_on_footprint() -> bool:
	var mouse_pos = get_global_mouse_position()
	var overlap_shape: CircleShape2D = footprint_shape.shape
	var distance = mouse_pos.distance_to(footprint.global_position)
	return distance <= overlap_shape.radius
	
func _input(event: InputEvent) -> void:
	if not state == State.PLACING:
		return
		
	if (event is InputEventMouseButton) and event.is_released():
		attempt_placement(get_global_mouse_position())

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

func shoot_at(target) -> void:
	create_shot_line(target)
	
	target.take_damage(damage_per_shot, self)
	last_shot_time = 0.
	
	return
	
func create_shot_line(target) -> void:
	var shot_line: Line2D = Line2D.new()
	shot_line.add_point(
		Vector2.ZERO,
	)
	shot_line.add_point(
		to_local(target.global_position)
	)
	shot_line.default_color = Color.CYAN
	shot_line.width = 4.
	add_child(shot_line)
	await get_tree().create_timer(.1).timeout
	shot_line.queue_free()
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
	
func level_up() -> void:
	level += 1
	xp_to_next_level = xp_to_next_level * level
	xp = 0
	
	refresh_level_display()
	return
	
func refresh_level_display() -> void:
	current_level_display.text = "Level: " + str(level)
	xp_level_progress_bar.max_value = xp_to_next_level
	xp_level_progress_bar.value = xp
