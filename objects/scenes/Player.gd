extends Node

class_name Player

var battle_gui 
var battle_controller

var player_name
var is_human:bool
var alliance:int
var deepDrawCount:int = 3
var units:Array
var current_unit_deck:Array
var player_deck:Array
var hand:Array
var discard:Array

signal hand_drawn(player, unit)
signal recover_discard(player, unit)
signal reshuffle(player, unit)

# Called when the node enters the scene tree for the first time.
func _ready():
	is_human = true
	alliance = 0

func loadUnitDecks() -> void:
	for unit in units:
		var unit_deck:Array = []
		for index in unit.deck.size():
			var card_data:Dictionary = CardLoader.loadSingleCardFile(unit.deck[index],true)
			card_data["card_owner"] = unit
			card_data["unique_id"] = str(unit) + " " + str(index)
			for proficiency in unit.proficiencies:
				if proficiency[0] == card_data["card_name"]:
					card_data["card_level"] = proficiency[1] - 1
			unit_deck.append(card_data)
		unit.active_deck = unit_deck
		randomize()
		unit.active_deck.shuffle()

#func loadHand() -> void:
#	for unit in units:
#		draw(unit)

# This func will try to draw as many cards that match the requested variable.
# If there is more draw than cards matching, it will continue to draw from the front of the deck
func unitDrawCards(unit:HexUnit, draw_amount:int = 1, deck:String = "active_deck", card_variable:String = "none", card_variable_value = null, comparison = 0, fallback = true) -> void:
	var matching_cards:Array = searchDeck(unit,deck,card_variable,card_variable_value,comparison)
	if matching_cards.size() > 0:
		for index in matching_cards:
			if draw_amount > 0:
				moveCards(unit,1,index,deck,"hand_deck")
				draw_amount -= 1
			else:
				break
	if draw_amount > 0 and fallback:
		moveCards(unit,draw_amount,0,deck,"hand_deck")

func unitReserveCards(unit:HexUnit, reserve_amount:int = 1, deck:String = "active_deck", card_variable:String = "none", card_variable_value = null, comparison = 0) -> void:
	var matching_cards:Array = searchDeck(unit,deck,card_variable,card_variable_value,comparison)
	if matching_cards.size() > 0:
		for index in matching_cards:
			if reserve_amount > 0:
				moveCardsToTop(unit, index, 1, deck)
				reserve_amount -= 1
			else:
				break

#active_unit, 1, "hand_deck", selected_card.unique_id
func unitDiscardCards(unit:HexUnit, discard_amount:int = 1, deck:String = "active_deck", omit_card_id:String = "", match_card_id:String = "", card_variable:String = "none", card_variable_value = null, comparison = 0, fallback = true) -> void:
	var matching_cards:Array = searchDeck(unit,deck,card_variable,card_variable_value,comparison, omit_card_id, match_card_id)
	if matching_cards.size() > 0:
		randomize()
		matching_cards.shuffle()
		for index in matching_cards:
			if discard_amount > 0:
#				discard(unit, index, 1, deck)
				moveCards(unit,1,index,deck,"discard_deck", false)
				discard_amount -= 1
			else:
				break
	elif discard_amount > 0 and (card_variable == "none" or fallback):
		moveCards(unit,discard_amount,0,deck,"discard_deck")

func unitConsumeCards(unit:HexUnit, consume_amount:int = 1, deck:String = "active_deck", omit_card_id:String = "", match_card_id:String = "", card_variable:String = "none", card_variable_value = null, comparison = 0, fallback = true) -> void:
	var matching_cards:Array = searchDeck(unit,deck,card_variable,card_variable_value,comparison, omit_card_id, match_card_id)
	if matching_cards.size() > 0:
		randomize()
		matching_cards.shuffle()
		for index in matching_cards:
			if consume_amount > 0:
#				discard(unit, index, 1, deck)
				moveCards(unit,1,index,deck,"consumed_deck", false)
				consume_amount -= 1
			else:
				break
	elif consume_amount > 0 and (card_variable == "none" or fallback):
		moveCards(unit,consume_amount,0,deck,"consumed_deck")

