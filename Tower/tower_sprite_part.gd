@tool
class_name TowerSpritePart
extends Sprite2D

enum SpriteRow {
	CUBE = 0,
	CUBES = 1,
	RECTANGLE = 2,
	TOWER_WINDOW = 3,
	TOWER_DOOR = 4,
	TOWER_CUBE = 5,
	PARAPET_CENTER = 6,
	PARAPET_SIDE = 7,
}

@export var sprite_row: SpriteRow:
	get:
		return frame_coords.y as SpriteRow
	set(value):
		frame_coords.y = value as int
