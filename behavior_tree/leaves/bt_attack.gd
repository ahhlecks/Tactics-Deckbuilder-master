class_name Attack, "../icons/btleaf.svg" 
extends BTLeaf

func get_class() -> String: return "Attack"

export(int, "all", "self_only", "ally_only", "enemy_only", "self_ally", "self_enemy", "ally_enemy") var valid_targets

# "targets" default to single target if blackboard doesn't have a pre-defined "targets" array
# "attack_value" can be set here if blackboard doesn't have a pre-defined "attack_value" integer
var targets:Array
#var hit_rate:float
#var critical_hit:float
var added_attack:int
var attack_value:int
var attack_multiplier:float
var multipliers:Array
var prefix_text:String


func _tick(agent: Node, blackboard: Blackboard) -> bool:
	var result = true

	if blackboard.has_data("add_attack_value"):
		added_attack = blackboard.get_data("add_attack_value")
	else:
		added_attack = 0

	if blackboard.has_data("attack_multiplier"):
		attack_multiplier = blackboard.get_data("attack_multiplier")
	else:
		attack_multiplier = 1
	
	if blackboard.has_data("target_params"):
		var target_params:Array = blackboard.get_data("target_params")
		if (target_params[0] == "splash" or target_params[0] == "leftright") and agent.need_los[agent.card_level]:
			if agent.target_cell.unit == null:
				var evasion_check = evasionCheck(agent,agent.card_caster.currentCell,agent.target_cell,true)
				if evasion_check[2]: #Check to see if ground is in line of sight
					blackboard.set_data("splash_target", "ground")
					if evasion_check[4] == null:
						blackboard.set_data("splash_target", "wall")
				else:
					blackboard.set_data("splash_target", "unit")
					targets = evasion_check[3].currentCell.getSplash(agent,target_params[1],target_params[2],target_params[3],target_params[4])
					blackboard.set_data("targets",targets)
		if target_params[0] == "inline" and agent.need_los[agent.card_level]:
			targets = blackboard.get_data("targets")
			for target in targets:
				var target_unit = evasionCheck(agent,agent.card_caster.currentCell,target,false)[3]
				if target_unit != null:
					blackboard.set_data("targets", [target_unit.currentCell])
					targets = [target_unit.currentCell]
					break

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
	blackboard.set_data("targets", targets)
	if !agent.behavior_tree.is_real and agent.card_caster.unit_owner.is_human:
		for cell in targets:
			cell.validifyAttack()
	var target_units:Array
	var empty_targets:Array #Empty Cells
	for target in targets:
		randomize()
		var hit_calculation:Array = calculateHit(agent,blackboard,target)
		var unit = hit_calculation[2]
		if unit != null:
			target_units.append(unit)
			blackboard.set_data("target_units", target_units)
			var hit_rate = hit_calculation[0]
			var crit_rate = hit_calculation[1]
			# Calculate Debuffs and Buffs
			setStatusMultipliers(agent, blackboard, unit)

#Set attack (or healing) value
			if blackboard.has_data("attack_value"):
				attack_value = int(round(blackboard.get_data("attack_value") * attack_multiplier + .05) + added_attack)
			else:
				attack_value = int(round(agent.card_attack[agent.card_level] * attack_multiplier + .05) + added_attack)

##Calculate block and deflect and strength and willpower
			if attack_value > 0:
				if agent.card_type == 1: # If card is a physical attack
					if !agent.behavior_tree.is_real:
						attack_value = max(attack_value - unit.block + agent.card_caster.strength, 0)
				if agent.card_type == 2: # If card is a magic attack
					if !agent.behavior_tree.is_real:
						attack_value = max(attack_value - unit.deflect + agent.card_caster.willpower, 0)

#Calculate hit rate and critical hit
#			calculateHit(agent,blackboard,target)

#Do the damage
			if agent.behavior_tree.is_real:
				if unit.current_health > 0:
					unit.emit_signal("targeted", agent, agent.card_caster)
					if randf() < hit_rate / 100.0:
						dealDamage(agent,blackboard,unit)
						blackboard.set_data("targetable", true)
					else:
						unit.emit_signal("evaded", agent)
						unit.unit_owner.get_parent().battle_gui.addEffectText("Missed!",target)
						agent.card_caster.emit_signal("missed",unit)
						blackboard.set_data("targetable", false)
						unit.reaction_animation = unit.reaction_animations.MISS
			else:
				agent.results.append([agent.card_caster, unit, attack_value, attack_multiplier + added_attack, multipliers, hit_rate, crit_rate])
		resetMultipliers()
		empty_targets.append(target)
	blackboard.set_data("empty_targets", empty_targets)
	clearBlackboard(blackboard)
	return succeed()