func unitEliminateCards(unit:HexUnit, eliminate_amount:int = 1, deck:String = "active_deck", omit_card_id:String = "", match_card_id:String = "", card_variable:String = "none", card_variable_value = null, comparison = 0, permanent:bool = false) -> void:
	var matching_cards:Array = searchDeck(unit,deck,card_variable,card_variable_value,comparison, omit_card_id, match_card_id)
	var from_deck:Array = unit.get(deck)
	if matching_cards.size() > 0:
		for index in matching_cards:
			if eliminate_amount > 0:
				if index < from_deck.size():
					if permanent:
						unit.emit_signal("eliminate", from_deck[index].duplicate(true))
						unit.deck.remove(unit.deck.find(from_deck[index].card_name))
					if is_human:
						battle_gui.discard_card_pool.append(battle_gui.getCardGUI(from_deck[index].unique_id))
					from_deck.remove(index)
					eliminate_amount -= 1
			else:
				break
	if is_human:
		battle_gui.removeCards()

func unitAddCards(unit:HexUnit, add_amount:int = 1, deck:String = "active_deck", card_name:String = "", card_level:int = 0, is_caster = true) -> void:
	var to_deck:Array = unit.get(deck).duplicate(true)
	var temp_cards:Array = []
	if add_amount > 0:
		var card_data:Dictionary = CardLoader.loadSingleCardFile(card_name,true)
		card_data["card_owner"] = unit
		card_data["unique_id"] = str(unit) + " " + str(unit.deck.size())
#		prints(card_data["unique_id"], card_data["card_name"])
		if card_level == 0:
			for proficiency in unit.proficiencies:
				if proficiency[0] == card_data["card_name"]:
					card_data["card_level"] = proficiency[1] - 1
		else:
			card_data["card_level"] = card_level
		temp_cards.append(card_data)
		unit.deck.append(card_data["card_name"])
		add_amount -= 1
	to_deck.append_array(temp_cards)
	unit.set(deck, to_deck)
	if is_caster:
		if deck == "hand_deck":
			if is_human:
				for card in temp_cards:
					battle_gui.addCard(card)
					yield(battle_gui,"drawn_card")

