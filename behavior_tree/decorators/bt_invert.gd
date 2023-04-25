class_name BTInvert, "../icons/btrevert.svg"
extends BTDecorator

# Succeeds if the child fails and viceversa.


func _tick(agent: Node, blackboard: Blackboard) -> bool:
	var result = bt_child.tick(agent, blackboard)
	if bt_child.running() and result is GDScriptFunctionState:
		yield(result, "completed")
	if bt_child.succeeded():
		return fail()
	else:
		return succeed()

func get_class() -> String:
	return "BTInvert"
