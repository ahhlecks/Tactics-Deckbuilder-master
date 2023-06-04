class_name SetIntArg, "../icons/btleaf.svg" 
extends BTLeaf


# Requires two int arguments in the blackboard "int_arg1" and "int_arg2"
# Will compare int_arg1 to int_arg2 and fail or succeed accordingly

export(int, "integer",
	"card_caster",
	"card_target",
	"card_variable") var int_source

export(String, "none", "int_arg1", "int_arg2") var int_arg

export(int) var integer: int = 0

export(String, "none",
	"current_health",
	"max_health",
	"current_action_points",
	"max_action_points",
	"current_movement_points",
	"max_movement_points",
	"current_jump_points",
	"max_jump_points",
	"base_speed",
	"current_speed",
	"base_physical_evasion",
	"current_physical_evasion",
	"base_magic_evasion",
	"current_magic_evasion",
	"base_physical_accuracy",
	"current_physical_accuracy",
	"base_magic_accuracy",
	"current_magic_accuracy",
	"max_draw_points",
	"current_draw_points",
	"base_crit_damage",
	"current_crit_damage",
	"elevation",
	"experience",
	"level",
	"block",
	"strength",
	"willpower",
	"unit_deck_size",
	"unit_hand_size",
	"unit_discard_size",
	"unit_consumed_size") var unit_variable:String

export(String, "none",
	"action_cost",
	"card_level",
	"upgrade_cost",
	"delay",
	"rarity",
	"card_min_range",
	"card_max_range",
	"card_up_vertical_range",
	"card_down_vertical_range",
	"card_attack") var card_variable:String

export(int, "sum_of_targets", "highest_target_value", "lowest_target_value") var target_calculation

func _tick(agent: Node, blackboard: Blackboard) -> bool:
	if int_arg != "none":
		match int_source:
			"integer":
				blackboard.set_data(int_arg, integer)
				return succeed()
			"card_caster":
				if agent.card_caster != null and unit_variable != "none":
					match unit_variable:
						"unit_deck_size":
							blackboard.set_data(int_arg, agent.card_caster.active_deck.size())
						"unit_hand_size":
							blackboard.set_data(int_arg, agent.card_caster.hand_deck.size())
						"unit_discard_size":
							blackboard.set_data(int_arg, agent.card_caster.discard_deck.size())
						"unit_consumed_size":
							blackboard.set_data(int_arg, agent.card_caster.consumed_deck.size())
						_:
							blackboard.set_data(int_arg, agent.card_caster.get(unit_variable))
					return succeed()
				else:
					return fail()
			"card_target":
				if agent.card_owner != null and unit_variable != "none":
					if !blackboard.has_data("targets") and agent.target_cell.unit != null:
							match unit_variable:
								"unit_deck_size":
									blackboard.set_data(int_arg, agent.target_cell.unit.active_deck.size())
								"unit_hand_size":
									blackboard.set_data(int_arg, agent.target_cell.unit.hand_deck.size())
								"unit_discard_size":
									blackboard.set_data(int_arg, agent.target_cell.unit.discard_deck.size())
								"unit_consumed_size":
									blackboard.set_data(int_arg, agent.target_cell.unit.consumed_deck.size())
								_:
									blackboard.set_data(int_arg, agent.target_cell.unit.get(unit_variable))
					else:
						var int_array = []
						var total_var:int = 0
						var targets = blackboard.get_data("targets")
						if unit_variable != "none":
							match target_calculation:
								0: #sum of targets
									for target in targets:
										if target.unit != null:
											match unit_variable:
												"unit_deck_size":
													total_var += target.unit.active_deck.size()
												"unit_hand_size":
													total_var += target.unit.hand_deck.size()
												"unit_discard_size":
													total_var += target.unit.discard_deck.size()
												"unit_consumed_size":
													total_var += target.unit.consumed_deck.size()
												_:
													total_var += target.unit.get(unit_variable)
									blackboard.set_data(int_arg, total_var)
									return succeed()
								1: #highest target value
									for target in targets:
										if target.unit != null:
											match unit_variable:
												"unit_deck_size":
													int_array.append(target.unit.active_deck.size())
												"unit_hand_size":
													int_array.append(target.unit.hand_deck.size())
												"unit_discard_size":
													int_array.append(target.unit.discard_deck.size())
												"unit_consumed_size":
													int_array.append(target.unit.consumed_deck.size())
												_:
													int_array.append(target.unit.get(unit_variable))
									if int_array.size() > 0:
										blackboard.set_data(int_arg, highestValue(int_array))
										return succeed()
								2: #lowest target value
									for target in targets:
										if target.unit != null:
											match unit_variable:
												"unit_deck_size":
													int_array.append(target.unit.active_deck.size())
												"unit_hand_size":
													int_array.append(target.unit.hand_deck.size())
												"unit_discard_size":
													int_array.append(target.unit.discard_deck.size())
												"unit_consumed_size":
													int_array.append(target.unit.consumed_deck.size())
												_:
													int_array.append(target.unit.get(unit_variable))
									if int_array.size() > 0:
										blackboard.set_data(int_arg, lowestValue(int_array))
										return succeed()
			"card_variable":
				if card_variable != "none":
					blackboard.set_data(int_arg, agent.get(card_variable))
					return succeed()
	return succeed()

func highestValue(values:Array) -> int:
	values.sort_custom(ValuesSorter, "sort_descending")
	return values[0]

func lowestValue(values:Array) -> int:
	values.sort_custom(ValuesSorter, "sort_ascending")
	return values[0]

class ValuesSorter:
	static func sort_descending(a, b):
		if a > b:
			return true
		return false
	static func sort_ascending(a, b):
		if a < b:
			return true
		return false

func get_class() -> String:
	return "BTSetIntArg"
