class_name CardModifyStat, "../icons/btleaf.svg" 
extends BTLeaf

#

export(int, "assign", "add", "subtract", "multiply", "divide") var operation

export(String) var stat:String

export(int) var stat_value: int = 0

export(String, "none", "int_arg1", "int_arg2") var int_arg

#export(int, "sum_of_targets", "highest_target_value", "lowest_target_value") var target_calculation

func _tick(agent: Node, blackboard: Blackboard) -> bool:
	if int_arg == "int_arg1":
		if blackboard.has_data("int_arg1"):
			stat_value = blackboard.get_data("int_arg1")
	if int_arg == "int_arg2":
		if blackboard.has_data("int_arg2"):
			stat_value = blackboard.get_data("int_arg2")
	if agent.behavior_tree.is_real:
		var has_modifier:bool = false
		for card_values in agent.original_card_values:
			if card_values[0] == stat:
				has_modifier = true
		if !has_modifier:
			var old_stat = agent[stat]
			agent.original_card_values.append([stat,old_stat])
		match operation:
			0:
				match stat:
					"card_name":
						agent.set(stat,stat_value)
					"card_class":
						agent.set(stat,stat_value)
					"card_level", "card_type", "rarity":
						agent.set(stat,stat_value)
					_:
						var new_stat = agent.get(stat)
						new_stat[agent.card_level] = stat_value
						agent.set(stat, new_stat)
			1:
				
				match stat:
					"card_name":
						agent.set(stat,stat_value)
					"card_class":
						agent.set(stat,stat_value)
					"card_level", "card_type", "rarity":
						agent.set(stat, agent.get(stat) + stat_value)
					"item_type":
						var new_stat = agent.get(stat)
						new_stat[agent.card_level].append(stat_value)
					_:
						var new_stat = agent.get(stat)
						new_stat[agent.card_level] += stat_value
						agent.set(stat, new_stat)
			2:
				match stat:
					"card_name":
						agent.set(stat,stat_value)
					"card_class":
						agent.set(stat,stat_value)
					"card_level", "card_type", "rarity":
						agent.set(stat, agent.get(stat) - stat_value)
					"item_type":
						var new_stat = agent.get(stat)
						new_stat[agent.card_level].erase(stat_value)
					_:
						var new_stat = agent.get(stat)
						new_stat[agent.card_level] -= stat_value
						agent.set(stat, new_stat)
			3:
				match stat:
					"card_name":
						agent.set(stat,stat_value)
					"card_class":
						agent.set(stat,stat_value)
					"card_level", "card_type", "rarity":
						agent.set(stat, agent.get(stat) * stat_value)
					"item_type":
						pass
					_:
						var new_stat = agent.get(stat)
						new_stat[agent.card_level] *= stat_value
						agent.set(stat, new_stat)
			4:
				if stat_value == 0:
					stat_value = 1
				match stat:
					"card_name":
						agent.set(stat,stat_value)
					"card_class":
						agent.set(stat,stat_value)
					"card_level", "card_type", "rarity":
						agent.set(stat, agent.get(stat) / stat_value)
					"item_type":
						pass
					_:
						var new_stat = agent.get(stat)
						new_stat[agent.card_level] /= stat_value
						agent.set(stat, new_stat)
#			agent.card_caster.unit_owner.updateCardGUI(agent.card_caster, agent.export_vars())
	if blackboard.has_data("utility_value"):
		blackboard.set_data("utility_value",blackboard.get_data("utility_value") + stat_value)
	else:
		blackboard.set_data("utility_value",stat_value)
	return succeed()

func get_class() -> String:
	return "CardModifyStat"
