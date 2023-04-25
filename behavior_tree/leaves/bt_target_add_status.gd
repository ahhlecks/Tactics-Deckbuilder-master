class_name TargetAddStatus, "../icons/btleaf.svg" 
extends BTLeaf

func get_class() -> String: return "TargetAddStatus"

# "targets" default to single target if blackboard doesn't have a pre-defined "targets" array
# "attack_value" can be set here if blackboard doesn't have a pre-defined "attack_value" integer

var status:int = 0

var duration:int = 1

export(int, "all", "self_only", "ally_only", "enemy_only", "self_ally", "self_enemy", "ally_enemy") var valid_targets

var targets:Array

func _tick(agent: Node, blackboard: Blackboard) -> bool:
	if blackboard.has_data("targets"):
		targets = blackboard.get_data("targets")
	elif agent.target_cell == null:
		return fail()
	else:
		blackboard.set_data("targets", [agent.target_cell])
		targets = [agent.target_cell]
	for target in targets:
		if target.unit != null:
			match valid_targets:
				0: # all targets are valid
					pass
				1: # only self is valid
					if target.unit != agent.card_caster:
						targets.erase(target)
				2: # only allies are valid
					if target.unit.team != agent.card_caster.team:
						targets.erase(target)
				3: # only enemies are valid
					if target.unit.team == agent.card_caster.team:
						targets.erase(target)
				4: # only self and allies are valid
					if target.unit != agent.card_caster or target.unit.team != agent.card_caster.team:
						targets.erase(target)
				5: # only self and enemies are valid
					if target.unit != agent.card_caster or target.unit.team == agent.card_caster.team:
						targets.erase(target)
				6: # only allies and enemies are valid
					if target.unit == agent.card_caster:
						targets.erase(target)
	
	if blackboard.has_data("targetable"):
		if blackboard.get_data("targetable") == true:
			for target in targets:
				if target.unit != null:
					if agent.behavior_tree.is_real:
						if target.unit.hasStatusType(status) != -1: # already has status
							target.unit.statuses[target.unit.hasStatusType(status)][1] = duration
						else:
							target.unit.statuses.append([status,duration])
							var status_name:String = BattleDictionary.valid_statuses[status][0]
							if status_name != "None":
								target.unit.unit_owner.get_parent().battle_gui.addEffectText(status_name,target.unit)
	else:
		for target in targets:
			if target.unit != null:
				if agent.behavior_tree.is_real:
					if target.unit.hasStatusType(status) != -1: # already has status
						target.unit.statuses[target.unit.hasStatusType(status)][1] = duration
					else:
						target.unit.statuses.append([status,duration])
						var status_name:String = BattleDictionary.valid_statuses[status][0]
						if status_name != "None":
							target.unit.unit_owner.get_parent().battle_gui.addEffectText(status_name,target.unit)
	if blackboard.has_data("utility_value"):
		blackboard.set_data("utility_value",blackboard.get_data("utility_value") + targets.size()*5)
	else:
		blackboard.set_data("utility_value",targets.size()*5)
	return succeed()

func evasionCheck(card, from_cell:HexCell, to_cell:HexCell, check_ground:bool = false) -> Array: # Used in Card.gd bt_attack.gd returns [hit_rate:float, critical_hit:bool, hit_ground:bool]
	if from_cell.translation == to_cell.translation:
		return [0.0, false, false]
	if !card.need_los[card.card_level]:
		return [0.0, false, false]
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
#		prints(from, to)
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
			match hit_results[i].name:
				"StaticBody2":
					hit_results[i] = [0.0,0,true]
				"SideForward":
					hit_results[i] = [-5,0,hit_results[i].get_parent().get_parent().currentCell]
				"SideForwardRight":
					hit_results[i] = [0,0,hit_results[i].get_parent().get_parent().currentCell]
				"SideForwardLeft":
					hit_results[i] = [0,0,hit_results[i].get_parent().get_parent().currentCell]
				"SideBackwardRight":
					hit_results[i] = [5,25,hit_results[i].get_parent().get_parent().currentCell]
				"SideBackwardLeft":
					hit_results[i] = [5,25,hit_results[i].get_parent().get_parent().currentCell]
				"SideBackward":
					hit_results[i] = [25,100,hit_results[i].get_parent().get_parent().currentCell]
		return lowestEvasion(hit_results)
	# return [hit_rate,crit_rate,hit_ground:bool]
	return[0.0,0,false]

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
