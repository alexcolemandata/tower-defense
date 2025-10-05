extends Level

func _ready() -> void:
	super._ready()
	wave_spawn_patterns = [
		MonsterSpawnPattern.new(
			5,
			10,
			[
				Monster.MonsterVariation.NINJA,
			],
		),
		MonsterSpawnPattern.new(
			4,
			6,
			[
				Monster.MonsterVariation.LOLLY_GAGGER,
			],
		),
		MonsterSpawnPattern.new(
			4,
			20,
			[
				Monster.MonsterVariation.NINJA,
			],
		),
		MonsterSpawnPattern.new(
			10,
			2,
			[
				Monster.MonsterVariation.ZOMBIE,
				Monster.MonsterVariation.LOLLY_GAGGER,
				Monster.MonsterVariation.LOLLY_GAGGER,
				Monster.MonsterVariation.LOLLY_GAGGER,
				Monster.MonsterVariation.LOLLY_GAGGER,
			],
		),
	]