func searchDeck(unit:HexUnit, deck:String = "active_deck", card_variable:String = "none", card_variable_value = null, comparison = 0, omit_card_id:String = "", match_card_id:String = "") -> Array:
	var matching_cards:Array
	for card in unit.get(deck).size():
		matching_cards.append(card)
	if match_card_id != "":
		for card in unit.get(deck).size():
			if match_card_id == unit.get(deck)[card].unique_id:
				matching_cards.clear()
				matching_cards.append(card)
				return matching_cards
	if omit_card_id != "":
		for card in unit.get(deck).size():
			if omit_card_id == unit.get(deck)[card].unique_id:
				matching_cards.remove(card)
	if card_variable != "none" and card_variable_value != null:
		matching_cards = []
		match card_variable:
			"card_name":
				for card in unit.get(deck).size():
					if (unit.get(deck)[card].unique_id != omit_card_id and omit_card_id != "") or omit_card_id == "":
						match comparison:
								0:
									if unit.get(deck)[card].get(card_variable) == card_variable_value:
										matching_cards.append(card)
								1:
									if unit.get(deck)[card].get(card_variable).length() > card_variable_value.length():
										matching_cards.append(card)
								2:
									if unit.get(deck)[card].get(card_variable).length() < card_variable_value.length():
										matching_cards.append(card)
								3:
									if (unit.get(deck)[card].get(card_variable) == card_variable_value) == false:
										matching_cards.append(card)
			"self_status":
				for card in unit.get(deck).size():
					if (unit.get(deck)[card].unique_id != omit_card_id and omit_card_id != "") or omit_card_id == "":
						var statuses = unit.get(deck)[card].self_statuses[unit.get(deck)[card].card_level]
						for status in statuses:
							match comparison:
								0:
									if status[0] == card_variable_value:
										matching_cards.append(card)
								1:
									if status[0] > card_variable_value:
										matching_cards.append(card)
								2:
									if status[0] < card_variable_value:
										matching_cards.append(card)
								3:
									if status[0] != card_variable_value:
										matching_cards.append(card)
			"target_status":
				for card in unit.get(deck).size():
					if (unit.get(deck)[card].unique_id != omit_card_id and omit_card_id != "") or omit_card_id == "":
						var statuses = unit.get(deck)[card].target_statuses[unit.get(deck)[card].card_level]
						for status in statuses:
							match comparison:
								0:
									if status[0] == card_variable_value:
										matching_cards.append(card)
								1:
									if status[0] > card_variable_value:
										matching_cards.append(card)
								2:
									if status[0] < card_variable_value:
										matching_cards.append(card)
								3:
									if status[0] != card_variable_value:
										matching_cards.append(card)
			"elements":
				for card in unit.get(deck).size():
					if (unit.get(deck)[card].unique_id != omit_card_id and omit_card_id != "") or omit_card_id == "":
						var elements = unit.get(deck)[card].elements[unit.get(deck)[card].card_level]
						for element in elements:
							match comparison:
								0:
									if element == card_variable_value:
										matching_cards.append(card)
								1:
									if element > card_variable_value:
										matching_cards.append(card)
								2:
									if element < card_variable_value:
										matching_cards.append(card)
								3:
									if element != card_variable_value:
										matching_cards.append(card)
			"card_class", "card_type", "card_level", "rarity":
				for card in unit.get(deck).size():
					if (unit.get(deck)[card].unique_id != omit_card_id and omit_card_id != "") or omit_card_id == "":
						match comparison:
								0:
									if unit.get(deck)[card].get(card_variable) == card_variable_value:
										matching_cards.append(card)
								1:
									if unit.get(deck)[card].get(card_variable) > card_variable_value:
										matching_cards.append(card)
								2:
									if unit.get(deck)[card].get(card_variable) < card_variable_value:
										matching_cards.append(card)
								3:
									if unit.get(deck)[card].get(card_variable) != card_variable_value:
										matching_cards.append(card)
			_:
				for card in unit.get(deck).size():
					if (unit.get(deck)[card].unique_id != omit_card_id and omit_card_id != "") or omit_card_id == "":
						match comparison:
								0:
									if unit.get(deck)[card].get(card_variable)[unit.get(deck)[card].card_level] == card_variable_value:
										matching_cards.append(card)
								1:
									if unit.get(deck)[card].get(card_variable)[unit.get(deck)[card].card_level] > card_variable_value:
										matching_cards.append(card)
								2:
									if unit.get(deck)[card].get(card_variable)[unit.get(deck)[card].card_level] < card_variable_value:
										matching_cards.append(card)
								3:
									if unit.get(deck)[card].get(card_variable)[unit.get(deck)[card].card_level] != card_variable_value:
										matching_cards.append(card)
	return matching_cards

