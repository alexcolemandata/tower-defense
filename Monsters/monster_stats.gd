class_name MonsterStats extends Resource

@export var death_speech: String = "I'm a Test Monster!"
@export var gold_on_death: int = 5
@export var max_health: float = 10.0
@export var speed_perc_per_sec: float = 5.0
@export var sprite_texture: Texture2D = preload("uid://bjmnblsu1q8ax")
@export var xp_on_death: int = 10

@export_group("Sounds", "sounds_")
@export var sounds_death: SoundSettings
