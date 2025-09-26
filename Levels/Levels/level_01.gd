extends Level

func _ready() -> void:
	super._ready()
	wave_spawn_patterns = [
		MonsterSpawnPattern.new(4, 8, [Monster.MonsterVariation.LOLLY_GAGGER]),
	]
