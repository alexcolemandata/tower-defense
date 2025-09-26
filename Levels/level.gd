class_name Level extends Node

@onready var town: Town = %Town
@onready var monster_trail: MonsterTrail = %MonsterTrail

var wave_spawn_patterns: Array[MonsterSpawnPattern]


func _ready() -> void:
	monster_trail.destination_town = town
