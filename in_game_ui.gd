class_name InGameUI extends Control

@onready var money_display: Label = %MoneyDisplay
@onready var tower_purchase_menu: TowerPurchaseMenu = $Panel/LeftPanel/TowerPurchaseMenu

func set_money(money: int) -> void:
	money_display.text = "Money: $" + str(money)
	
