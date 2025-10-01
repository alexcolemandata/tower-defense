class_name SpellStats
extends Resource

var spell_name: String
var mp_cost: int

func _init(p_spell_name: String, p_mp_cost: int) -> void:
	spell_name = p_spell_name
	mp_cost = p_mp_cost

