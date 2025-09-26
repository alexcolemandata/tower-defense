class_name MonsterSpawnPattern extends Resource

@export var within_seconds: float
@export var num_groups: int
@export var group: Array[Monster.MonsterVariation]


func _init(p_within_seconds: float, p_num_groups: int, p_group: Array[Monster.MonsterVariation]) -> void:
	within_seconds = p_within_seconds
	num_groups = p_num_groups
	group = p_group