#---- Helper Functions ----#

func evasionCheck(card, from_cell:HexCell, to_cell:HexCell, check_ground:bool = false, hit_rate_base = 0, crit_rate_base = 0) -> Array: # Used in Card.gd bt_attack.gd returns [hit_rate:float, critical_hit:float, hit_ground:bool]
	if from_cell.translation == to_cell.translation:
		return [0.0, 0.0, false, null, null]
	if !card.need_los[card.card_level]:
		return [0.0, 0.0, false, null, null]
		
	from_cell.originalShape.disabled = true
	from_cell.slopedShape.disabled = true
	to_cell.originalShape.disabled = true
	
	var ray_target:Vector3
	if check_ground:
		ray_target = Vector3(0,0,0)
		if to_cell.unit != null:
			to_cell.unit.deactivateSides()
			to_cell.unit.deactivateCoreCollision()
	else:
		if to_cell.unit != null:
			to_cell.unit.activateSides()
		ray_target = Vector3(0,2,0)
	var hit_results:Array
	var space_state = card.card_caster.unit_owner.get_parent().grid.get_world().get_direct_space_state()
	
	
	if from_cell.unit != null:
		from_cell.unit.deactivateSides()
		from_cell.unit.deactivateCoreCollision()
	for edge in from_cell.edge_positions.get_children(): #Check the raycasts from each hexagon side
		var from = (edge.translation + from_cell.translation) + Vector3(0,from_cell.cell_height*from_cell.scale.y,0) + Vector3(0,2,0)
		var to = to_cell.translation + Vector3(0,to_cell.cell_height*to_cell.scale.y,0) + ray_target
		var result = space_state.intersect_ray(from, to)
		if result.has("collider"):
			var target_side:String = result.collider.name
			if card.need_los[card.card_level] and !(target_side == "" or target_side == "CellBody" or target_side == "Obstacle"):
				hit_results.append(result.collider)
	if from_cell.unit != null:
		from_cell.unit.activateSides()
		from_cell.unit.activateCoreCollision()
	
	
	from_cell.originalShape.disabled = false
	from_cell.slopedShape.disabled = false
	to_cell.originalShape.disabled = false
	
	if to_cell.unit != null:
		to_cell.unit.activateSides()
		to_cell.unit.activateCoreCollision()
	
	if hit_results.size() > 0:
		for i in hit_results.size():
			var result_unit = null
			match hit_results[i].name:
