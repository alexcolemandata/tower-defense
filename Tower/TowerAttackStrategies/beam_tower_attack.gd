class_name BeamTowerAttack
extends TowerAttackStrategy


func create_shot_line(target: Monster, shooter: Tower) -> void:
	var shot_line: Line2D = Line2D.new()
	shot_line.add_point(shooter.global_position)
	shot_line.add_point(target.global_position)
	shot_line.default_color = Color.CYAN
	shot_line.width = 4.
	shooter.add_sibling(shot_line)
	await shooter.get_tree().create_timer(.1).timeout
	shot_line.queue_free()
	return


func shoot_at_target(target: Monster, shooter: Tower, damage: int) -> void:
	create_shot_line(target, shooter)
	target.take_damage(damage, shooter)
