class_name BehaviorTree, "icons/bt.svg" 
extends Node

# This is your main node. Put one of these at the root of the scene and start adding BTNodes.
# A Behavior Tree only accepts ONE entry point (so one child), for example a BTSequence or a BTSelector.


export(bool) var is_active: bool = false
var is_real:bool = false
var checking_validity:bool = false
var initial_cast:bool = false

export(String, "Idle", "Physics", "Once") var sync_mode = "once"

signal completed()

#func _ready():
#	yield(get_tree().create_timer(.1, false), "timeout")
#	assert(get_child_count() == 1)
#	yield(get_tree(), "idle_frame") # To ensure the agent is ready.
#	run()


func run() -> void:
	var blackboard: Blackboard = $'../Blackboard'
	var bt_root: BTNode = get_child(0)
	var agent: Node = get_parent()
	var tick_result
	
	while is_active:
		tick_result = bt_root.tick(agent, blackboard)
		if tick_result is GDScriptFunctionState:
			tick_result = yield(tick_result, "completed")
		
		if sync_mode == "idle":
			yield(get_tree(), "idle_frame") 
		elif sync_mode == "physics":
			yield(get_tree(), "physics_frame")
		elif sync_mode == "once":
			agent.complete()
			is_active = false
			break

#func checkCostValidity() -> bool:
#	var blackboard: Blackboard = $'../Blackboard'
#	var cost_tree:Array
#	for c in get_children():
#		if c.get_class() == "BTSequence":
#			for cost_check in c.get_children():
#				if cost_check.get_class() == "BTCostCheck":
#					cost_tree.append(cost_check)
#	if cost_tree.empty():
#		return true
#
#	var agent: Node = get_parent()
#	var tick_result
#	for node in cost_tree:
#		tick_result = node.tick(agent, blackboard)
#		print(node)
#	return tick_result
