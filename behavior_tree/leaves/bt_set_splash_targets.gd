class_name SetSplashTargets, "../icons/btleaf.svg" 
extends BTLeaf


# Sets the targets for a splash attack.
export(int, "card_caster", "card_target") var target_source
export(int) var splash_min_range: int = 0
export(int) var splash_max_range: int = 0
export(int) var splash_up_vertical_range: int = 0
export(int) var splash_down_vertical_range: int = 0
export(int, "all", "self_only", "ally_only", "enemy_only", "self_ally", "self_enemy", "ally_enemy") var valid_targets

func _tick(agent: Node, blackboard: Blackboard) -> bool:
	blackboard.remove_data("targets")
	blackboard.remove_data("is_splash")
	blackboard.remove_data("is_inline")
	blackboard.remove_data("is_leftright")
	blackboard.remove_data("splash_target")
	blackboard.remove_data("target_params")
	
	var startCell
	match target_source:
		0:
			startCell = agent.source_cell
		1:
			startCell = agent.target_cell
	if startCell == null or startCell.get_class() != "HexCell":
		return fail()
	else:
		var targets:Array = startCell.getSplash(agent,splash_min_range,splash_max_range,splash_up_vertical_range,splash_down_vertical_range)
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
		blackboard.set_data("targets",target_area)
		blackboard.set_data("target_params",["splash",splash_min_range,splash_max_range,splash_up_vertical_range,splash_down_vertical_range])
		blackboard.set_data("is_splash",true)
		if blackboard.has_data("utility_value_multiplier"):
			blackboard.set_data("utility_value_multiplier",blackboard.get_data("utility_value_multiplier") + targets.size())
		else:
			blackboard.set_data("utility_value_multiplier",targets.size())
	return succeed()

func get_class() -> String:
	return "SetSplashTargets"
