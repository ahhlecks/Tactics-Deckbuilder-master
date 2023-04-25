class_name BTLeafEvasionCheck, "icons/btleaf.svg" 
extends BTNode

# Leaf nodes are used to implement your own behavior logic.
# That can be for example calling functions on the agent, or checking conditions in the blackboard. 
# Good practice is to not make leaf nodes do too much stuff, and to not have flow logic in them.
# Instead, just use them to do a single action or condition check, and use a composite node
# (BTSequence, BTSelector or BTParallel) to define the flow between multiple leaf nodes.

# BEGINNING OF VIRTUAL FUNCTIONS
# Override these two in your extended script

# Called after tick()
func _on_tick(result: bool):
	pass


# The following is an abstract example of good practices when defining your actions
func _tick(agent: Node, blackboard: Blackboard) -> bool:
	var result = true
	#result = agent.call("some_function", blackboard.get_data("some_argument"))
	
	# If action is executing, wait for completion and remain in running state
	if result is GDScriptFunctionState:
		# Store what the action returns when completed
		result = yield(result, "completed") 
	
	# If action returns anything but a bool consider it a success
	if not result is bool: 
		result = true
	
	# Once action is complete we set state and return.
	if result == true:
		return succeed()
	else:
		return fail()

func passLeaf(agent:Node, blackboard) -> bool:
	return succeed()

# END OF VIRTUAL FUNCTIONS

func evasionCheck(card, from_cell:HexCell, to_cell:HexCell, check_ground:bool = false) -> Array: # Used in Card.gd bt_attack.gd returns [hit_rate:float, critical_hit:float, hit_ground:bool]
	if from_cell.translation == to_cell.translation:
		return [0.0, 0.0, false, null]
	if !card.need_los[card.card_level]:
		return [0.0, 0.0, false, null]
	var critical_hit:bool = false
	from_cell.originalShape.disabled = true
	from_cell.slopedShape.disabled = true
	if from_cell.unit != null:
		from_cell.unit.deactivateSides()
	to_cell.originalShape.disabled = true
	var ray_target:Vector3
	if check_ground:
		ray_target = Vector3(0,0,0)
		if to_cell.unit != null:
			to_cell.unit.deactivateSides()
	else:
		ray_target = Vector3(0,2,0)
	var hit_results:Array
	var space_state = card.card_caster.unit_owner.get_parent().grid.get_world().get_direct_space_state()
	for edge in from_cell.edge_positions.get_children(): #Check the raycasts from each hexagon side
		var from = (edge.translation + from_cell.translation) + Vector3(0,from_cell.cell_height*from_cell.scale.y,0) + Vector3(0,2,0)
		var to = to_cell.translation + Vector3(0,to_cell.cell_height*to_cell.scale.y,0) + ray_target
		var result = space_state.intersect_ray(from, to)
		if result.has("collider"):
			var target_side:String = result.collider.name
			if card.need_los[card.card_level] and !(target_side == "" or target_side == "CellBody" or target_side == "Obstacle"):
				hit_results.append(result.collider)
	from_cell.originalShape.disabled = false
	from_cell.slopedShape.disabled = false
	if from_cell.unit != null:
		from_cell.unit.activateSides()
	to_cell.originalShape.disabled = false
	if to_cell.unit != null:
		to_cell.unit.activateSides()
	
	if hit_results.size() > 0:
		for i in hit_results.size():
			var result_unit = null
			match hit_results[i].name:
				"StaticBody2":
					result_unit = null
					hit_results[i] = [0.0,0,true,result_unit]
				"SideForward":
					result_unit = hit_results[i].get_parent().get_parent()
					hit_results[i] = [-5 + hitRate(card,result_unit),0,false,result_unit]
				"SideForwardRight":
					result_unit = hit_results[i].get_parent().get_parent()
					hit_results[i] = [0 + hitRate(card,result_unit),0,false,result_unit]
				"SideForwardLeft":
					result_unit = hit_results[i].get_parent().get_parent()
					hit_results[i] = [0 + hitRate(card,result_unit),0,false,result_unit]
				"SideBackwardRight":
					result_unit = hit_results[i].get_parent().get_parent()
					hit_results[i] = [5 + hitRate(card,result_unit),25,false,result_unit]
				"SideBackwardLeft":
					result_unit = hit_results[i].get_parent().get_parent()
					hit_results[i] = [5 + hitRate(card,result_unit),25,false,result_unit]
				"SideBackward":
					result_unit = hit_results[i].get_parent().get_parent()
					hit_results[i] = [25 + hitRate(card,result_unit),100,false,result_unit]
		return lowestEvasion(hit_results)
	return[0.0,0.0,false,null]

