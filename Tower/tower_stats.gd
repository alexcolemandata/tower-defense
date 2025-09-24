class_name TowerStats
extends Resource

const TOWER = preload("uid://8doeehu0sj6y")

@export var cost: int
@export var damage_per_shot: int
@export var shoots_per_second: float
@export var texture: Texture2D
@export var tower_name: String
@export var vision_range: float

var attack_strategy: TowerAttackStrategy


func _init(
		p_tower_name: String = "Unnamed Tower",
		p_vision_range: float = 10.,
		p_damage_per_shot: int = 1,
		p_shoots_per_second: float = 1.,
		p_cost: int = 10,
		p_texture: Texture2D = TOWER,
		p_attack_strategy: TowerAttackStrategy = BeamTowerAttack.new(),
) -> void:
	tower_name = p_tower_name
	vision_range = p_vision_range
	damage_per_shot = p_damage_per_shot
	shoots_per_second = p_shoots_per_second
	cost = p_cost
	texture = p_texture
	attack_strategy = p_attack_strategy
