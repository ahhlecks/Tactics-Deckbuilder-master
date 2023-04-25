class_name CasterDiscardCard, "../icons/btleaf.svg" 
extends BTLeaf

func get_class() -> String: return "CasterDiscardCard"
# 
export(int, "equal", "greater_than", "lesser_than", "not_equal") var comparison

export(int) var discard_amount: int = 1

export(int, "active_deck", "hand_deck", "discard_deck", "consumed_deck") var deck

var deck_name:String = "active_deck"

export(String, "none", "card_name", "card_class", "action_costs", "card_level", "upgrade_costs", "card_type", "can_attack", "can_defend",
"need_los", "is_homing", "is_unblockable", "is_undeflectable", "is_consumable", "has_counter", "has_reflex", "self_statuses", "target_statuses",
"delay", "rarity", "card_min_range", "card_max_range", "card_up_vertical_range", "card_down_vertical_range", "card_attack", "elements") var card_variable:String

export var card_variable_value:String

var targets:Array

func _tick(agent: Node, blackboard: Blackboard) -> bool:
	match deck:
			0:
				deck_name = "active_deck"
			1:
				deck_name = "hand_deck"
			2:
				deck_name = "discard_deck"
			3:
				deck_name = "consumed_deck"
	if agent.behavior_tree.checking_validity:
		if agent.card_caster != null:
			match card_variable:
				"none":
					if agent.card_caster.unit_owner.searchDeck(agent.card_caster,deck_name).size() <= discard_amount and deck_name == "hand_deck":
						return fail()
					if agent.card_caster.unit_owner.searchDeck(agent.card_caster,deck_name).size() < discard_amount and deck_name != "hand_deck":
						return fail()
				"card_name":
					if agent.card_caster.unit_owner.searchDeck(agent.card_caster,deck_name,card_variable,card_variable_value,comparison).size() <= discard_amount and deck == "hand_deck":
						return fail()
					if agent.card_caster.unit_owner.searchDeck(agent.card_caster,deck_name,card_variable,card_variable_value,comparison).size() < discard_amount and deck != "hand_deck":
						return fail()
				"can_attack", "can_defend", "need_los", "is_homing", "is_unblockable", "is_undeflectable", "is_consumable", "has_counter", "has_reflex":
					if agent.card_caster.unit_owner.searchDeck(agent.card_caster,deck_name,card_variable,bool(card_variable_value),comparison).size() <= discard_amount and deck == "hand_deck":
						return fail()
					if agent.card_caster.unit_owner.searchDeck(agent.card_caster,deck_name,card_variable,bool(card_variable_value),comparison).size() < discard_amount and deck != "hand_deck":
						return fail()
				_:
					if agent.card_caster.unit_owner.searchDeck(agent.card_caster,deck_name,card_variable,int(card_variable_value),comparison).size() <= discard_amount and deck == "hand_deck":
						return fail()
					if agent.card_caster.unit_owner.searchDeck(agent.card_caster,deck_name,card_variable,int(card_variable_value),comparison).size() < discard_amount and deck != "hand_deck":
						return fail()
	elif agent.behavior_tree.is_real and agent.behavior_tree.initial_cast:
		if agent.card_caster != null:
			match card_variable:
				"none":
					agent.card_caster.unit_owner.unitDiscardCards(agent.card_caster,discard_amount,deck_name,agent.unique_id)
				"card_name":
					agent.card_caster.unit_owner.unitDiscardCards(agent.card_caster,discard_amount,deck_name,agent.unique_id,card_variable,card_variable_value,comparison)
				"can_attack", "can_defend", "need_los", "is_homing", "is_unblockable", "is_undeflectable", "is_consumable", "has_counter", "has_reflex":
					var card_variable_value_bool = bool(card_variable_value)
					agent.card_caster.unit_owner.unitDiscardCards(agent.card_caster,discard_amount,deck_name,agent.unique_id,card_variable,card_variable_value_bool,comparison)
				_:
					var card_variable_value_int = int(card_variable_value)
					agent.card_caster.unit_owner.unitDiscardCards(agent.card_caster,discard_amount,deck_name,agent.unique_id,card_variable,card_variable_value_int,comparison)
	if blackboard.has_data("utility_value"):
		blackboard.set_data("utility_value",blackboard.get_data("utility_value") -discard_amount*10)
	else:
		blackboard.set_data("utility_value",-discard_amount*10)
	return succeed()
