class_name TargetDrawCard, "../icons/btleaf.svg" 
extends BTLeaf

func get_class() -> String: return "TargetDrawCard"
# 
export(int, "equal", "greater_than", "lesser_than", "not_equal") var comparison

export(int) var draw_amount: int = 1

export(int, "active_deck", "hand_deck", "discard_deck", "consumed_deck") var deck
var deck_name:String = "active_deck"

export(String) var card_variable:String

export var card_variable_value:String

export(String, "none", "int_arg1", "int_arg2") var int_arg

export(int, "all", "self_only", "ally_only", "enemy_only", "self_ally", "self_enemy", "ally_enemy") var valid_targets

export var fallback:bool

var targets:Array

func _tick(agent: Node, blackboard: Blackboard) -> bool:
	if int_arg == "int_arg1":
		if blackboard.has_data("int_arg1"):
			card_variable_value = blackboard.get_data("int_arg1")
	if int_arg == "int_arg2":
		if blackboard.has_data("int_arg2"):
			card_variable_value = blackboard.get_data("int_arg2")
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
						
	if agent.behavior_tree.is_real:
		match deck:
			0:
				deck_name = "active_deck"
			1:
				deck_name = "hand_deck"
			2:
				deck_name = "discard_deck"
			3:
				deck_name = "consumed_deck"
		if agent.delay[agent.card_level] == 0:
			for target in targets:
				if target.unit.current_health > 0:
					if target.unit == agent.card_caster:
						match card_variable:
							"none":
								target.unit.unit_owner.unitDrawCards(target.unit,draw_amount,deck_name)
							"card_name":
								target.unit.unit_owner.unitDrawCards(target.unit,draw_amount,deck_name,card_variable,card_variable_value,comparison,fallback)
							"can_attack", "can_defend", "need_los", "has_combo", "is_homing", "is_unblockable", "is_undeflectable", "is_consumable", "has_counter", "has_reflex":
								var card_variable_value_bool = bool(card_variable_value)
								target.unit.unit_owner.unitDrawCards(target.unit,draw_amount,deck_name,card_variable,card_variable_value_bool,comparison,fallback)
							_:
								var card_variable_value_int = int(card_variable_value)
								target.unit.unit_owner.unitDrawCards(target.unit,draw_amount,deck_name,card_variable,card_variable_value_int,comparison,fallback)
					elif target.unit != null:
						match card_variable:
							"none":
								target.unit.unit_owner.unitReserveCards(target.unit,draw_amount,deck_name)
								target.unit.current_draw_points += draw_amount
							"card_name":
								target.unit.unit_owner.unitReserveCards(target.unit,draw_amount,deck_name,card_variable,card_variable_value,comparison)
								target.unit.current_draw_points += draw_amount
							"can_attack", "can_defend", "need_los", "has_combo", "is_homing", "is_unblockable", "is_undeflectable", "is_consumable", "has_counter", "has_reflex":
								var card_variable_value_bool = bool(card_variable_value)
								target.unit.unit_owner.unitReserveCards(target.unit,draw_amount,deck_name,card_variable,card_variable_value_bool,comparison)
								target.unit.current_draw_points += draw_amount
							_:
								var card_variable_value_int = int(card_variable_value)
								target.unit.unit_owner.unitReserveCards(target.unit,draw_amount,deck_name,card_variable,card_variable_value_int,comparison)
								target.unit.current_draw_points += draw_amount
		else:
			for target in targets:
				if target.unit != null and target.unit.current_health > 0:
					match card_variable:
						"none":
							target.unit.unit_owner.unitReserveCards(target.unit,draw_amount,deck_name)
							target.unit.current_draw_points += draw_amount
						"card_name":
							target.unit.unit_owner.unitReserveCards(target.unit,draw_amount,deck_name,card_variable,card_variable_value,comparison)
							target.unit.current_draw_points += draw_amount
						"can_attack", "can_defend", "need_los", "has_combo", "is_homing", "is_unblockable", "is_undeflectable", "is_consumable", "has_counter", "has_reflex":
							var card_variable_value_bool = bool(card_variable_value)
							target.unit.unit_owner.unitReserveCards(target.unit,draw_amount,deck_name,card_variable,card_variable_value_bool,comparison)
							target.unit.current_draw_points += draw_amount
						_:
							var card_variable_value_int = int(card_variable_value)
							target.unit.unit_owner.unitReserveCards(target.unit,draw_amount,deck_name,card_variable,card_variable_value_int,comparison)
							target.unit.current_draw_points += draw_amount
	if blackboard.has_data("utility_value"):
		blackboard.set_data("utility_value",blackboard.get_data("utility_value") + draw_amount*targets.size()*20)
	else:
		blackboard.set_data("utility_value",draw_amount*targets.size()*20)
	return succeed()
