class_name ClearTargets, "../icons/btleaf.svg" 
extends BTLeaf

func _tick(agent: Node, blackboard: Blackboard) -> bool:
	blackboard.remove_data("targets")
	blackboard.remove_data("is_splash")
	blackboard.remove_data("is_inline")
	blackboard.remove_data("is_leftright")
	blackboard.remove_data("splash_target")
	blackboard.remove_data("target_params")
	return succeed()

func get_class() -> String:
	return "ClearTargets"
