extends Node2D

@onready var monster_trail: Path2D = %MonsterTrail
@onready var town: Town = %Town
@onready var game_over_screen: ColorRect = %GameOverScreen

@export var seconds_per_monster: float = 1.0
var seconds_since_monster: float = 0.
var is_game_over: bool = false

func _ready() -> void:
	spawn_monster()
	town.death_manager = self
	monster_trail.destination_town = town
	game_over_screen.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		exit_game()
		
func exit_game() -> void:
	get_tree().quit()

func _process(delta: float) -> void:
	if is_game_over:
		return
	seconds_since_monster += delta
	if seconds_since_monster >= seconds_per_monster:
		spawn_monster()
		seconds_since_monster = 0.
	return
	
func spawn_monster() -> void:
	monster_trail.spawn_monster()


func handle_death(died) -> void:
	if is_instance_of(died, Town):
		print("DIED")
		game_over()
		
func game_over() -> void:
	is_game_over = true
	game_over_screen.visible = true
