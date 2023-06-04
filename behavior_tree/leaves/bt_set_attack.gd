class_name SetAttack, "../icons/btleaf.svg" 
extends BTLeaf


#DEPRECATED#

# "targets" default to single target if blackboard doesn't have a pre-defined "targets" array
# "attack_value" can be set here if blackboard doesn't have a pre-defined "attack_value" integer

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

#"integer",
#"card_caster",
#"card_target",
#"card_variable,

func _tick(agent: Node, blackboard: Blackboard) -> bool:
	match int_source:
		0:
			if attack_value == 0:
				blackboard.set_data("attack_value", agent.card_attack[agent.card_level])
			else:
				blackboard.set_data("attack_value", attack_value)
			return succeed()
		1:
			if agent.card_caster != null and unit_variable != "none":
				blackboard.set_data("attack_value", agent.card_caster.get(unit_variable))
				return succeed()
		2:
			if !blackboard.has_data("targets") and unit_variable != "none":
				if agent.target_cell.unit != null:
					blackboard.set_data("attack_value", agent.target_cell.unit.get(unit_variable))
					return succeed()
			else:
				var int_array = []
				var total_attack:int = 0
				var targets = blackboard.get_data("targets")
				match target_calculation:
					0:
						for target in targets:
							if target.unit != null and unit_variable != "none":
								total_attack += target.unit.get(unit_variable)
						blackboard.set_data("attack_value", total_attack)
						return succeed()
					1:
						for target in targets:
							if target.unit != null and unit_variable != "none":
								int_array.append(target.unit.get(unit_variable))
						blackboard.set_data("attack_value", highestValue(int_array))
						return succeed()
					2:
						for target in targets:
							if target.unit != null and unit_variable != "none":
								int_array.append(target.unit.get(unit_variable))
						blackboard.set_data("attack_value", lowestValue(int_array))
						return succeed()
		3: 
			blackboard.set_data("attack_value", agent.get(card_variable))
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
	return "SetAttack"