func lowestEvasion(evasions) -> Array:
	evasions.sort_custom(EvasionSorter, "sort_descending")
	return evasions[0]

class EvasionSorter:
	static func sort_descending(a, b):
		if a[0] > b[0]:
			return true
		return false
	static func sort_ascending(a, b):
		if a[0] < b[0]:
			return true
		return false

func calculateHit(agent, blackboard, target) -> Array:
	var hit_rate:float = 0
	var critical_hit:float = 0
	var unit = null
	if blackboard.has_data("splash_target"):
		if blackboard.get_data("splash_target") == "wall": # Check if raycast from target cell to splash targets have line of sight
			hit_rate = 0
			critical_hit = 0
		elif blackboard.get_data("splash_target") == "ground": # Check if raycast from target cell to splash targets have line of sight
			if target.unit != null:
				hit_rate = evasionCheck(agent,agent.target_cell,target,false)[0]
			else:
				hit_rate = evasionCheck(agent,agent.source_cell,target,false)[0]
			critical_hit = evasionCheck(agent,agent.target_cell,target,false)[1]
		elif blackboard.get_data("splash_target") == "unit": # Check if raycast from target cell to splash targets have line of sight
			if target.unit != null:
				hit_rate = evasionCheck(agent,agent.target_cell,target,false)[0]
			else:
				hit_rate = evasionCheck(agent,agent.source_cell,target,false)[0]
			critical_hit = evasionCheck(agent,agent.source_cell,target,false)[1]
		unit = evasionCheck(agent,agent.source_cell,target,false)[3]
		return [hit_rate, critical_hit, unit]
		
	if agent.need_los[agent.card_level]: #Just a normal line of sight check
		if target.unit != null:
			hit_rate = evasionCheck(agent,agent.source_cell,target,false)[0]
		else:
			hit_rate = evasionCheck(agent,agent.source_cell,target,false)[0]
		if evasionCheck(agent,agent.source_cell,target,false)[1] is bool:
			unit = evasionCheck(agent,agent.source_cell,target,false)[3]
			return [hit_rate, critical_hit, unit]
		else:
			critical_hit = evasionCheck(agent,agent.source_cell,target,false)[1]
			unit = evasionCheck(agent,agent.source_cell,target,false)[3]
			return [hit_rate, critical_hit, unit]
		unit = evasionCheck(agent,agent.source_cell,target,false)[3]
		return [hit_rate, critical_hit, unit]
		
	if !agent.need_los[agent.card_level]: #If this card doesn't require los, always hit accuracy minus target evasion if no line of sight needed
		if target.unit != null:
			hit_rate = hitRate(agent,target)
		else:
			hit_rate = 0
		critical_hit = 0
		unit = evasionCheck(agent,agent.source_cell,target,false)[3]
		return [hit_rate, critical_hit, unit]
	return [hit_rate, critical_hit, unit]


func hitRate(agent,target,attack_value = 0) -> float:
	var evasion:float
	var accuracy:float
	if agent.card_type == 0 or agent.card_type == 1 or agent.card_type == 4:
		evasion = target.current_physical_evasion
		accuracy = agent.card_caster.current_physical_accuracy
	if agent.card_type == 2 or agent.card_type == 3:
		evasion = target.current_magic_evasion
		accuracy = agent.card_caster.current_magic_accuracy
	if attack_value < 0:
		evasion = 0
		accuracy = 100
	if attack_value <= 0 and (agent.card_type == 0 or agent.card_type == 3 or agent.card_type == 4):
		evasion = 0
		accuracy = 100
	return clamp(accuracy - evasion,0,100)
