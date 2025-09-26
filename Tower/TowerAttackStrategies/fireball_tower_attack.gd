class_name FireballTowerAttack extends TowerAttackStrategy

const FIREBALL_ATTACK_EFFECT = preload("uid://de0anlp4yjdlu")


func shoot_at_target(target: Monster, shooter: Tower, damage: int) -> void:
	send_fireball_to_coordinate(target.global_position, shooter, damage)


func send_fireball_to_coordinate(coord: Vector2, from: Tower, damage: int) -> void:
	var fireball: FireballAttackEffect = FIREBALL_ATTACK_EFFECT.instantiate()
	from.add_child(fireball)
	fireball.global_position = from.global_position
	fireball.target_coord.global_position = coord
	fireball.fire()
	fireball.damaged_monster.connect(damage_monster.bind(from, damage))
	return


func damage_monster(monster: Monster, from: Tower, damage: int) -> void:
	if not monster.state == Monster.State.ACTIVE:
		return

	monster.take_damage(damage, from)
