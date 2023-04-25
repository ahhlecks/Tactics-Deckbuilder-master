class_name HandModifyStat, "../icons/btleaf.svg" 
extends BTLeaf

#

export(int, "assign", "add", "subtract", "multiply", "divide") var operation

export(String, "none",
	"card_name",
	"card_class",
	"action_costs",
	"card_level",
	"upgrade_costs",
	"card_type",
	"can_attack", #7
	"can_defend", #8
	"need_los", #9
	"is_homing", #10
	"has_combo", #11
	"is_unblockable", #12
	"is_undeflectable", #13
	"is_consumable", #14
	"has_counter", #15
	"has_reflex", #16
	"self_statuses",
	"target_statuses",
	"delay",
	"rarity",
	"card_min_range",
	"card_max_range",
	"card_up_vertical_range",
	"card_down_vertical_range",
	"card_attack",
	"elements") var stat:String

export(int) var stat_value: int = 0

export(String, "none",
	"card_name",
	"card_class",
	"action_costs",
	"card_level",
	"upgrade_costs",
	"card_type",
	"can_attack", #7
	"can_defend", #8
	"need_los", #9
	"is_homing", #10
	"has_combo", #11
	"is_unblockable", #12
	"is_undeflectable", #13
	"is_consumable", #14
	"has_counter", #15
	"has_reflex", #16
	"self_statuses",
	"target_statuses",
	"delay",
	"rarity",
	"card_min_range",
	"card_max_range",
	"card_up_vertical_range",
	"card_down_vertical_range",
	"card_attack",
	"elements") var stat_requirement:String

export(int) var stat_requirement_value: int = 0

export(String, "none", "int_arg1", "int_arg2") var int_arg

var valid_cards:Array

#export(int, "sum_of_targets", "highest_target_value", "lowest_target_value") var target_calculation

func _tick(agent: Node, blackboard: Blackboard) -> bool:
	if int_arg == "int_arg1":
		if blackboard.has_data("int_arg1"):
			stat_value = blackboard.get_data("int_arg1")
	if int_arg == "int_arg2":
		if blackboard.has_data("int_arg2"):
			stat_value = blackboard.get_data("int_arg2")
	if agent.behavior_tree.is_real:
		for card in agent.card_caster.hand_deck:
			if stat_requirement != "none":
				if card.get(stat_requirement) == stat_requirement_value:
					valid_cards.append(card)
			else:
				valid_cards = agent.card_caster.hand_deck
		for card in valid_cards:
			var has_modifier:bool = false
			for card_values in card.original_card_values:
				if card_values[0] == stat:
					has_modifier = true
			if !has_modifier:
				var old_stat = card[stat].duplicate()
				card.original_card_values.append([stat,old_stat])
			match operation:
				0:
					match stat:
						"card_name":
							card[stat] = stat_value
						"card_class":
							card[stat] = stat_value
						"card_level", "card_type", "rarity":
							card[stat] = stat_value
						_:
							card[stat][card.card_level] = stat_value
				1:
					
					match stat:
						"card_name":
							card[stat] = stat_value
						"card_class":
							card[stat] = stat_value
						"card_level", "card_type", "rarity":
							card[stat] += stat_value
						_:
							card[stat][card.card_level] += stat_value
				2:
					match stat:
						"card_name":
							card[stat] = stat_value
						"card_class":
							card[stat] = stat_value
						"card_level", "card_type", "rarity":
							card[stat] -= stat_value
						_:
							card[stat][card.card_level] -= stat_value
				3:
					match stat:
						"card_name":
							card[stat] = stat_value
						"card_class":
							card[stat] = stat_value
						"card_level", "card_type", "rarity":
							card[stat] *= stat_value
						_:
							card[stat][card.card_level] *= stat_value
				4:
					if stat_value == 0:
						stat_value = 1
					match stat:
						"card_name":
							card[stat] = stat_value
						"card_class":
							card[stat] = stat_value
						"card_level", "card_type", "rarity":
							card[stat] /= stat_value
						_:
							card[stat][card.card_level] /= stat_value
			agent.card_caster.unit_owner.updateCardGUI(agent.card_caster, card)
	if blackboard.has_data("utility_value"):
		blackboard.set_data("utility_value",blackboard.get_data("utility_value") + valid_cards.size()*stat_value)
	else:
		blackboard.set_data("utility_value",valid_cards.size()*stat_value)
	return succeed()

func get_class() -> String:
	return "HandModifyStat"
