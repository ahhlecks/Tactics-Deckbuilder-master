class_name IsUnitLevel, "../icons/btdecorator.svg"
extends BTDecorator


# Requires "targets" from the blackboard to execute where "targets" is an Array of HexCells
# Attack value can be set here if blackboard doesn't have a pre-defined "attack_value"

export(int) var unit_level: int = 1

# Override this in your extended script
func _tick(agent: Node, blackboard: Blackboard) -> bool:
	if unit_level == agent.card_owner.level:
		result = bt_child.tick(agent, blackboard)
		if result is GDScriptFunctionState:
			result = yield(result, "completed")
		return set_state(bt_child)
	else:
		return fail()

func get_class() -> String:
	return "IsUnitLevel"
