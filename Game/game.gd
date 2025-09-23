extends Node2D

const TOWER = preload("uid://eou4mq5n6oh3")

const TOWER_TEXTURE = preload("uid://8doeehu0sj6y")
const SPIFFY_TOWER_TEXTURE = preload("uid://c5ktq13ybkphg")

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
var wave: int = 1

enum GameState {PLAYING, PLACING_TOWER, GAME_OVER, VICTORY}
var game_state = GameState.PLAYING

var tower_stats: Array[TowerStats] = [
	TowerStats.new("Basic Tower", 160., 2, 1., 15, TOWER_TEXTURE, BeamTowerAttack.new()),
	TowerStats.new("Spiffy Tower", 240., 4, 1.1, 80, SPIFFY_TOWER_TEXTURE, BeamTowerAttack.new())
]

func _ready() -> void:
	town.death_manager = self
	monster_trail.destination_town = town
	monster_trail.loot_handler = self
	game_over_screen.visible = false
	refresh_ui()
	for tower_stat in tower_stats:
		purchase_tower_button = in_game_ui.tower_purchase_menu.add_tower_to_purchase(tower_stat)
		purchase_tower_button.pressed.connect(_attempt_purchase.bind(tower_stat))
		
	in_game_ui.next_wave_button.pressed.connect(trigger_next_wave)
	
	return

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		exit_game()
	
	if event.is_action_released("debug_spawn_monster"):
		spawn_monster()
		
func _attempt_purchase(tower_stat: TowerStats) -> void:
	if not game_state == GameState.PLAYING:
		return
		
	if tower_stat.cost > money:
		print("not enough money")
		return
	money -= tower_stat.cost
	print("purchased ", tower_stat.tower_name, " for $", str(tower_stat.cost))
	choosing_tower_placement(tower_stat)
	refresh_money()
	
	return
	
func trigger_next_wave() -> void:
	wave += 1
	monsters_spawned = 0
	total_monsters_to_spawn *= 2
	seconds_per_monster *= 0.9
	refresh_monster_counts()
	in_game_ui.set_next_wave_button_enabled(false)
	town.stop_celebrating()
	game_state = GameState.PLAYING

func choosing_tower_placement(tower_stat: TowerStats) -> void:
	print("placing: " + tower_stat.tower_name)
	game_state = GameState.PLACING_TOWER
	
	var new_tower: Tower = TOWER.instantiate()
	new_tower.state = Tower.State.PLACING
	new_tower.stats = tower_stat
	new_tower.placed.connect(finished_placing_tower.bind(new_tower))
	new_tower.refunded.connect(refund_tower.bind(tower_stat))
	add_child(new_tower)
	
	return
	
func finished_placing_tower(_tower: Tower) -> void:
	game_state = GameState.PLAYING
	return
	
func refund_tower(tower_stat: TowerStats) -> void:
	game_state = GameState.PLAYING
	money += tower_stat.cost
	refresh_money()
	return
	
func gain_money(amount: int) -> void:
	money += amount
	refresh_money()
	
func refresh_ui() -> void:
	refresh_money()
	refresh_monster_counts()
	
func refresh_money() -> void:
	in_game_ui.set_money(money)
	
func refresh_monster_counts() -> void:
	in_game_ui.set_monster_progress(monsters_spawned, total_monsters_to_spawn)
	in_game_ui.set_wave_number(wave)
		
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
	in_game_ui.set_next_wave_button_enabled(true)
	town.start_celebrating()

func handle_death(died) -> void:
	if is_instance_of(died, Town):
		game_over()
		
func game_over() -> void:
	print("DIED")
	game_state = GameState.GAME_OVER
	game_over_screen.visible = true
	
func collect_loot(money_value: int) -> void:
	gain_money(money_value)
