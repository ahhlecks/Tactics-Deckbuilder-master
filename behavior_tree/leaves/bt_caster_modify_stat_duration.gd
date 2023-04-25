class_name CasterModifyStatDuration, "../icons/btleaf.svg" 
extends BTLeaf

#

export(int, "assign", "add", "subtract", "multiply", "divide") var operation

export(String, "none", "int_arg1", "int_arg2") var int_arg

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
	"base_crit_chance",
	"current_crit_chance",
	"elevation",
	"experience",
	"level",
	"block",
	"deflect",
	"strength",
	"willpower") var stat:String

export(int) var stat_value: int = 0

export(int) var duration: int = 1
var delta:float = 0
#export(int, "sum_of_targets", "highest_target_value", "lowest_target_value") var target_calculation

func _tick(agent: Node, blackboard: Blackboard) -> bool:
#	blackboard.set_data("add_attack_value",attack_value)
#	return succeed()
	if int_arg == "int_arg1":
		if blackboard.has_data("int_arg1"):
			stat_value = blackboard.get_data("int_arg1")
	if int_arg == "int_arg2":
		if blackboard.has_data("int_arg2"):
			stat_value = blackboard.get_data("int_arg2")
	if agent.behavior_tree.is_real:
		var new_status
		if operation == 0 and stat_value > 0:
			new_status = ["StatChange", duration, str(stat) + " " + operationToString(operation) + " " + str(stat_value), "Buff", stat, stat_value, operation]
		elif operation == 1 or operation == 3:
			new_status = ["StatChange", duration, str(stat) + " " + operationToString(operation) + " " + str(stat_value), "Buff", stat, stat_value, operation]
		else:
			new_status = ["StatChange", duration, str(stat) + " " + operationToString(operation) + " " + str(stat_value), "Debuff", stat, stat_value, operation]
		agent.card_caster.statuses.append(new_status)
		
		match operation:
			0:
				agent.card_caster.set(stat,stat_value)
			1:
				agent.card_caster.set(stat, agent.card_caster.get(stat) + stat_value)
				delta = (agent.card_caster.get(stat) + stat_value) - agent.card_caster.get(stat)
			2:
				agent.card_caster.set(stat,agent.card_caster.get(stat) - stat_value)
				delta = (agent.card_caster.get(stat) - stat_value) - agent.card_caster.get(stat)
			3:
				agent.card_caster.set(stat, agent.card_caster.get(stat) * stat_value)
				delta = (agent.card_caster.get(stat) * stat_value) - agent.card_caster.get(stat)
			4:
				if stat_value != 0:
					agent.card_caster.set(stat, agent.card_caster.get(stat) / stat_value)
					delta = (agent.card_caster.get(stat) / stat_value) - agent.card_caster.get(stat)
	else:
		match operation:
			0:
				pass
			1:
				delta = (agent.card_caster.get(stat) + stat_value) - agent.card_caster.get(stat)
			2:
				delta = (agent.card_caster.get(stat) - stat_value) - agent.card_caster.get(stat)
			3:
				delta = (agent.card_caster.get(stat) * stat_value) - agent.card_caster.get(stat)
			4:
				if stat_value != 0:
					delta = (agent.card_caster.get(stat) / stat_value) - agent.card_caster.get(stat)
	if blackboard.has_data("utility_value"):
		blackboard.set_data("utility_value",blackboard.get_data("utility_value") + delta)
	else:
		blackboard.set_data("utility_value",delta)
	return succeed()

func operationToString(operation) -> String:
	match operation:
		0:
			return "="
		1:
			return "+"
		2:
			return "-"
		3:
			return "x"
		4:
			return "/"
	return " "

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
	return "CasterModifyStatDuration"
