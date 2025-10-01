class_name SpellList extends VBoxContainer

func add_spell_to_cast(spell_stats: SpellStats) -> Button:
	var new_button = Button.new()
	new_button.text = spell_stats.spell_name + ": " + str(spell_stats.mp_cost) + " MP"

	add_child(new_button)
	return new_button
