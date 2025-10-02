class_name Gold
extends Node2D

signal collected(money: int)

var is_collected: bool = false
var is_attracted_to_mouse: bool = false
var is_mouse_attractable: bool = true
var money_value: int = 10
var current_velocity := Vector2.ZERO
var current_accel := Vector2.ZERO

@export var max_speed: float = 200.0
@export var inertia_weight: float = 0.1

@onready var mouse_over_area: Area2D = $MouseOverArea
@onready var mouse_attract_shape: CollisionShape2D = $MouseAttractArea/MouseAttractShape


func collect_loot():
	AudioManager.play_sound_at_location(
		global_position,
		AudioManager.sounds.loot_gold,
	)
	is_collected = true
	collected.emit(money_value)
	visible = false
	queue_free()

func _ready() -> void:
	scale = Vector2.ONE * 0.5 + Vector2.ONE * clamp(money_value / 50.0, 0.0, 3.0)

func _on_mouse_over_area_mouse_entered() -> void:
	if is_collected:
		return
	collect_loot()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_MOUSE_EXIT:
			is_mouse_attractable = false
		NOTIFICATION_WM_MOUSE_ENTER:
			is_mouse_attractable = true

func _on_mouse_attract_area_mouse_entered() -> void:
	is_attracted_to_mouse = true

func _physics_process(delta: float) -> void:
	if not is_attracted_to_mouse and is_mouse_attractable:
		return
	
	current_velocity += current_accel * delta
	global_position += current_velocity * delta
	
	var vec_to_mouse: Vector2 = (get_global_mouse_position() - global_position)
	var weighted_mouse_vector = vec_to_mouse.normalized() * max_speed * (
		clamp(mouse_attract_shape.shape.radius - vec_to_mouse.length(), 0, max_speed) / (mouse_attract_shape.shape.radius)
	)
	
	current_velocity = lerp(current_velocity, weighted_mouse_vector, inertia_weight)

	return
