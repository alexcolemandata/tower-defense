@tool
extends Path2D

@export var line_color: Color = Color.WHITE
@export var line_width: float = 4.

func _draw() -> void:
	var points = curve.get_baked_points()
	if points.size() > 1:
		draw_polyline(points, line_color, line_width)

func _process(_delta: float) -> void:
	queue_redraw()
