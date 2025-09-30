class_name Gold
extends Node2D

signal collected(money: int)

var is_collected: bool = false
var is_attracted_to_mouse: bool = false
var money_value: int = 10
var current_velocity := Vector2.ZERO

@export var max_speed: float = 200.0
@export var inertia_weight: float = 10.0

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


func _on_mouse_over_area_mouse_entered() -> void:
	if is_collected:
		return
	collect_loot()


func _on_mouse_attract_area_mouse_entered() -> void:
	is_attracted_to_mouse = true

func _physics_process(delta: float) -> void:
	if not is_attracted_to_mouse:
		return
	
	global_position += current_velocity * delta
	
	
	
	var vec_to_mouse: Vector2 = get_global_mouse_position() - global_position
	
	var mouse_attract_radius: float = mouse_attract_shape.shape.radius
	var mouse_weight = clamp(vec_to_mouse.length() / mouse_attract_radius, 1.0, max_speed)
		
	current_velocity = (current_velocity * inertia_weight + vec_to_mouse * mouse_weight) / (2.0)
	if current_velocity.length() > max_speed:
		current_velocity = current_velocity.normalized() * max_speed
