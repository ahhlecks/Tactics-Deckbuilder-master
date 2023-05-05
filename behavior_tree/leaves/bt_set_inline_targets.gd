class_name SetInlineTargets, "../icons/btleaf.svg" 
extends BTLeaf


# Sets the targets for an inline attack. Only works when card variable "hexagonal" is set to true or min and max range is 1.
export(int) var inline_inner_range: int = 0
export(int) var inline_outer_range: int = 0
export(int) var inline_up_vertical_range: int = 0
export(int) var inline_down_vertical_range: int = 0
export(int, "all", "self_only", "ally_only", "enemy_only", "self_ally", "self_enemy", "ally_enemy") var valid_targets

func _tick(agent: Node, blackboard: Blackboard) -> bool:
	
	blackboard.remove_data("targets")
	blackboard.remove_data("is_splash")
	blackboard.remove_data("is_inline")
	blackboard.remove_data("is_leftright")
	blackboard.remove_data("splash_target")
	blackboard.remove_data("target_params")
	
	var startCell = agent.target_cell
	
	if startCell == null or startCell.get_class() != "HexCell":
		return fail()
	elif agent.hexagonal_targeting[agent.card_level] or (agent.card_min_range[agent.card_level] == 1 and agent.card_max_range[agent.card_level] == 1):
		var targets:Array = startCell.getInline(agent,inline_inner_range,inline_outer_range,inline_up_vertical_range,inline_down_vertical_range)
		var target_area:Array = targets.duplicate()
		for i in range(targets.size()-1,-1,-1):
			if targets[i].unit != null:
				match valid_targets:
					0: # all targets are valid
						pass
					1: # only self is valid
						if targets[i].unit != agent.card_caster:
							targets.erase(targets[i])
					2: # only allies are valid
						if targets[i].unit.team != agent.card_caster.team:
							targets.erase(targets[i])
					3: # only enemies are valid
						if targets[i].unit.team == agent.card_caster.team:
							targets.erase(targets[i])
					4: # only self and allies are valid
						if targets[i].unit != agent.card_caster or targets[i].unit.team != agent.card_caster.team:
							targets.erase(targets[i])
					5: # only self and enemies are valid
						if targets[i].unit != agent.card_caster or targets[i].unit.team == agent.card_caster.team:
							targets.erase(targets[i])
					6: # only allies and enemies are valid
						if targets[i].unit == agent.card_caster:
							targets.erase(targets[i])
			else:
				targets.erase(targets[i])
		blackboard.set_data("targets", target_area)
		blackboard.set_data("target_params", ["inline",inline_inner_range,inline_outer_range,inline_up_vertical_range,inline_down_vertical_range])
		blackboard.set_data("is_inline", true)
		if blackboard.has_data("utility_value_multiplier"):
			blackboard.set_data("utility_value_multiplier",blackboard.get_data("utility_value_multiplier") + targets.size())
		else:
			blackboard.set_data("utility_value_multiplier",targets.size())
		return succeed()
	else:
		return fail()

func get_class() -> String:
	return "SetInlineTargets"
