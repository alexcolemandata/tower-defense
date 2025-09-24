class_name Gold
extends Node2D

signal collected(money: int)

var money_value: int = 10

@onready var mouse_over_area: Area2D = $MouseOverArea


func collect_loot():
	collected.emit(money_value)
	queue_free()


func _on_mouse_over_area_mouse_entered() -> void:
	collect_loot()
