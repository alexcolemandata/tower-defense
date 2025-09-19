class_name Tower extends Node2D

@export var vision_range: float = 200.
@export var shoots_per_second: float = 1.2
@export var damage_per_shot: float = 1.

@onready var vision_shape: CollisionShape2D = %VisionShape
@onready var vision_area: Area2D = %VisionArea
@onready var speech_box: Label = %SpeechBox
@onready var current_level_display: Label = %CurrentLevelDisplay
@onready var xp_level_progress_bar: ProgressBar = %XPLevelProgressBar


var xp: int = 0
var level: int = 1
var xp_to_next_level = 30

var last_shot_time: float = 0.

func _ready() -> void:
	var shape: CircleShape2D = vision_shape.shape
	shape.radius = vision_range
	refresh_level_display()

func _process(delta: float) -> void:
	last_shot_time += delta
	if last_shot_time >= 1/shoots_per_second:
		attempt_shot()
	
	return
	
func _draw() -> void:
	draw_circle(Vector2.ZERO, vision_range, Color.WHITE, false, 2.0, true)

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
	target.take_damage(damage_per_shot, self)
	last_shot_time = 0.
	print("shot at ", target, " for ", damage_per_shot, " damage")
	return
	
func gain_xp(amount: int) -> void:
	xp += amount
	
	speech_box.text = "+" + str(amount) + "XP!"
	await get_tree().create_timer(1.).timeout
	speech_box.text = ""
	
	if xp >= xp_to_next_level:
		level_up()
	else:
		xp_level_progress_bar.value = xp
		
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
