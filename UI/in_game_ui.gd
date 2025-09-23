class_name InGameUI extends Control

@onready var money_display: Label = %MoneyDisplay
@onready var tower_purchase_menu: TowerPurchaseMenu = %TowerPurchaseMenu
@onready var monster_spawned_progress_bar: ProgressBar = %MonsterSpawnedProgressBar
@onready var monsters_spawned_label: Label = %MonstersSpawnedLabel
@onready var wave_number_label: Label = %WaveNumberLabel
@onready var next_wave_button: Button = %NextWaveButton

func _ready() -> void:
	set_next_wave_button_enabled(false)

func set_money(money: int) -> void:
	money_display.text = "Money: $" + str(money)

func set_monster_progress(current: int, maximum: int) -> void:
	monster_spawned_progress_bar.max_value = maximum
	monster_spawned_progress_bar.value = current
	monsters_spawned_label.text = "Monsters Spawned: " + str(current) + " / " + str(maximum)
	return

func set_wave_number(wave: int) -> void:
	wave_number_label.text = "Wave: " + str(wave)

func set_next_wave_button_enabled(is_enabled: bool) -> void:
	next_wave_button.visible = is_enabled
	next_wave_button.disabled = not is_enabled
