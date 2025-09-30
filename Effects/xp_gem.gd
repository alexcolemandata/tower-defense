class_name XPGem
extends Node2D

@export_range(0, 180) var initial_angle_spread_deg: float = 90.0
@export_range(0, 1000) var base_initial_speed: float = 300.0
@export_range(0, 500) var initial_speed_spread: float = 20.0
@export_range(0, 10000) var attraction_to_target: float = 900.0
@export_range(0, 50) var radius: float = 50.0
@export_range(0, 1) var initial_velocity_time: float = 0.3

var target: Tower
var target_position: Vector2
var current_velocity: Vector2
var total_lifespan: float = 0
var xp_value: int = 1

func _ready() -> void:
	
	var angle_diff: float = deg_to_rad(randf_range(-initial_angle_spread_deg / 2.0,initial_angle_spread_deg / 2.0))
	var initial_angle = get_vector_to_target().angle() + angle_diff
	var initial_speed = randf_range(
		base_initial_speed 
		- initial_speed_spread / 2.0, 
		base_initial_speed + initial_speed_spread / 2.0
	)
	
	current_velocity = Vector2.from_angle(initial_angle) * initial_speed
	
func get_vector_to_target() -> Vector2:
	return target_position - global_position
	
	
func _physics_process(delta: float) -> void:
	total_lifespan += delta
	global_position += current_velocity * delta
	
	var vector_to_target = get_vector_to_target()
	
	if vector_to_target.length() <= radius:
		target.gain_xp(xp_value)
		queue_free()
		
	if total_lifespan <= initial_velocity_time:
		return
	
	var target_velocity_attraction = attraction_to_target * total_lifespan
	var desired_velocity = vector_to_target.normalized() * target_velocity_attraction
	var current_speed = current_velocity.length()
	current_velocity = (current_velocity + desired_velocity) / (2.0)
