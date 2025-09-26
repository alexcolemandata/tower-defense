extends Node2D

enum GameState { PLAYING, GAME_OVER, VICTORY, LEVEL_END }

const TOWER = preload("uid://eou4mq5n6oh3")

@export var tower_stats: Array[TowerStats]

var game_state = GameState.PLAYING
var money: int = 0
var monsters_spawned: int = 0
var groups_spawned: int = 0

var seconds_since_group_spawn: float = 0.
var wave: int = 1

@onready var game_over_screen: ColorRect = %GameOverScreen
@onready var in_game_ui: InGameUI = %InGameUI

@onready var level: Level

@export var levels: Array[PackedScene]
@export var current_level_num: int = 0

var tower_purchase_buttons: Array[Button]

func _ready() -> void:	

	for tower_stat in tower_stats:
		var purchase_tower_button: Button = in_game_ui.tower_purchase_menu.add_tower_to_purchase(tower_stat)
		purchase_tower_button.pressed.connect(_attempt_purchase.bind(tower_stat))
		tower_purchase_buttons.append(purchase_tower_button)

	in_game_ui.next_wave_button.pressed.connect(trigger_next_wave)
	await next_level()

	return


func _process(delta: float) -> void:
	if game_state != GameState.PLAYING:
		return

	if monsters_spawned < total_monsters_to_spawn_this_wave():
		seconds_since_group_spawn += delta
		if seconds_since_group_spawn >= seconds_per_group():
			spawn_current_group()
		return
	else:
		if level.monster_trail.count_monsters == 0:
			victory()
			return

	return


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		exit_game()

	if event.is_action_released("debug_spawn_monster"):
		level.monster_trail.spawn_monster(Monster.MonsterVariation.LOLLY_GAGGER)
		
func next_level() -> void:
	current_level_num += 1
	money += 100
	if level:
		level.queue_free()
	level = levels[current_level_num - 1].instantiate()
	add_child(level)
	if not level.is_node_ready():
		await level.ready
	
	level.town.death_manager = self
	level.monster_trail.loot_handler = self
	game_over_screen.visible = false
	
	AudioManager.play_sound(AudioManager.sounds.round_start, 0.2)
	
	monsters_spawned = 0
	groups_spawned = 0
	wave = 1
	refresh_ui()
	game_state = GameState.PLAYING
	
	return


func current_spawn_pattern() -> MonsterSpawnPattern:
	return level.wave_spawn_patterns[wave - 1]

func total_monsters_to_spawn_this_wave() -> int:
	var spawn_pattern = current_spawn_pattern()

	return spawn_pattern.num_groups * len(spawn_pattern.group)

func seconds_per_group() -> float:
	var spawn_pattern = current_spawn_pattern()
	return spawn_pattern.within_seconds / spawn_pattern.num_groups


func choosing_tower_placement(tower_stat: TowerStats) -> void:
	print("placing: " + tower_stat.tower_name)
	AudioManager.play_sound(AudioManager.sounds.tower_purchase)

	var new_tower: Tower = TOWER.instantiate()
	new_tower.state = Tower.State.PLACING
	new_tower.stats = tower_stat
	new_tower.refunded.connect(refund_tower.bind(tower_stat))
	level.add_child(new_tower)

	return


func collect_loot(money_value: int) -> void:
	gain_money(money_value)


func exit_game() -> void:
	get_tree().quit()


func gain_money(amount: int) -> void:
	money += amount
	refresh_money()


func game_over() -> void:
	print("DIED")
	game_state = GameState.GAME_OVER
	game_over_screen.visible = true


func handle_death(died) -> void:
	if is_instance_of(died, Town):
		game_over()


func refresh_money() -> void:
	in_game_ui.set_money(money)


func refresh_monster_counts() -> void:
	in_game_ui.set_monster_progress(monsters_spawned, total_monsters_to_spawn_this_wave())
	in_game_ui.set_wave_number(wave)


func refresh_ui() -> void:
	refresh_money()
	refresh_monster_counts()


func refund_tower(tower_stat: TowerStats) -> void:
	game_state = GameState.PLAYING
	money += tower_stat.cost
	refresh_money()
	return


func spawn_current_group() -> void:
	seconds_since_group_spawn = 0.0

	for mv in current_spawn_pattern().group:
		level.monster_trail.spawn_monster(mv)
		monsters_spawned += 1

		refresh_monster_counts()

	groups_spawned += 1


func trigger_next_wave() -> void:
	monsters_spawned = 0
	
	in_game_ui.set_next_wave_button_enabled(false)
	level.town.stop_celebrating()
	
	if wave == len(level.wave_spawn_patterns):
		game_state = GameState.LEVEL_END
		next_level()
	else:	
		AudioManager.play_sound(AudioManager.sounds.round_start)
		wave += 1
	
		game_state = GameState.PLAYING
		
	refresh_monster_counts()
	return


func victory() -> void:
	print("victory!!")
	game_state = GameState.VICTORY
	in_game_ui.set_next_wave_button_enabled(true)
	level.town.start_celebrating()


func _attempt_purchase(tower_stat: TowerStats) -> void:
	if not game_state in [GameState.PLAYING, GameState.VICTORY]:
		return

	if tower_stat.cost > money:
		print("not enough money")
		return
	money -= tower_stat.cost
	print("purchased ", tower_stat.tower_name, " for $", str(tower_stat.cost))
	choosing_tower_placement(tower_stat)
	refresh_money()

	return
