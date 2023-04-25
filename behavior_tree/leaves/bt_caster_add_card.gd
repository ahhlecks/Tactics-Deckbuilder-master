class_name CasterAddCard, "../icons/btleaf.svg" 
extends BTLeaf

func get_class() -> String: return "CasterAddCard"

export(int) var add_amount: int = 1

var card_name:String = ""

var card_level:int = 0

export(int, "active_deck", "hand_deck", "discard_deck", "consumed_deck") var deck

var deck_name:String = "active_deck"

func _tick(agent: Node, blackboard: Blackboard) -> bool:
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
#			unitAddCards(unit:HexUnit, add_amount:int = 1, deck:String = "active_deck", card_name:String = "", card_level:int = 0, is_caster = true) -> void:
			agent.card_caster.unit_owner.unitAddCards(agent.card_caster, add_amount, deck_name, card_name, card_level, true)
	if blackboard.has_data("utility_value"):
		blackboard.set_data("utility_value",blackboard.get_data("utility_value") + add_amount*20)
	else:
		blackboard.set_data("utility_value",add_amount*20)
	return succeed()
