class_name IsCardLevel, "../icons/btdecorator.svg"
extends BTDecorator

export(int) var card_level: int = 1

# Override this in your extended script
func _tick(agent: Node, blackboard: Blackboard) -> bool:
	if card_level == agent.card_level:
		result = bt_child.tick(agent, blackboard)
		if result is GDScriptFunctionState:
			result = yield(result, "completed")
		return set_state(bt_child)
	else:
		return fail()

func get_class() -> String:
	return "IsCardLevel"
