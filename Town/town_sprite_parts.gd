class_name TownSpriteParts extends SpriteParts

const NUM_DAMAGE_STATES: int = 5

var parts: Array[TownSpritePart]

var max_hp: int:
	get:
		return get_max_hp()
var hp: int:
	get:
		return get_current_hp()
	set(value):
		set_hp(hp)

var hp_ratio: float:
	get:
		return hp / (max_hp as float)
	set(value):
		set_hp_ratio(value)

var ratio_per_hp: float:
	get:
		return 1.0 / (max_hp as float)


func _ready() -> void:
	for part in get_parts():
		parts.append(part as TownSpritePart)


func get_max_hp() -> int:
	return len(parts) * NUM_DAMAGE_STATES


func get_current_hp() -> int:
	var _hp: int = 0
	for part in parts:
		_hp += part.get_remaining_health()
	prints("current total hp: ", _hp)
	return _hp


func set_hp_ratio(value: float) -> void:
	var desired_hp = hp_ratio_to_hp(value)
	prints("set_hp_ratio:", value, "desired hp:", desired_hp)
	set_hp(desired_hp)


func hp_ratio_to_hp(ratio: float) -> int:
	if ratio >= 1:
		return max_hp
	elif ratio <= 0:
		return 0
	else:
		return floor(ratio * max_hp)


func set_hp(value: int) -> void:
	prints("set_hp,", value)
	var hp_change = value - hp
	if hp_change == 0:
		return
	elif hp_change < 0:
		for _x in range(-hp_change):
			damage_random_part()
	else:
		for _x in range(hp_change):
			heal_random_part()


func damage_random_part() -> void:
	prints("damage_random_part")
	var damagable_parts: Array[TownSpritePart] = []
	for part in parts:
		if part.get_remaining_health() > 0:
			damagable_parts.append(part)

	var part_to_damage: TownSpritePart = damagable_parts.pick_random()
	part_to_damage.damage_part()


func heal_random_part() -> void:
	prints("heal_random_part")
	var healable_parts: Array[TownSpritePart] = []
	for part in parts:
		var remain_hp = part.get_remaining_health()
		if (remain_hp >= 0) and (remain_hp < NUM_DAMAGE_STATES):
			healable_parts.append(part)

	var part_to_heal: TownSpritePart = healable_parts.pick_random()
	part_to_heal.heal_part()
