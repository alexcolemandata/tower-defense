class_name TowerAttackStrategy
extends Resource

func shoot_at_target(target: Monster, shooter: Tower, damage: int) -> void:
	target.take_damage(damage, shooter)
	
