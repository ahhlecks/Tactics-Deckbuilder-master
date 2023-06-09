class_name BTRepeat, "../icons/btrepeat.svg"
extends BTDecorator

# Executes child "iterations" times and returns the last state and tick result
 
export(int, 0, 999) var times_to_repeat = 1



func _tick(agent: Node, blackboard: Blackboard) -> bool:
	var result
	
	for i in times_to_repeat:
		result = bt_child.tick(agent, blackboard)
		
		if result is GDScriptFunctionState:
			result = yield(result, "completed")
	
	return set_state(bt_child)

func get_class() -> String:
	return "BTRepeat"
