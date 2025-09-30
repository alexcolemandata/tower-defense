class_name XPGems extends Node2D

@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D

var gem_origin_global_position: Vector2
var num_gems: int


func _ready() -> void:
	var particle_material: ParticleProcessMaterial = gpu_particles_2d.process_material
	var gem_origin = to_local(gem_origin_global_position)
	particle_material.emission_shape_offset = Vector3(gem_origin.x, gem_origin.y, 0)
	gpu_particles_2d.amount = num_gems
	gpu_particles_2d.emitting = false


func fire_and_free() -> void:
	gpu_particles_2d.emitting = true
	gpu_particles_2d.finished.connect(queue_free)
