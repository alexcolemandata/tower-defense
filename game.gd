extends Node2D

const TOWER = preload("uid://eou4mq5n6oh3")

@onready var monster_trail: MonsterTrail = %MonsterTrail
@onready var town: Town = %Town
@onready var game_over_screen: ColorRect = %GameOverScreen
@onready var in_game_ui: InGameUI = %InGameUI

@export var seconds_per_monster: float = 1.0
@export var total_monsters_to_spawn: int = 3
var monsters_spawned: int = 0

var seconds_since_monster: float = 0.
var money: int = 100
var purchase_tower_button: Button

enum GameState {PLAYING, PLACING_TOWER, GAME_OVER, VICTORY}
var game_state = GameState.PLAYING

func _ready() -> void:
	town.death_manager = self
	monster_trail.destination_town = town
	game_over_screen.visible = false
	refresh_ui()
	purchase_tower_button = in_game_ui.tower_purchase_menu.add_tower_to_purchase("Basic Tower", 10)
	purchase_tower_button.pressed.connect(_attempt_purchase.bind("Basic Tower", 10))
	
	return

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		exit_game()
	
	if event.is_action_released("debug_spawn_monster"):
		spawn_monster()
		
func _attempt_purchase(tower_name: String, cost: int) -> void:
	if not game_state == GameState.PLAYING:
		return
		
	if cost > money:
		print("not enough money")
		return
	money -= cost
	print("purchased ", tower_name, " for $", str(cost))
	choosing_tower_placement("Basic Tower")
	refresh_money()
	
	return

func choosing_tower_placement(tower_name: String) -> void:
	print("placing: " + tower_name)
	game_state = GameState.PLACING_TOWER
	
	var new_tower: Tower = TOWER.instantiate()
	new_tower.state = Tower.State.PLACING
	new_tower.placed.connect(finished_placing_tower)
	add_child(new_tower)
	
	return
	
func finished_placing_tower() -> void:
	game_state = GameState.PLAYING
	
func refresh_ui() -> void:
	refresh_money()
	refresh_monster_counts()
	
func refresh_money() -> void:
	in_game_ui.set_money(money)
	
func refresh_monster_counts() -> void:
	in_game_ui.set_monster_progress(monsters_spawned, total_monsters_to_spawn)
		
func exit_game() -> void:
	get_tree().quit()

func _process(delta: float) -> void:
	if (game_state == GameState.GAME_OVER) or (game_state == GameState.VICTORY):
		return
	
	if monsters_spawned < total_monsters_to_spawn:
		seconds_since_monster += delta	
		if seconds_since_monster >= seconds_per_monster:
			spawn_monster()
		return
	else:
		if monster_trail.count_monsters == 0:
			victory()
			return
	
		
	return
	
func spawn_monster() -> void:
	if monsters_spawned >= total_monsters_to_spawn:
		return
	monsters_spawned += 1
	seconds_since_monster = 0.
	monster_trail.spawn_monster()
	refresh_monster_counts()

func victory() -> void:
	game_state = GameState.VICTORY
	town.start_celebrating()

func handle_death(died) -> void:
	if is_instance_of(died, Town):
		game_over()
		
func game_over() -> void:
	print("DIED")
	game_state = GameState.GAME_OVER
	game_over_screen.visible = true
