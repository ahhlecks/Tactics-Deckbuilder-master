class_name BTSelector, "../icons/btselector.svg"
extends BTComposite

# Ticks its children until ANY of them succeeds, thus succeeding.
# If ALL of the children fails, it fails as well.

func _tick(agent: Node, blackboard: Blackboard) -> bool:
	var result
	
	for c in get_children():
		bt_child = c
		
		result = bt_child.tick(agent, blackboard)
		
		if result is GDScriptFunctionState:
			result = yield(result, "completed")
		
		if bt_child.succeeded():
			return succeed()
	
	return fail()

func get_class() -> String:
	return "BTSelector"