#active_deck:Array = [] # Array of card dictionaries for in-game use
#var hand_deck:Array = [] # Array of card dictionaries for in-game use. Each hand is made at the beginning of each round.
#var discard_deck:Array = [] # Array of card dictionaries for in-game use. 
#var consume_deck:Array = []
func moveCards(unit:HexUnit, draw_amount:int = 1, index:int = 0, from_deck:String = "active_deck", to_deck:String = "hand_deck", fallback:bool = true) -> void:
	var temp_cards:Array
	var from:Array = unit.get(from_deck).duplicate(true)
	var to:Array = unit.get(to_deck).duplicate(true)
	var discard:Array
	while draw_amount > 0:
		if index < from.size():
			to.append(from[index])
			temp_cards.append(from[index])
			match to_deck:
				"discard_deck":
					unit.emit_signal("discard", from[index])
				"consumed_deck":
					unit.emit_signal("consume", from[index])
				"hand_deck":
					unit.emit_signal("draw", from[index])
			if to_deck == "discard_deck" and is_human:
				battle_gui.discard_card_pool.append(battle_gui.getCardGUI(from[index].unique_id))
			if to_deck == "consumed_deck" and is_human:
				battle_gui.consume_card_pool.append(battle_gui.getCardGUI(from[index].unique_id))
			from.remove(index)
			draw_amount -= 1
			if from_deck == "active_deck" and to_deck == "hand_deck":
				unit.current_draw_points -= 1
		elif fallback and from.size() > 0:
			to.append(from[0])
			temp_cards.append(from[0])
			match to_deck:
				"discard_deck":
					unit.emit_signal("discard", from[0])
				"consumed_deck":
					unit.emit_signal("consume", from[0])
				"hand_deck":
					unit.emit_signal("draw", from[0])
			if to_deck == "discard_deck" and is_human:
				battle_gui.discard_card_pool.append(battle_gui.getCardGUI(from[0].unique_id))
			if to_deck == "consumed_deck" and is_human:
				battle_gui.consume_card_pool.append(battle_gui.getCardGUI(from[0].unique_id))
			from.remove(0)
			draw_amount -= 1
			if from_deck == "active_deck" and to_deck == "hand_deck":
				unit.current_draw_points -= 1
				unit.emit_signal("draw", from[0])
		else:
			break
	match from_deck:
		"active_deck":
			unit.active_deck = from
		"hand_deck":
			unit.hand_deck = from
		"discard_deck":
			unit.discard_deck = from
		"consumed_deck":
			unit.consumed_deck = from
	match to_deck:
		"active_deck":
			unit.active_deck = to
			if from_deck == "discard_deck":
				emit_signal("recover_discard", self, unit)
				unit.emit_signal("recover_discard")
		"hand_deck":
			unit.hand_deck = to
			var drawn_cards:int = 0
			if is_human and temp_cards.size() > 0 and from_deck == "active_deck":
				for card in temp_cards:
					var new_card = battle_gui.addCard(card)
					yield(battle_gui,"drawn_card")
					drawn_cards += 1
			if drawn_cards == temp_cards.size() and unit.current_draw_points > 0 and unit.active_deck.size() == 0 and from_deck == "active_deck":
				if unit.discard_deck.size() > 0:
					moveCards(unit,unit.discard_deck.size(),0,"discard_deck","active_deck")
					randomize()
					unit.active_deck.shuffle()
					if is_human:
						var sound = UI_Sounds.createSound(UI_Sounds.deck_shuffle)
					emit_signal("reshuffle", self, unit)
					moveCards(unit,unit.current_draw_points,0,"active_deck","hand_deck")
			emit_signal("hand_drawn", self, unit)
		"discard_deck":
			unit.discard_deck = to
			if from_deck == "hand_deck":
				battle_gui.removeCards()
		"consumed_deck":
			unit.consumed_deck = to
			if from_deck == "hand_deck":
				battle_gui.consumeCards()

func moveCardsToTop(unit:HexUnit, draw_amount:int = 1, index:int = 0, deck:String = "active_deck") -> void:
	var new_deck:Array = unit.get(deck).duplicate(true)
	while draw_amount > 0:
		if index < new_deck.size():
			new_deck.push_front(unit.get(deck)[index])
			new_deck.remove(index+1)
			draw_amount -= 1
		else:
			break
	match deck:
		"active_deck":
			unit.active_deck = new_deck
		"hand_deck":
			unit.hand_deck = new_deck
		"discard_deck":
			unit.discard_deck = new_deck
		"consumed_deck":
			unit.consumed_deck = new_deck

func updateCardGUI(unit, card) -> void:
	battle_gui.getCardGUI(card.unique_id).loadNewCardData(card)
	battle_gui.getCardGUI(card.unique_id).updateCardInfo(unit)

func setupUnits() -> void: # Resets movement points, AP, magic evasion, and physical evasion
	for unit in units:
		unit.current_movement_points = unit.max_movement_points
		unit.current_jump_points = unit.max_jump_points
		unit.current_action_points = min(unit.current_action_points + unit.current_action_points_regen, unit.max_action_points)
		if unit.current_health > 0:
			unit.isSelectable = true
		else:
			unit.isSelectable = false

func startRound() -> void:
	setupUnits()

func endRound() -> void:
	pass
