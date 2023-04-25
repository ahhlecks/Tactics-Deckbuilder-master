class_name BTDecorator, "icons/btdecorator.svg" 
extends BTNode

# Accepts only ONE child. Ticks and sets its state the same as the child.
# Can be used to create conditions. For example, if we extend this script we can do:
#
# func _tick(agent: Node, blackboard: Blackboard) -> bool:
#	assert("agent_property" in agent)
#
#	if not blackboard.has_data("blackboard_property"):
#		return fail()
#
#	if agent.get("agent_property") and blackboard.get_data("blackboard_entry"):
#		return ._tick(agent, blackboard)
#	else:
#		return fail()
#
# This will execute the child only if a certain condition is met, and then match state. 
# So you can decorate a leaf node to be executed only under certain conditions.

var bt_child: BTNode
var result



func _tick(agent: Node, blackboard: Blackboard) -> bool:
	var bt_child: BTNode = get_child(0) as BTNode
	var result = bt_child.tick(agent, blackboard)
	
	if result is GDScriptFunctionState:
		result = yield(result, "completed")
	
	return set_state(bt_child)


func _ready():
#	yield(get_tree().create_timer(.1),"timeout")
	while get_child_count() == 0:
		yield(get_tree(),"node_added")
	bt_child = get_child(0) as BTNode
#	assert(get_child_count() == 1)
