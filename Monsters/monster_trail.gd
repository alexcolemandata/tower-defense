@tool
class_name MonsterTrail
extends Path2D

const MONSTER = preload("uid://dt26jdmea8bpa")

@export var line_width: float = 64.0
@export var num_collision_points: int = 50

var total_monsters: int = 0
var count_monsters: int = 0
var destination_town: Town
var loot_handler

@onready var footprint_polygon: CollisionPolygon2D = $Footprint/FootprintPolygon
@onready var line_2d: Line2D = $Line2D


func _ready() -> void:
	generate_footprint()
	var points = curve.get_baked_points()
	if points.size() > 1:
		line_2d.points = points
		line_2d.width = line_width
		
func _draw() -> void:
	if Engine.is_editor_hint():
		var points = curve.get_baked_points()
		if points.size() > 1:
			draw_polyline(points, Color(1, 1, 1, 0.3), line_width, true)
	

func _process(_delta: float) -> void:
	queue_redraw()


func decrement_monster_count() -> void:
	count_monsters -= 1
	return


func generate_footprint() -> void:
	if not footprint_polygon:
		return
	var path_length = curve.get_baked_length()
	var footprint_points: PackedVector2Array = []
	var left_edges: Array = []
	var right_edges: Array = []

	for i in num_collision_points + 1:
		var sample_offset = (float(i) / float(num_collision_points)) * path_length
		var sampled_transform = curve.sample_baked_with_rotation(sample_offset)
		var path_point = sampled_transform.get_origin()
		var path_rotation = sampled_transform.get_rotation()
		var path_direction = Vector2.from_angle(path_rotation)

		left_edges.append(Vector2(path_point + (path_direction.rotated(PI / 2.) * line_width / 2.)))
		right_edges.append(Vector2(path_point + (path_direction.rotated(-PI / 2.) * line_width / 2.)))

	footprint_points.append_array(left_edges)
	right_edges.reverse()
	footprint_points.append_array(right_edges)

	footprint_polygon.set_polygon(footprint_points)
	return


func spawn_monster(monster_variation: Monster.MonsterVariation) -> Monster:
	var monster: Monster = MONSTER.instantiate()

	monster.stats = Monster.VARIATION_LOOKUP[monster_variation]
	monster.destination_town = destination_town
	monster.loot_handler = loot_handler
	count_monsters += 1
	total_monsters += 1
	monster.destroyed.connect(decrement_monster_count)
	add_child(monster)

	return monster
