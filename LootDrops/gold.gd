class_name Gold extends Node2D

@onready var mouse_over_area: Area2D = $MouseOverArea

var money_value: int = 10

signal collected(money: int)
	
func collect_loot():
	collected.emit(money_value)
	queue_free()


func _on_mouse_over_area_mouse_entered() -> void:
	collect_loot()
