class_name TargetModifyStat, "../icons/btleaf.svg" 
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

export(int, "all", "self_only", "ally_only", "enemy_only", "self_ally", "self_enemy", "ally_enemy") var valid_targets

var targets:Array
var delta:float = 0.0

#export(int, "sum_of_targets", "highest_target_value", "lowest_target_value") var target_calculation

func _tick(agent: Node, blackboard: Blackboard) -> bool:
	if int_arg == "int_arg1":
		if blackboard.has_data("int_arg1"):
			stat_value = blackboard.get_data("int_arg1")
	if int_arg == "int_arg2":
		if blackboard.has_data("int_arg2"):
			stat_value = blackboard.get_data("int_arg2")
	if blackboard.has_data("targets"):
		targets = blackboard.get_data("targets")
	elif agent.target_cell == null:
		return fail()
	else:
		blackboard.set_data("targets", [agent.target_cell])
		targets = [agent.target_cell]
	for target in targets:
		if target.unit != null:
			match valid_targets:
				0: # all targets are valid
					pass
				1: # only self is valid
					if target.unit != agent.card_caster:
						targets.erase(target)
				2: # only allies are valid
					if target.unit.team != target.unit.team:
						targets.erase(target)
				3: # only enemies are valid
					if target.unit.team == target.unit.team:
						targets.erase(target)
				4: # only self and allies are valid
					if target.unit != agent.card_caster or target.unit.team != target.unit.team:
						targets.erase(target)
				5: # only self and enemies are valid
					if target.unit != agent.card_caster or target.unit.team == target.unit.team:
						targets.erase(target)
				6: # only allies and enemies are valid
					if target.unit == agent.card_caster:
						targets.erase(target)
						
	if agent.behavior_tree.is_real:
		for target in targets:
			if target.unit != null and target.unit.current_health > 0:
				match operation:
					0:
						target.unit.set(stat,stat_value)
					1:
						target.unit.set(stat, target.unit.get(stat) + stat_value)
						delta = (target.unit.get(stat) + stat_value) - target.unit.get(stat)
					2:
						target.unit.set(stat, target.unit.get(stat) - stat_value)
						delta = (target.unit.get(stat) - stat_value) - target.unit.get(stat)
					3:
						target.unit.set(stat, target.unit.get(stat) * stat_value)
						delta = (target.unit.get(stat) * stat_value) - target.unit.get(stat)
					4:
						if stat_value != 0:
							target.unit.set(stat, target.unit.get(stat) / stat_value)
							delta = (target.unit.get(stat) / stat_value) - target.unit.get(stat)
	else:
		for target in targets:
			if target.unit != null and target.unit.current_health > 0:
				var alliance:String
				if target.unit.team != agent.card_caster.team:
					alliance = "enemy_stat_"
				else:
					alliance = "ally_stat_"
				match operation:
					0:
						blackboard.set_data(alliance + stat, stat_value)
					1:
						blackboard.set_data(alliance + stat, target.unit.get(stat) + stat_value)
						delta = (target.unit.get(stat) + stat_value) - target.unit.get(stat)
					2:
						blackboard.set_data(alliance + stat, target.unit.get(stat) - stat_value)
						delta = (target.unit.get(stat) - stat_value) - target.unit.get(stat)
					3:
						blackboard.set_data(target.unit.id + stat, target.unit.get(stat) * stat_value)
						delta = (target.unit.get(stat) * stat_value) - target.unit.get(stat)
					4:
						if stat_value != 0:
							blackboard.set_data(target.unit.id + stat, target.unit.get(stat) / stat_value)
							delta = (target.unit.get(stat) / stat_value) - target.unit.get(stat)
	if blackboard.has_data("utility_value"):
		blackboard.set_data("utility_value",blackboard.get_data("utility_value") + targets.size()*delta/2)
	else:
		blackboard.set_data("utility_value",targets.size()*delta/2)
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
	return "TargetModifyStat"
