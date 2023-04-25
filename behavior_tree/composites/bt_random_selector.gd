class_name BTRandomSelector, "../icons/btrndselector.svg"
extends BTComposite

# Executes a random child and is successful at the first successful tick.
# Attempts a number of ticks equal to the number of children. If no successful
# child was found, it fails.

func _tick(agent: Node, blackboard: Blackboard) -> bool:
	randomize()
	var result
	children = get_children() as Array
	children.shuffle()
	
	for c in children:
		bt_child = c
		
		result = bt_child.tick(agent, blackboard)
		
		if result is GDScriptFunctionState:
			result = yield(result, "completed")
		
		if bt_child.succeeded():
			return succeed()
	
	return fail()

func get_class() -> String:
	return "BTRandomSelector"
