class_name BTRandomSequence, "../icons/btrndsequence.svg" 
extends BTComposite

# Just like a BTSequence, but the children are executed in random order.

func _tick(agent: Node, blackboard: Blackboard) -> bool:
	randomize()
	var result
	children.shuffle()
	
	for c in children:
		bt_child = c
		
		result = bt_child.tick(agent, blackboard)
		
		if result is GDScriptFunctionState:
			result = yield(result, "completed")
		
		if bt_child.failed():
			return fail()
	
	return succeed()

func get_class() -> String:
	return "BTRandomSequence"
