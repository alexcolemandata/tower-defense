@tool
extends Path2D

const MONSTER = preload("res://monster.tscn")

@export var line_color: Color = Color.WHITE
@export var line_width: float = 4.

var destination_town: Town

func _draw() -> void:
	var points = curve.get_baked_points()
	if points.size() > 1:
		draw_polyline(points, line_color, line_width)

func _process(_delta: float) -> void:
	queue_redraw()

func spawn_monster() -> void:
	var monster: Monster = MONSTER.instantiate()
	monster.destination_town = destination_town
	add_child(monster)
