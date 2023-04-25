class_name SetSingleTarget, "../icons/btleaf.svg" 
extends BTLeaf

export(int, "card_caster", "card_target") var target_source

export(int, "all", "self_only", "ally_only", "enemy_only", "self_ally", "self_enemy", "ally_enemy") var valid_targets

func _tick(agent: Node, blackboard: Blackboard) -> bool:
	blackboard.remove_data("targets")
	blackboard.remove_data("is_splash")
	blackboard.remove_data("is_inline")
	blackboard.remove_data("is_leftright")
	blackboard.remove_data("splash_target")
	blackboard.remove_data("target_params")
	
	match target_source:
		0:
			blackboard.set_data("targets",[agent.source_cell])
		1:
			blackboard.set_data("targets",[agent.target_cell])
	
	var targets = blackboard.get_data("targets")
	for target in targets:
		if target.unit != null:
			match valid_targets:
				0: # all targets are valid
					pass
				1: # only self is valid
					if target.unit != agent.card_caster:
						targets.erase(target)
				2: # only allies are valid
					if target.unit.team != agent.card_caster.team:
						targets.erase(target)
				3: # only enemies are valid
					if target.unit.team == agent.card_caster.team:
						targets.erase(target)
				4: # only self and allies are valid
					if target.unit != agent.card_caster or target.unit.team != agent.card_caster.team:
						targets.erase(target)
				5: # only self and enemies are valid
					if target.unit != agent.card_caster or target.unit.team == agent.card_caster.team:
						targets.erase(target)
				6: # only allies and enemies are valid
					if target.unit == agent.card_caster:
						targets.erase(target)
	blackboard.set_data("targets", targets)
	blackboard.set_data("target_params",["single"])
	return succeed()

func get_class() -> String:
	return "SetSingleTarget"
