class_name SetStatus, "../icons/btleaf.svg" 
extends BTLeaf

#################################
##
## Should use bt_caster_add_status or bt_target_add_status instead
##
#################################
func get_class() -> String: return "SetStatus"

# "targets" default to single target if blackboard doesn't have a pre-defined "targets" array
# "attack_value" can be set here if blackboard doesn't have a pre-defined "attack_value" integer

var targets:Array

func _tick(agent: Node, blackboard: Blackboard) -> bool:
	if blackboard.has_data("targets"):
		targets = blackboard.get_data("targets")
	else:
		targets = [agent.target_cell]
	
	if targets.size() == 0:
		return fail()
	
	
	var new_self_statuses:Array
	var new_target_statuses:Array
	if agent.self_statuses[agent.card_level].size() > 0:
		new_self_statuses = agent.self_statuses[agent.card_level]
	if agent.target_statuses[agent.card_level].size() > 0:
		new_target_statuses = agent.target_statuses[agent.card_level]
	if new_self_statuses.size() == 0 and new_target_statuses.size() == 0:
		return fail()
	var has_target_status:bool = false
	var has_self_status:bool = false
	if blackboard.has_data("targetable"):
		if blackboard.get_data("targetable") == true:
			if new_target_statuses.size() > 0:
				for target in targets:
					if target.unit != null:
						for new_status in new_target_statuses:
							if target.unit.hasStatusType(new_status[0]) != -1:
								if agent.behavior_tree.is_real:
		#							print(target.unit.unit_name + " already has " + str(new_status[0]))
									target.unit.statuses[target.unit.hasStatusType(new_status[0])][1] = new_status[1]
							else:
								if agent.behavior_tree.is_real:
		#							print(target.unit.unit_name + " doesn't have " + str(new_status[0]))
									target.unit.statuses.append(new_status.duplicate())
									var status_name:String = BattleDictionary.valid_statuses[new_status[0]][0]
									if status_name != "None":
										target.unit.unit_owner.get_parent().battle_gui.addEffectText(status_name,target.unit)
			
			if new_self_statuses.size() > 0:
				for target in targets:
					if target.unit != null:
						for new_status in new_self_statuses:
							if target.unit.hasStatusType(new_status[0]) != -1:
								if agent.behavior_tree.is_real:
		#							print(target.unit.unit_name + " already has " + str(new_status[0]))
									agent.card_caster.statuses[target.unit.hasStatusType(new_status[0])][1] = new_status[1]
							else:
								if agent.behavior_tree.is_real:
		#							print(target.unit.unit_name + " doesn't have " + str(new_status[0]))
									agent.card_caster.statuses.append(new_status.duplicate())
									var status_name:String = BattleDictionary.valid_statuses[new_status[0]][0]
									if status_name != "None":
										agent.card_caster.unit_owner.get_parent().battle_gui.addEffectText(status_name,target.unit)
	return succeed()
