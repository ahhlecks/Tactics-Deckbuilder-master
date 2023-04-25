class_name BTAlwaysSucceed, "../icons/btnode.svg"
extends BTDecorator

# Executes the child and always succeeds, depending on what you set from the inspector



func _tick(agent: Node, blackboard: Blackboard) -> bool:
	var result = bt_child.tick(agent, blackboard)
	if bt_child.running() and result is GDScriptFunctionState:
		yield(result, "completed")
	return succeed()

func get_class() -> String:
	return "BTAlwaysSucceed"
