extends Sprite2D

@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D

func _ready() -> void:
	stop_celebrating()

func start_celebrating() -> void:
	visible = true
	gpu_particles_2d.emitting = true
	
func stop_celebrating() -> void:
	visible = false
