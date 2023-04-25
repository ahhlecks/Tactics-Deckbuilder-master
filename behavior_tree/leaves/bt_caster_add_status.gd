class_name CasterAddStatus, "../icons/btleaf.svg" 
extends BTLeaf

func get_class() -> String: return "CasterAddStatus"

# "targets" default to single target if blackboard doesn't have a pre-defined "targets" array
# "attack_value" can be set here if blackboard doesn't have a pre-defined "attack_value" integer

var status:int = 0

var duration:int = 1

func _tick(agent: Node, blackboard: Blackboard) -> bool:
#	if blackboard.has_data("targets"):
#		targets = blackboard.get_data("targets")
#	else:
#		targets = [agent.target_cell]
#
#	if targets.size() == 0:
#		return fail()
	if agent.behavior_tree.is_real:
		if agent.card_caster.hasStatusType(status) != -1: # already has status
			agent.card_caster.statuses[agent.card_caster.hasStatusType(status)][1] = duration
		else:
			agent.card_caster.statuses.append([status,duration])
			var status_name:String = BattleDictionary.valid_statuses[status][0]
			if status_name != "None":
				agent.card_caster.unit_owner.get_parent().battle_gui.addEffectText(status_name,agent.card_caster)
	if blackboard.has_data("utility_value"):
		blackboard.set_data("utility_value",blackboard.get_data("utility_value") + 5)
	else:
		blackboard.set_data("utility_value",5)
	return succeed()
