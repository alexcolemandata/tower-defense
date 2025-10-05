class_name TownSpritePart extends SpritePart

func get_remaining_health():
	match frame_coords.x as SpriteParts.FrameCol:
		SpriteParts.FrameCol.UNDAMAGED:
			return 5
		SpriteParts.FrameCol.DAMAGE_1:
			return 4
		SpriteParts.FrameCol.DAMAGE_2:
			return 3
		SpriteParts.FrameCol.DAMAGE_3:
			return 2
		SpriteParts.FrameCol.DAMAGE_4:
			return 1
		SpriteParts.FrameCol.DESTROYED:
			return 0
		_:
			return -1


func set_remaining_health(value: int) -> void:
	var frame_col: SpriteParts.FrameCol
	match value:
		0:
			frame_col = SpriteParts.FrameCol.DESTROYED
		1:
			frame_col = SpriteParts.FrameCol.DAMAGE_4
		2:
			frame_col = SpriteParts.FrameCol.DAMAGE_3
		3:
			frame_col = SpriteParts.FrameCol.DAMAGE_2
		4:
			frame_col = SpriteParts.FrameCol.DAMAGE_1
		_:
			return

	frame_coords = Vector2i(frame_col as int, frame_coords.y)


func damage_part() -> void:
	set_remaining_health(get_remaining_health() - 1)


func heal_part() -> void:
	set_remaining_health(get_remaining_health() + 1)
