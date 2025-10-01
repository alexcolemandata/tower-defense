extends AudioStreamPlayer

@export_range(-80.0, 24.0, 0.01) var default_volume_db: float = -14.0
@export var start_fade_in_sec: float = 6.0

func _ready() -> void:
	var tween: Tween = create_tween()
	volume_db = -80.0
	(
		tween.tween_property(
			self, "volume_db", default_volume_db, start_fade_in_sec
		)
		.set_ease(Tween.EASE_IN)
	)
