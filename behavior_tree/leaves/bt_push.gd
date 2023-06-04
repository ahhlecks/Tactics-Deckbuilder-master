class_name Push, "../icons/btleaf.svg" 
extends BTLeaf

func get_class() -> String: return "Push"

export(int, "all", "self_only", "ally_only", "enemy_only", "self_ally", "self_enemy", "ally_enemy") var valid_targets
export(int) var strength: int = 1

# "targets" default to single target if blackboard doesn't have a pre-defined "targets" array
# "attack_value" can be set here if blackboard doesn't have a pre-defined "attack_value" integer
var targets:Array
var push_targets:Array
var prev_pushed_targets:Array


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
	if targets.size() == 0:
		return fail()
#	var startCell = agent.target_cell
#	if startCell == null or startCell.get_class() != "HexCell":
#		return fail()
	
#	elif agent.hexagonal_targeting[agent.card_level] or (agent.card_min_range[agent.card_level] == 1 and agent.card_max_range[agent.card_level] == 1):
#		return succeed()
	
#	for i in targets.size():
#		if !(targets[i].cubeCoordinates.x != agent.card_caster.cubeCoordinates.x and targets[i].cubeCoordinates.y != agent.card_caster.cubeCoordinates.y and targets[i].cubeCoordinates.z != agent.card_caster.cubeCoordinates.z):
#			push_targets.append(targets[i])
#	if push_targets.size() == 0:
#		return fail()

	if agent.behavior_tree.is_real:
		for i in range(3): #three maximum layers of push possible
			for target in targets:
				if target.unit != null and !prev_pushed_targets.has(target.unit):
					
					if target.cubeCoordinates.x == agent.card_caster.currentCell.cubeCoordinates.x: #x-axis
						if target.cubeCoordinates.y > agent.card_caster.currentCell.cubeCoordinates.y: #+y -z
							var to_coordinates:Vector3 = Vector3(target.cubeCoordinates.x,target.cubeCoordinates.y+strength,target.cubeCoordinates.z-strength)
							var to_cell:HexCell = target.grid.findCubeHex(to_coordinates)
							target.unit.pushTo(to_cell)
							prev_pushed_targets.append(target.unit)
						else:
							var to_coordinates:Vector3 = Vector3(target.cubeCoordinates.x,target.cubeCoordinates.y-strength,target.cubeCoordinates.z+strength)
							var to_cell:HexCell = target.grid.findCubeHex(to_coordinates)
							target.unit.pushTo(to_cell)
							prev_pushed_targets.append(target.unit)
					if target.cubeCoordinates.y == agent.card_caster.currentCell.cubeCoordinates.y: #y-axis
						if target.cubeCoordinates.x > agent.card_caster.currentCell.cubeCoordinates.x: #+x -z
							var to_coordinates:Vector3 = Vector3(target.cubeCoordinates.x+strength,target.cubeCoordinates.y,target.cubeCoordinates.z-strength)
							var to_cell:HexCell = target.grid.findCubeHex(to_coordinates)
							target.unit.pushTo(to_cell)
							prev_pushed_targets.append(target.unit)
						else:
							var to_coordinates:Vector3 = Vector3(target.cubeCoordinates.x-strength,target.cubeCoordinates.y,target.cubeCoordinates.z+strength)
							var to_cell:HexCell = target.grid.findCubeHex(to_coordinates)
							target.unit.pushTo(to_cell)
							prev_pushed_targets.append(target.unit)
					if target.cubeCoordinates.z == agent.card_caster.currentCell.cubeCoordinates.z: #y-axis
						if target.cubeCoordinates.x > agent.card_caster.currentCell.cubeCoordinates.x: #+x -y
							var to_coordinates:Vector3 = Vector3(target.cubeCoordinates.x+strength,target.cubeCoordinates.y-strength,target.cubeCoordinates.z)
							var to_cell:HexCell = target.grid.findCubeHex(to_coordinates)
							target.unit.pushTo(to_cell)
							prev_pushed_targets.append(target.unit)
						else:
							var to_coordinates:Vector3 = Vector3(target.cubeCoordinates.x-strength,target.cubeCoordinates.y+strength,target.cubeCoordinates.z)
							var to_cell:HexCell = target.grid.findCubeHex(to_coordinates)
							target.unit.pushTo(to_cell)
							prev_pushed_targets.append(target.unit)
	if blackboard.has_data("utility_value"):
		blackboard.set_data("utility_value",blackboard.get_data("utility_value") + push_targets.size()*3)
	else:
		blackboard.set_data("utility_value",push_targets.size()*3)
	return succeed()
