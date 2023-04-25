class_name BTConditional, "../icons/btnode.svg" 
extends BTDecorator


# Requires two int arguments in the blackboard "int_arg1" and "int_arg2"
# Will compare int_arg1 to int_arg2 and fail or succeed accordingly
# array_check will determine if all checks or just one check need to satisfy the comparison when comparing arrays

export(int, "equal", "greater_than", "lesser_than", "not_equal") var comparison
export(int, "all", "one") var array_check

func _tick(agent: Node, blackboard: Blackboard) -> bool:
	_ready()
	if !blackboard.has_data("int_arg1"):
		return fail()
	if !blackboard.has_data("int_arg2"):
		return fail()
	var int_arg1 = blackboard.get_data("int_arg1")
	var int_arg2 = blackboard.get_data("int_arg2")
	if typeof(int_arg1) == TYPE_INT and typeof(int_arg2) == TYPE_INT:
		match comparison:
			0:
				if int_arg1 == int_arg2:
					result = bt_child.tick(agent, blackboard)
					if result is GDScriptFunctionState:
						result = yield(result, "completed")
					return set_state(bt_child)
			1:
				if int_arg1 > int_arg2:
					result = bt_child.tick(agent, blackboard)
					if result is GDScriptFunctionState:
						result = yield(result, "completed")
					return set_state(bt_child)
			2:
				if int_arg1 < int_arg2:
					result = bt_child.tick(agent, blackboard)
					if result is GDScriptFunctionState:
						result = yield(result, "completed")
					return set_state(bt_child)
			3:
				if int_arg1 != int_arg2:
					result = bt_child.tick(agent, blackboard)
					if result is GDScriptFunctionState:
						result = yield(result, "completed")
					return set_state(bt_child)
	elif typeof(int_arg1) == TYPE_INT_ARRAY and typeof(int_arg2) == TYPE_INT:
		match comparison:
			0:
				if array_check == 0: #all have to pass
					for i in int_arg1:
						if int_arg1[i] != int_arg2:
							return fail()
					result = bt_child.tick(agent, blackboard)
					if result is GDScriptFunctionState:
						result = yield(result, "completed")
					return set_state(bt_child)
				if array_check == 1: #only one needs to pass
					for i in int_arg1:
						if int_arg1[i] == int_arg2:
							result = bt_child.tick(agent, blackboard)
							if result is GDScriptFunctionState:
								result = yield(result, "completed")
							return set_state(bt_child)
			1:
				if array_check == 0: #all have to pass
					for i in int_arg1:
						if int_arg1[i] <= int_arg2:
							return fail()
					result = bt_child.tick(agent, blackboard)
					if result is GDScriptFunctionState:
						result = yield(result, "completed")
					return set_state(bt_child)
				if array_check == 1: #only one needs to pass
					for i in int_arg1:
						if int_arg1[i] > int_arg2:
							result = bt_child.tick(agent, blackboard)
							if result is GDScriptFunctionState:
								result = yield(result, "completed")
							return set_state(bt_child)
			2:
				if array_check == 0: #all have to pass
					for i in int_arg1:
						if int_arg1[i] >= int_arg2:
							return fail()
					result = bt_child.tick(agent, blackboard)
					if result is GDScriptFunctionState:
						result = yield(result, "completed")
					return set_state(bt_child)
				if array_check == 1: #only one needs to pass
					for i in int_arg1:
						if int_arg1[i] < int_arg2:
							result = bt_child.tick(agent, blackboard)
							if result is GDScriptFunctionState:
								result = yield(result, "completed")
							return set_state(bt_child)
			3:
				if array_check == 0: #all have to pass
					for i in int_arg1:
						if int_arg1[i] == int_arg2:
							return fail()
					result = bt_child.tick(agent, blackboard)
					if result is GDScriptFunctionState:
						result = yield(result, "completed")
					return set_state(bt_child)
				if array_check == 1: #only one needs to pass
					for i in int_arg1:
						if int_arg1[i] != int_arg2:
							result = bt_child.tick(agent, blackboard)
							if result is GDScriptFunctionState:
								result = yield(result, "completed")
							return set_state(bt_child)
	elif typeof(blackboard.get_data("int_arg1")) == TYPE_INT and typeof(blackboard.get_data("int_arg2")) == TYPE_INT_ARRAY:
		match comparison:
			0:
				if array_check == 0: #all have to pass
					for i in int_arg2:
						if int_arg1 != int_arg2[i]:
							return fail()
					result = bt_child.tick(agent, blackboard)
					if result is GDScriptFunctionState:
						result = yield(result, "completed")
					return set_state(bt_child)
				if array_check == 1: #only one needs to pass
					for i in int_arg2:
						if int_arg1 == int_arg2[i]:
							result = bt_child.tick(agent, blackboard)
							if result is GDScriptFunctionState:
								result = yield(result, "completed")
							return set_state(bt_child)
			1:
				if array_check == 0: #all have to pass
					for i in int_arg2:
						if int_arg1 <= int_arg2[i]:
							return fail()
					result = bt_child.tick(agent, blackboard)
					if result is GDScriptFunctionState:
						result = yield(result, "completed")
					return set_state(bt_child)
				if array_check == 1: #only one needs to pass
					for i in int_arg2:
						if int_arg1 > int_arg2[i]:
							result = bt_child.tick(agent, blackboard)
							if result is GDScriptFunctionState:
								result = yield(result, "completed")
							return set_state(bt_child)
			2:
				if array_check == 0: #all have to pass
					for i in int_arg2:
						if int_arg1 >= int_arg2[i]:
							return fail()
					result = bt_child.tick(agent, blackboard)
					if result is GDScriptFunctionState:
						result = yield(result, "completed")
					return set_state(bt_child)
				if array_check == 1: #only one needs to pass
					for i in int_arg2:
						if int_arg1 < int_arg2[i]:
							result = bt_child.tick(agent, blackboard)
							if result is GDScriptFunctionState:
								result = yield(result, "completed")
							return set_state(bt_child)
			3:
				if array_check == 0: #all have to pass
					for i in int_arg2:
						if int_arg1 == int_arg2[i]:
							return fail()
					result = bt_child.tick(agent, blackboard)
					if result is GDScriptFunctionState:
						result = yield(result, "completed")
					return set_state(bt_child)
				if array_check == 1: #only one needs to pass
					for i in int_arg2:
						if int_arg1 != int_arg2[i]:
							result = bt_child.tick(agent, blackboard)
							if result is GDScriptFunctionState:
								result = yield(result, "completed")
							return set_state(bt_child)
	elif typeof(blackboard.get_data("int_arg1")) == TYPE_INT_ARRAY and typeof(blackboard.get_data("int_arg2")) == TYPE_INT_ARRAY:
		var bigger:Array
		var smaller:Array
		if blackboard.get_data("int_arg1").size() > blackboard.get_data("int_arg2").size():
			bigger = blackboard.get_data("int_arg1")
			smaller = blackboard.get_data("int_arg2")
		else:
			bigger = blackboard.get_data("int_arg2")
			smaller = blackboard.get_data("int_arg1")
			
		match comparison:
			0:
				if array_check == 0: #all have to pass
					for i in smaller:
						if smaller[i] != bigger[i]:
							return fail()
					result = bt_child.tick(agent, blackboard)
					if result is GDScriptFunctionState:
						result = yield(result, "completed")
					return set_state(bt_child)
				if array_check == 1: #only one needs to pass
					for i in smaller:
						if smaller[i] == bigger[i]:
							result = bt_child.tick(agent, blackboard)
							if result is GDScriptFunctionState:
								result = yield(result, "completed")
							return set_state(bt_child)
			1:
				if array_check == 0: #all have to pass
					for i in smaller:
						if smaller[i] <= bigger[i]:
							return fail()
					result = bt_child.tick(agent, blackboard)
					if result is GDScriptFunctionState:
						result = yield(result, "completed")
					return set_state(bt_child)
				if array_check == 1: #only one needs to pass
					for i in smaller:
						if smaller[i] > bigger[i]:
							result = bt_child.tick(agent, blackboard)
							if result is GDScriptFunctionState:
								result = yield(result, "completed")
							return set_state(bt_child)
			2:
				if array_check == 0: #all have to pass
					for i in smaller:
						if smaller[i] >= bigger[i]:
							return fail()
					result = bt_child.tick(agent, blackboard)
					if result is GDScriptFunctionState:
						result = yield(result, "completed")
					return set_state(bt_child)
				if array_check == 1: #only one needs to pass
					for i in smaller:
						if smaller[i] < bigger[i]:
							result = bt_child.tick(agent, blackboard)
							if result is GDScriptFunctionState:
								result = yield(result, "completed")
							return set_state(bt_child)
			3:
				if array_check == 0: #all have to pass
					for i in smaller:
						if smaller[i] == bigger[i]:
							return fail()
					result = bt_child.tick(agent, blackboard)
					if result is GDScriptFunctionState:
						result = yield(result, "completed")
					return set_state(bt_child)
				if array_check == 1: #only one needs to pass
					for i in smaller:
						if smaller[i] != bigger[i]:
							result = bt_child.tick(agent, blackboard)
							if result is GDScriptFunctionState:
								result = yield(result, "completed")
							return set_state(bt_child)
	return succeed()

func get_class() -> String:
	return "BTConditional"
