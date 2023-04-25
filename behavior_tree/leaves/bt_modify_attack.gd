class_name ModifyAttack, "../icons/btleaf.svg" 
extends BTLeaf

#DEPRECATED#

export(int, "add", "subtract", "multiply", "divide") var operation

export(int, "integer", "card_caster", "card_target", "card_variable") var int_source

export(int) var attack_value: int = 0

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
	"deflect",
	"strength",
	"willpower",
	"unit_deck_size",
	"unit_hand_size",
	"unit_discard_size",
	"unit_consumed_size",
	"int_arg1",
	"int_arg2") var unit_variable:String

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
	"card_attack",
	"int_arg1",
	"int_arg2") var card_variable:String

export(int, "sum_of_targets", "highest_target_value", "lowest_target_value") var target_calculation

func _tick(agent: Node, blackboard: Blackboard) -> bool:
#	blackboard.set_data("add_attack_value",attack_value)
#	return succeed()
	var original_attack:int
	if blackboard.has_data("attack_value"):
		original_attack = blackboard.get_data("attack_value")
	else:
		original_attack = agent.card_attack[agent.card_level]
	match int_source:
		0:
			match operation:
				0:
					blackboard.set_data("attack_value", original_attack + attack_value)
					return succeed()
				1:
					blackboard.set_data("attack_value", original_attack - attack_value)
					return succeed()
				2:
					blackboard.set_data("attack_value", original_attack * attack_value)
					return succeed()
				3:
					if attack_value != 0:
						blackboard.set_data("attack_value", int(round(float(original_attack) / float(attack_value))))
						return succeed()
		1:
			if agent.card_caster != null and unit_variable != "none":
				match operation:
					0:
						blackboard.set_data("attack_value", original_attack + agent.card_caster.get(unit_variable))
						return succeed()
					1:
						blackboard.set_data("attack_value", original_attack - agent.card_caster.get(unit_variable))
						return succeed()
					2:
						blackboard.set_data("attack_value", original_attack * agent.card_caster.get(unit_variable))
						return succeed()
					3:
						if agent.card_caster.get(unit_variable) != 0:
							blackboard.set_data("attack_value", int(round(float(original_attack) / float(agent.card_caster.get(unit_variable)))))
							return succeed()
		2:
			if agent.card_owner != null and unit_variable != "none":
				if !blackboard.has_data("targets") and agent.target_cell.unit != null:
					match operation:
						0:
							blackboard.set_data("attack_value", original_attack + agent.target_cell.unit.get(unit_variable))
							return succeed()
						1:
							blackboard.set_data("attack_value", original_attack - agent.target_cell.unit.get(unit_variable))
							return succeed()
						2:
							blackboard.set_data("attack_value", original_attack * agent.target_cell.unit.get(unit_variable))
							return succeed()
						3:
							if agent.target_cell.unit.get(unit_variable) != 0:
								blackboard.set_data("attack_value", int(round(float(original_attack) / float(agent.target_cell.unit.get(unit_variable)))))
								return succeed()
				else:
					var int_array = []
					var total_attack:int = 0
					var targets = blackboard.get_data("targets")
					if unit_variable != "none":
						match target_calculation:
							0: #sum of targets
								match operation:
									0:
										for target in targets:
											if target.unit != null:
												total_attack += target.unit.get(unit_variable)
										blackboard.set_data("attack_value", original_attack + total_attack)
										return succeed()
									1:
										for target in targets:
											if target.unit != null:
												total_attack += target.unit.get(unit_variable)
										blackboard.set_data("attack_value", original_attack - total_attack)
										return succeed()
									2:
										for target in targets:
											if target.unit != null:
												total_attack += target.unit.get(unit_variable)
										blackboard.set_data("attack_value", original_attack * total_attack)
										return succeed()
									3:
										for target in targets:
											if target.unit != null:
												total_attack += target.unit.get(unit_variable)
										if agent.target_cell.unit.get(unit_variable) != 0:
											blackboard.set_data("attack_value", int(round(float(original_attack) / float(total_attack))))
											return succeed()
							1: #highest target value
								match operation:
									0:
										for target in targets:
											if target.unit != null:
												int_array.append(target.unit.get(unit_variable))
										if int_array.size() > 0:
											blackboard.set_data("attack_value", original_attack + highestValue(int_array))
											return succeed()
									1:
										for target in targets:
											if target.unit != null:
												int_array.append(target.unit.get(unit_variable))
										if int_array.size() > 0:
											blackboard.set_data("attack_value", original_attack - highestValue(int_array))
											return succeed()
									2:
										for target in targets:
											if target.unit != null:
												int_array.append(target.unit.get(unit_variable))
										if int_array.size() > 0:
											blackboard.set_data("attack_value", original_attack * highestValue(int_array))
											return succeed()
									3:
										for target in targets:
											if target.unit != null:
												int_array.append(target.unit.get(unit_variable))
										if agent.target_cell.unit.get(unit_variable) != 0:
											if int_array.size() > 0:
												blackboard.set_data("attack_value", int(round(float(original_attack) / float(highestValue(int_array)))))
												return succeed()
							2: #lowest target value
								match operation:
									0:
										for target in targets:
											if target.unit != null:
												int_array.append(target.unit.get(unit_variable))
										if int_array.size() > 0:
											blackboard.set_data("attack_value", original_attack + lowestValue(int_array))
											return succeed()
									1:
										for target in targets:
											if target.unit != null:
												int_array.append(target.unit.get(unit_variable))
										if int_array.size() > 0:
											blackboard.set_data("attack_value", original_attack - lowestValue(int_array))
											return succeed()
									2:
										for target in targets:
											if target.unit != null:
												int_array.append(target.unit.get(unit_variable))
										if int_array.size() > 0:
											blackboard.set_data("attack_value", original_attack * lowestValue(int_array))
											return succeed()
									3:
										for target in targets:
											if target.unit != null:
												int_array.append(target.unit.get(unit_variable))
										if agent.target_cell.unit.get(unit_variable) != 0:
											if int_array.size() > 0:
												blackboard.set_data("attack_value", int(round(float(original_attack) / float(lowestValue(int_array)))))
												return succeed()
		3: 
			match operation:
						0:
							blackboard.set_data("attack_value", original_attack + agent.get(card_variable))
							return succeed()
						1:
							blackboard.set_data("attack_value", original_attack - agent.get(card_variable))
							return succeed()
						2:
							blackboard.set_data("attack_value", original_attack * agent.get(card_variable))
							return succeed()
						3:
							if agent.get(card_variable) != 0:
								blackboard.set_data("attack_value", int(round(float(original_attack) / float(agent.get(card_variable)))))
								return succeed()
	return fail()

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
	return "ModifyAttack"