#				[hit_rate:float, critical_hit:float, hit_ground:bool]
				"StaticBody2":
					result_unit = null
					hit_results[i] = [0.0,0,true,result_unit,hit_results[i].name]
				"SideForward":
					result_unit = hit_results[i].get_parent().get_parent()
					hit_results[i] = [clamp(0 + hitRate(card,result_unit,hit_rate_base),0,100),clamp(-5 + critRate(card,result_unit,crit_rate_base),0,100),false,result_unit,hit_results[i].name]
				"SideForwardRight":
					result_unit = hit_results[i].get_parent().get_parent()
					hit_results[i] = [clamp(15 + hitRate(card,result_unit,hit_rate_base),0,100),clamp(0 + critRate(card,result_unit,crit_rate_base),0,100),false,result_unit,hit_results[i].name]
				"SideForwardLeft":
					result_unit = hit_results[i].get_parent().get_parent()
					hit_results[i] = [clamp(15 + hitRate(card,result_unit,hit_rate_base),0,100),clamp(0 + critRate(card,result_unit,crit_rate_base),0,100),false,result_unit,hit_results[i].name]
				"SideBackwardRight":
					result_unit = hit_results[i].get_parent().get_parent()
					hit_results[i] = [clamp(20 + hitRate(card,result_unit,hit_rate_base),0,100),clamp(25 + critRate(card,result_unit,crit_rate_base),0,100),false,result_unit,hit_results[i].name]
				"SideBackwardLeft":
					result_unit = hit_results[i].get_parent().get_parent()
					hit_results[i] = [clamp(20 + hitRate(card,result_unit,hit_rate_base),0,100),clamp(25 + critRate(card,result_unit,crit_rate_base),0,100),false,result_unit,hit_results[i].name]
				"SideBackward":
					result_unit = hit_results[i].get_parent().get_parent()
					hit_results[i] = [clamp(25 + hitRate(card,result_unit,hit_rate_base),0,100),clamp(100 + critRate(card,result_unit,crit_rate_base),0,100),false,result_unit,hit_results[i].name]
				"HexUnit":
					result_unit = hit_results[i]
					hit_results[i] = [0,0,true,result_unit,hit_results[i].name]
				_:
					result_unit = null
					hit_results[i] = [0,0,false,result_unit,hit_results[i].name]
		return lowestEvasion(hit_results)
	return[0.0,0.0,false,null,null]

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
	var crit_chance:float = 0
	var unit = null
	
	if blackboard.has_data("caster_stat_current_physical_accuracy") and (agent.card_type == 0 or agent.card_type == 1): #current_magic_accuracy
		hit_rate = blackboard.get_data("caster_stat_current_physical_accuracy")
	if blackboard.has_data("caster_stat_current_magic_accuracy") and (agent.card_type == 2 or agent.card_type == 3): #current_magic_accuracy
		hit_rate = blackboard.get_data("caster_stat_current_magic_accuracy")
	if blackboard.has_data("caster_stat_current_crit_chance"):
		crit_chance = blackboard.get_data("caster_stat_current_crit_chance")
		
	if agent.need_los[agent.card_level]: #Just a normal line of sight check
		if blackboard.has_data("target_params"):
			var target_params:Array = blackboard.get_data("target_params")
			if target_params[0] == "splash":
				if target.unit != null:
					hit_rate = hitRate(agent,target.unit,hit_rate)
					crit_chance = critRate(agent,target.unit,crit_chance)
					unit = target.unit
				return [hit_rate, crit_chance, unit]
		hit_rate = evasionCheck(agent,agent.source_cell,target,false,hit_rate,crit_chance)[0]
		if evasionCheck(agent,agent.source_cell,target,false,hit_rate,crit_chance)[1] is bool:
			unit = evasionCheck(agent,agent.source_cell,target,false,hit_rate,crit_chance)[3]
			return [hit_rate, crit_chance, unit]
		else:
			crit_chance = evasionCheck(agent,agent.source_cell,target,false,hit_rate,crit_chance)[1]
			unit = evasionCheck(agent,agent.source_cell,target,false,hit_rate,crit_chance)[3]
			return [hit_rate, crit_chance, unit]
	if !agent.need_los[agent.card_level]: #If this card doesn't require los, always hit accuracy minus target evasion if no line of sight needed
		if target.unit != null:
			hit_rate = hitRate(agent,target.unit,hit_rate)
			crit_chance = critRate(agent,target.unit,crit_chance)
			unit = target.unit
			return [hit_rate, crit_chance, unit]
	return [hit_rate, crit_chance, unit]


func hitRate(agent,target,base = 0) -> float:
	var evasion:float
	var accuracy:float
	if agent.card_type == 0 or agent.card_type == 1 or agent.card_type == 4:
		evasion = target.current_physical_evasion
		accuracy = agent.card_caster.current_physical_accuracy + target.evasion_degradation
	if agent.card_type == 2 or agent.card_type == 3:
		evasion = target.current_magic_evasion
		accuracy = agent.card_caster.current_magic_accuracy + target.evasion_degradation
	if attack_value <= 0 and (agent.card_type == 0):
		evasion = 0
		accuracy = agent.card_caster.current_physical_accuracy + target.evasion_degradation
	if attack_value <= 0 and (agent.card_type == 3 or agent.card_type == 4):
		evasion = 0
		accuracy = agent.card_caster.current_magic_accuracy + target.evasion_degradation
	if base != 0:
		accuracy = base + target.evasion_degradation
	return clamp(accuracy - evasion,0,100)

func critRate(agent,target,base = 0) -> float:
	var evasion:float
	var crit_accuracy:float = agent.card_caster.current_crit_chance
	if base != 0:
		crit_accuracy = base
	if agent.card_type == 0 or agent.card_type == 1 or agent.card_type == 4:
		evasion = target.current_physical_evasion
	if agent.card_type == 2 or agent.card_type == 3:
		evasion = target.current_magic_evasion
	return clamp(crit_accuracy - evasion,0,100)


