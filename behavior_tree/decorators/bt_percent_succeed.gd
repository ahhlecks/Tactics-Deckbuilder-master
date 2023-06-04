class_name BTPercentSucceed, "../icons/btdecorator.svg"
extends BTDecorator

func get_class() -> String: return "BTPercentSucceed"

# Succeeds a percentage of the time

export(int, 0, 100) var success_rate = 100
export(String, "none", "int_arg1", "int_arg2") var int_arg

var percent:int

func _tick(agent: Node, blackboard: Blackboard) -> bool:
	percent = success_rate
	if int_arg == "int_arg1":
		if blackboard.has_data("int_arg1"):
			percent = blackboard.get_data("int_arg1")
	if int_arg == "int_arg2":
		if blackboard.has_data("int_arg2"):
			percent = blackboard.get_data("int_arg2")
	percent = clamp(percent,0,100)
	randomize()
	if percent < randi() % 102: # 0 - 101
		result = bt_child.tick(agent, blackboard)
		if result is GDScriptFunctionState:
			result = yield(result, "completed")
		return set_state(bt_child)
	else:
		return fail()
