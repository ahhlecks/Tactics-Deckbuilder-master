class_name CasterDrawCard, "../icons/btleaf.svg" 
extends BTLeaf

func get_class() -> String: return "CasterDrawCard"
# 
export(int, "equal", "greater_than", "lesser_than", "not_equal") var comparison

export(int) var draw_amount: int = 1

export(int, "active_deck", "hand_deck", "discard_deck", "consumed_deck") var deck
var deck_name:String = "active_deck"

export(String) var card_variable:String

export var card_variable_value:String

export(String, "none", "int_arg1", "int_arg2") var int_arg

export var fallback:bool

var targets:Array

func _tick(agent: Node, blackboard: Blackboard) -> bool:
	if int_arg == "int_arg1":
		if blackboard.has_data("int_arg1"):
			card_variable_value = blackboard.get_data("int_arg1")
	if int_arg == "int_arg2":
		if blackboard.has_data("int_arg2"):
			card_variable_value = blackboard.get_data("int_arg2")
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
		if agent.card_caster != null:
			match card_variable:
				"none":
					agent.card_caster.unit_owner.unitDrawCards(agent.card_caster,draw_amount,deck_name)
				"card_name":
					agent.card_caster.unit_owner.unitDrawCards(agent.card_caster,draw_amount,deck_name,card_variable,card_variable_value,comparison,fallback)
				"can_attack", "can_defend", "need_los", "has_combo", "is_homing", "is_unblockable", "is_undeflectable", "is_consumable", "has_counter", "has_reflex":
					var card_variable_value_bool = bool(card_variable_value)
					agent.card_caster.unit_owner.unitDrawCards(agent.card_caster,draw_amount,deck_name,card_variable,card_variable_value_bool,comparison,fallback)
				_:
					var card_variable_value_int = int(card_variable_value)
					agent.card_caster.unit_owner.unitDrawCards(agent.card_caster,draw_amount,deck_name,card_variable,card_variable_value_int,comparison,fallback)
	if blackboard.has_data("utility_value"):
		blackboard.set_data("utility_value",blackboard.get_data("utility_value") + draw_amount*20)
	else:
		blackboard.set_data("utility_value",draw_amount*20)
	return succeed()
