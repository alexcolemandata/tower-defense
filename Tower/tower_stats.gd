class_name TowerStats extends Resource

const TOWER_SPRITE_PARTS = preload("uid://c04fh02hms6ha")

@export var cost: int
@export var damage_per_shot: int
@export var shoots_per_second: float
@export var tower_name: String
@export var vision_range: float
@export var attack_strategy: TowerAttackStrategy
@export var sprite_parts: PackedScene


func _init(
		p_tower_name: String = "Unnamed Tower",
		p_vision_range: float = 10.,
		p_damage_per_shot: int = 1,
		p_shoots_per_second: float = 1.,
		p_cost: int = 10,
		p_attack_strategy: TowerAttackStrategy = BeamTowerAttack.new(),
		p_sprite_parts: PackedScene = TOWER_SPRITE_PARTS,
) -> void:
	tower_name = p_tower_name
	vision_range = p_vision_range
	damage_per_shot = p_damage_per_shot
	shoots_per_second = p_shoots_per_second
	cost = p_cost
	attack_strategy = p_attack_strategy
	sprite_parts = p_sprite_parts