func dealDamage(agent, blackboard, target:HexUnit) -> void:
	randomize()
	if randf() < (calculateHit(agent,blackboard,target.currentCell)[1] + agent.card_caster.current_crit_chance) / 100.0:
		attack_value *= 1 + (agent.card_caster.current_crit_damage / 100.0)
		prefix_text = "Critical! - "
		blackboard.set_data("critical", true)
		agent.card_caster.emit_signal("crit_attacked", agent)
	else:
		prefix_text = "- "
	attack_value = round(attack_value)
	if attack_value < 0: prefix_text = "+ "
	if attack_value != 0:
		if attack_value > 0:
			agent.card_caster.emit_signal("attacked", agent)
			target.reaction_animation = target.reaction_animations.HIT
			#Calculate block and deflect and strength and willpower
			if agent.card_type == 1: # If card is a physical attack
				if agent.behavior_tree.is_real: # If this is a real attack
					attack_value += agent.card_caster.strength
					var old_block = target.block
					target.block = max(target.block - attack_value, 0)
					if !agent.is_piercing[agent.card_level]:
						attack_value = max(attack_value - old_block, 0)
						if old_block > 0:
							target.reaction_animation = target.reaction_animations.BLOCK
							target.unit_owner.get_parent().battle_gui.addEffectText("Blocked " + str(old_block - target.block),target)
							target.emit_signal("blocked", agent, old_block - target.block)
			if agent.card_type == 2: # If card is a magic attack
				if agent.behavior_tree.is_real: # If this is a real attack
					attack_value += agent.card_caster.willpower
					var old_deflect = target.deflect
					target.deflect = max(target.deflect - attack_value, 0)
					if !agent.is_piercing[agent.card_level]:
						attack_value = max(attack_value - old_deflect, 0)
						if old_deflect > 0:
							target.reaction_animation = target.reaction_animations.MISS
							target.unit_owner.get_parent().battle_gui.addEffectText("Deflected " + str(old_deflect - target.deflect),target)
							target.emit_signal("deflected", agent, old_deflect - target.deflect)
		else:
			target.reaction_animation = target.reaction_animations.HEAL
			target.emit_signal("receive_heal", agent, attack_value)
			agent.card_caster.emit_signal("give_heal", agent, attack_value)
		if attack_value != 0:
			target.current_health -= clamp(attack_value, -INF, target.current_health)
			target.unit_owner.get_parent().battle_gui.addEffectText(prefix_text + str(attack_value) + " HP",target)
			if prefix_text.begins_with("Critical"):
				target.emit_signal("crit_damaged", agent, clamp(attack_value, -INF, target.current_health))
			else:
				target.emit_signal("damaged", agent, clamp(attack_value, -INF, target.current_health))
	prefix_text = ""



