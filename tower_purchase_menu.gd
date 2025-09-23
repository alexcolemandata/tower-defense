class_name TowerPurchaseMenu extends VBoxContainer
	
func add_tower_to_purchase(tower_name: String, cost: int) -> Button:
	var new_button = Button.new()
	new_button.text = tower_name + ": $" + str(cost)
	add_child(new_button)
	
	return new_button
