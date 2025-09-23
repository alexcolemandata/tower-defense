class_name InGameUI extends Control

@onready var money_display: Label = %MoneyDisplay
@onready var tower_purchase_menu: TowerPurchaseMenu = %TowerPurchaseMenu
@onready var monster_spawned_progress_bar: ProgressBar = %MonsterSpawnedProgressBar
@onready var monsters_spawned_label: Label = %MonstersSpawnedLabel

func set_money(money: int) -> void:
	money_display.text = "Money: $" + str(money)

func set_monster_progress(current: int, maximum: int) -> void:
	monster_spawned_progress_bar.max_value = maximum
	monster_spawned_progress_bar.value = current
	monsters_spawned_label.text = "Monsters Spawned: " + str(current) + " / " + str(maximum)
	return
