class_name Gold
extends Node2D

signal collected(money: int)

var is_collected: bool = false
var money_value: int = 10

@onready var mouse_over_area: Area2D = $MouseOverArea


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
