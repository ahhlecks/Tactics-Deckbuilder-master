class_name TargetAddCard, "../icons/btleaf.svg" 
extends BTLeaf

func get_class() -> String: return "TargetAddCard"

export(int) var add_amount: int = 1

var card_name:String = ""

var card_level:int = 0

export(int, "active_deck", "hand_deck", "discard_deck", "consumed_deck") var deck

var deck_name:String = "active_deck"

export(int, "all", "self_only", "ally_only", "enemy_only", "self_ally", "self_enemy", "ally_enemy") var valid_targets

var targets:Array

func _tick(agent: Node, blackboard: Blackboard) -> bool:
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
	if agent.behavior_tree.is_real:
		match deck:
			0:
				deck_name = "active_deck"
			1:
				deck_name = "hand_deck"
			2:
				deck_name = "discard_deck"
			3:
				deck_name = "consumed_deck"
		for target in targets:
			if target.unit != null and target.unit.current_health > 0:
				if target.unit == agent.card_caster:
					agent.card_caster.unit_owner.unitAddCards(agent.card_caster, add_amount, deck_name, card_name, card_level, true)
				elif target.unit != null:
					target.unit.unit_owner.unitAddCards(target.unit, add_amount, deck_name, card_name, card_level, false)
	if blackboard.has_data("utility_value"):
		blackboard.set_data("utility_value",blackboard.get_data("utility_value") + add_amount*targets.size()*20)
	else:
		blackboard.set_data("utility_value",add_amount*targets.size()*20)
	return succeed()
