extends Node2D

const MONSTER = preload("res://monster.tscn")

@onready var monster_trail: Path2D = %MonsterTrail

@export var seconds_per_monster: float = 1.0
var seconds_since_monster: float = 0.

func _ready() -> void:
	spawn_monster()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		exit_game()
		
func exit_game() -> void:
	get_tree().quit()

func _process(delta: float) -> void:
	seconds_since_monster += delta
	if seconds_since_monster >= seconds_per_monster:
		spawn_monster()
		seconds_since_monster = 0.
	return
	
func spawn_monster() -> void:
	var monster: Monster = MONSTER.instantiate()
	monster_trail.add_child(monster)
