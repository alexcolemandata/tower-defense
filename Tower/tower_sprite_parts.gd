@tool
class_name TowerSpriteParts extends Node2D

enum FrameCol {
	BUILD_1 = 0,
	BUILD_2 = 1,
	BUILD_3 = 2,
	UNDAMAGED = 3,
	DAMAGE_1 = 4,
	DAMAGE_2 = 5,
	DAMAGE_3 = 6,
	DAMAGE_4 = 7,
	DESTROYED = 8,
}

enum State { BUILDING, STATIC }
var state: State = State.STATIC

@export var frame_col: FrameCol = FrameCol.UNDAMAGED
@export var frames_per_sec: float = 8.0
var sec_since_frame: float = 0.0

var sec_per_frame: float:
	get:
		return 1.0 / frames_per_sec
	set(value):
		frames_per_sec = 1.0 / value


func _process(delta) -> void:
	for sprite_part: TowerSpritePart in get_tower_parts():
		sprite_part.frame_coords.x = frame_col

	if state == State.BUILDING:
		sec_since_frame += delta
		if sec_since_frame > sec_per_frame:
			sec_since_frame = 0.0
			if frame_col >= FrameCol.BUILD_3:
				frame_col = FrameCol.UNDAMAGED
				state = State.STATIC
			else:
				frame_col = (frame_col + 1) as FrameCol


func set_sprite_row(sprite_row: TowerSpritePart.SpriteRow) -> void:
	for sprite_part in get_tower_parts():
		sprite_part.sprite_row = sprite_row


func get_tower_parts() -> Array[TowerSpritePart]:
	var result: Array[TowerSpritePart] = []
	for child in get_children():
		if is_instance_of(child, TowerSpritePart):
			result.append(child)
	return result


func play_build_animation() -> void:
	state = State.BUILDING
	frame_col = FrameCol.BUILD_1
