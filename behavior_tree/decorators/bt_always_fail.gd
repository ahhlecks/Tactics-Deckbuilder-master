class_name BTAlwaysFail, "../icons/btnode.svg"
extends BTDecorator

# Executes the child and always succeeds, depending on what you set from the inspector



func _tick(agent: Node, blackboard: Blackboard) -> bool:
	var result = bt_child.tick(agent, blackboard)
	if bt_child.running() and result is GDScriptFunctionState:
		yield(result, "completed")
	return fail()

func get_class() -> String:
	return "BTAlwaysFail"