func setStatusMultipliers(agent:Node, blackboard:Blackboard, target_unit:HexUnit) -> void:
	if target_unit.statuses.size() > 0:
		for status in target_unit.statuses:
			match status[0]:
	#--------------------------- RESISTANCE-----------------------------------#
				BattleDictionary.STATUS.PHYSICALDEFENSEUP:
					if agent.card_type == 1:
						attack_multiplier -= .25
						multipliers.append(BattleDictionary.STATUS.PHYSICALDEFENSEUP)
				BattleDictionary.STATUS.PHYSICALDEFENSEUP2:
					if agent.card_type == 1:
						attack_multiplier -= .5
						multipliers.append(BattleDictionary.STATUS.PHYSICALDEFENSEUP2)
				BattleDictionary.STATUS.MAGICDEFENSEUP:
					if agent.card_type == 2:
						attack_multiplier -= .25
						multipliers.append(BattleDictionary.STATUS.MAGICDEFENSEUP)
				BattleDictionary.STATUS.MAGICDEFENSEUP2:
					if agent.card_type == 2:
						attack_multiplier -= .5
						multipliers.append(BattleDictionary.STATUS.MAGICDEFENSEUP2)
				BattleDictionary.STATUS.FIREDEFENSEUP:
					for element in agent.elements[agent.card_level]:
						if element == 1:
							attack_multiplier -= .25
							multipliers.append(BattleDictionary.STATUS.FIREDEFENSEUP)
				BattleDictionary.STATUS.FIREDEFENSEUP2:
					for element in agent.elements[agent.card_level]:
						if element == 1:
							attack_multiplier -= .5
							multipliers.append(BattleDictionary.STATUS.FIREDEFENSEUP2)
				BattleDictionary.STATUS.ICEDEFENSEUP:
					for element in agent.elements[agent.card_level]:
						if element == 2:
							attack_multiplier -= .25
							multipliers.append(BattleDictionary.STATUS.ICEDEFENSEUP)
				BattleDictionary.STATUS.ICEDEFENSEUP2:
					for element in agent.elements[agent.card_level]:
						if element == 2:
							attack_multiplier -= .5
							multipliers.append(BattleDictionary.STATUS.ICEDEFENSEUP2)
				BattleDictionary.STATUS.ELECTRICDEFENSEUP:
					for element in agent.elements[agent.card_level]:
						if element == 3:
							attack_multiplier -= .25
							multipliers.append(BattleDictionary.STATUS.ELECTRICDEFENSEUP)
				BattleDictionary.STATUS.ELECTRICDEFENSEUP2:
					for element in agent.elements[agent.card_level]:
						if element == 3:
							attack_multiplier -= .5
							multipliers.append(BattleDictionary.STATUS.ELECTRICDEFENSEUP2)
	#--------------------------- SENSITIVITY --------------------------------------#
				BattleDictionary.STATUS.PHYSICALDEFENSEDOWN:
					if agent.card_type == 1:
						attack_multiplier += .25
						multipliers.append(BattleDictionary.STATUS.PHYSICALDEFENSEDOWN)
				BattleDictionary.STATUS.PHYSICALDEFENSEDOWN2:
					if agent.card_type == 1:
						attack_multiplier += .5
						multipliers.append(BattleDictionary.STATUS.PHYSICALDEFENSEDOWN2)
				BattleDictionary.STATUS.MAGICDEFENSEDOWN:
					if agent.card_type == 2:
						attack_multiplier += .25
						multipliers.append(BattleDictionary.STATUS.MAGICDEFENSEDOWN)
				BattleDictionary.STATUS.MAGICDEFENSEDOWN2:
					if agent.card_type == 2:
						attack_multiplier += .5
						multipliers.append(BattleDictionary.STATUS.MAGICDEFENSEDOWN2)
				BattleDictionary.STATUS.FIREDEFENSEDOWN:
					for element in agent.elements[agent.card_level]:
						if element == 1:
							attack_multiplier += .25
							multipliers.append(BattleDictionary.STATUS.FIREDEFENSEDOWN)
				BattleDictionary.STATUS.FIREDEFENSEDOWN2:
					for element in agent.elements[agent.card_level]:
						if element == 1:
							attack_multiplier += .5
							multipliers.append(BattleDictionary.STATUS.FIREDEFENSEDOWN2)
				BattleDictionary.STATUS.ICEDEFENSEDOWN:
					for element in agent.elements[agent.card_level]:
						if element == 2:
							attack_multiplier += .25
							multipliers.append(BattleDictionary.STATUS.ICEDEFENSEDOWN)
				BattleDictionary.STATUS.ICEDEFENSEDOWN2:
					for element in agent.elements[agent.card_level]:
						if element == 2:
							attack_multiplier += .5
							multipliers.append(BattleDictionary.STATUS.ICEDEFENSEDOWN2)
				BattleDictionary.STATUS.ELECTRICDEFENSEDOWN:
					for element in agent.elements[agent.card_level]:
						if element == 3:
							attack_multiplier += .25
							multipliers.append(BattleDictionary.STATUS.ELECTRICDEFENSEDOWN)
				BattleDictionary.STATUS.ELECTRICDEFENSEDOWN2:
					for element in agent.elements[agent.card_level]:
						if element == 3:
							attack_multiplier += .5
							multipliers.append(BattleDictionary.STATUS.ELECTRICDEFENSEDOWN2)
	
	for status in agent.card_caster.statuses:
		match status[0]:
	#------------------------------ STRENGTH --------------------------------------#
			BattleDictionary.STATUS.PHYSICALATTACKUP:
				if agent.card_type == 1:
					attack_multiplier += .25
					multipliers.append(BattleDictionary.STATUS.PHYSICALATTACKUP)
			BattleDictionary.STATUS.PHYSICALATTACKUP2:
				if agent.card_type == 1:
					attack_multiplier += .50
					multipliers.append(BattleDictionary.STATUS.PHYSICALATTACKUP2)
			BattleDictionary.STATUS.MAGICATTACKUP:
				if agent.card_type == 2:
					attack_multiplier += .25
					multipliers.append(BattleDictionary.STATUS.MAGICATTACKUP)
			BattleDictionary.STATUS.MAGICATTACKUP2:
				if agent.card_type == 2:
					attack_multiplier += .5
					multipliers.append(BattleDictionary.STATUS.MAGICATTACKUP2)
			BattleDictionary.STATUS.FIREATTACKUP:
				for element in agent.elements[agent.card_level]:
					if element == 1:
						attack_multiplier += .25
						multipliers.append(BattleDictionary.STATUS.FIREATTACKUP)
			BattleDictionary.STATUS.FIREATTACKUP2:
				for element in agent.elements[agent.card_level]:
					if element == 1:
						attack_multiplier += .5
						multipliers.append(BattleDictionary.STATUS.FIREATTACKUP2)
			BattleDictionary.STATUS.ICEATTACKUP:
				for element in agent.elements[agent.card_level]:
					if element == 2:
						attack_multiplier += .25
						multipliers.append(BattleDictionary.STATUS.ICEATTACKUP)
			BattleDictionary.STATUS.ICEATTACKUP2:
				for element in agent.elements[agent.card_level]:
					if element == 2:
						attack_multiplier += .5
						multipliers.append(BattleDictionary.STATUS.ICEATTACKUP2)
			BattleDictionary.STATUS.ELECTRICATTACKUP:
				for element in agent.elements[agent.card_level]:
					if element == 3:
						attack_multiplier += .25
						multipliers.append(BattleDictionary.STATUS.ELECTRICATTACKUP)
			BattleDictionary.STATUS.ELECTRICATTACKUP2:
				for element in agent.elements[agent.card_level]:
					if element == 3:
						attack_multiplier += .5
						multipliers.append(BattleDictionary.STATUS.ELECTRICATTACKUP2)
	#------------------------------ WEAKNESSES-------------------------------------#
			BattleDictionary.STATUS.PHYSICALATTACKDOWN:
				if agent.card_type == 1:
					attack_multiplier -= .25
					multipliers.append(BattleDictionary.STATUS.PHYSICALATTACKDOWN)
			BattleDictionary.STATUS.PHYSICALATTACKDOWN2:
				if agent.card_type == 1:
					attack_multiplier -= .50
					multipliers.append(BattleDictionary.STATUS.PHYSICALATTACKDOWN2)
			BattleDictionary.STATUS.MAGICATTACKDOWN:
				if agent.card_type == 2:
					attack_multiplier -= .25
					multipliers.append(BattleDictionary.STATUS.MAGICATTACKDOWN)
			BattleDictionary.STATUS.MAGICATTACKDOWN2:
				if agent.card_type == 2:
					attack_multiplier -= .5
					multipliers.append(BattleDictionary.STATUS.MAGICATTACKDOWN2)
			BattleDictionary.STATUS.FIREATTACKDOWN:
				for element in agent.elements[agent.card_level]:
					if element == 1:
						attack_multiplier -= .25
						multipliers.append(BattleDictionary.STATUS.FIREATTACKDOWN)
			BattleDictionary.STATUS.FIREATTACKDOWN2:
				for element in agent.elements[agent.card_level]:
					if element == 1:
						attack_multiplier -= .5
						multipliers.append(BattleDictionary.STATUS.FIREATTACKDOWN2)
			BattleDictionary.STATUS.ICEATTACKDOWN:
				for element in agent.elements[agent.card_level]:
					if element == 2:
						attack_multiplier -= .25
						multipliers.append(BattleDictionary.STATUS.ICEATTACKDOWN)
			BattleDictionary.STATUS.ICEATTACKDOWN2:
				for element in agent.elements[agent.card_level]:
					if element == 2:
						attack_multiplier -= .5
						multipliers.append(BattleDictionary.STATUS.ICEATTACKDOWN2)
			BattleDictionary.STATUS.ELECTRICATTACKDOWN:
				for element in agent.elements[agent.card_level]:
					if element == 3:
						attack_multiplier -= .25
						multipliers.append(BattleDictionary.STATUS.ELECTRICATTACKDOWN)
			BattleDictionary.STATUS.ELECTRICATTACKDOWN2:
				for element in agent.elements[agent.card_level]:
					if element == 3:
						attack_multiplier -= .5
						multipliers.append(BattleDictionary.STATUS.ELECTRICATTACKDOWN2)
	blackboard.set_data("attack_multiplier", attack_multiplier)

func resetMultipliers() -> void:
	multipliers = []
	attack_multiplier = 1

func clearBlackboard(bb) -> void:
	bb.remove_data("attack_value")
	bb.remove_data("add_attack_value")
	bb.remove_data("attack_multiplier")
