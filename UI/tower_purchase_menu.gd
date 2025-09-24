class_name TowerPurchaseMenu
extends VBoxContainer


func add_tower_to_purchase(tower_stat: TowerStats) -> Button:
	var new_button = Button.new()
	new_button.text = tower_stat.tower_name + ": $" + str(tower_stat.cost)
	add_child(new_button)

	return new_button
