class_name BTCheckLastCard, "../icons/btnode.svg" 
extends BTDecorator


# Requires two int arguments in the blackboard "int_arg1" and "int_arg2"
# Will compare int_arg1 to int_arg2 and fail or succeed accordingly
# Mode will determine if all checks or just one check need to satisfy the condition when comparing arrays

export(int, "card_caster", "target_unit") var card_source
export(int, "one_target", "all_targets") var target_condition
export(String) var card


func _tick(agent: Node, blackboard: Blackboard) -> bool:
	match card_source:
		0:
			if agent.card_caster != null:
				if agent.card_caster.cards_played.size() > 0:
					if agent.card_caster.cards_played.back().card_name == card:
						result = bt_child.tick(agent, blackboard)
						if result is GDScriptFunctionState:
							result = yield(result, "completed")
						return set_state(bt_child)
		1:
			if !blackboard.has_data("targets"):
				if agent.target_unit == null:
					return fail()
				if agent.target_unit.get_class() != "HexUnit":
					return fail()
				else:
					if agent.target_unit.cards_played.size() > 0:
						if agent.target_unit.cards_played.back().card_name == card:
							result = bt_child.tick(agent, blackboard)
							if result is GDScriptFunctionState:
								result = yield(result, "completed")
							return set_state(bt_child)
			else:
				if target_condition == 0:
					for target in blackboard.get_data("targets"):
						if target.unit.cards_played.size() > 0:
							if agent.target_unit.cards_played.back().card_name == card:
								result = bt_child.tick(agent, blackboard)
								if result is GDScriptFunctionState:
									result = yield(result, "completed")
								return set_state(bt_child)
				if target_condition == 1:
					for target in blackboard.get_data("targets"):
						if target.unit.cards_played.size() > 0:
							if agent.target_unit.cards_played.back().card_name != card:
								return fail()
					result = bt_child.tick(agent, blackboard)
					if result is GDScriptFunctionState:
						result = yield(result, "completed")
					return set_state(bt_child)
	return fail()

func get_class() -> String:
	return "BTCheckLastCard"
