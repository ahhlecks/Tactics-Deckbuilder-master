extends Node


class_name TurnQueue

var current_round_list:Array
var next_round_list:Array
var next_round_cards:Array #[index, card]
var active_tab
var turn_counter = 0
var round_counter = 0
var still_alive:bool = true
var enemy_still_alive:bool = true
onready var battle_controller = get_parent()
onready var battle_gui = $"../BattleGUI"
var units:Array

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_BattleController_match_started():
	for unit in units:
		unit.initiative_counter = 0
	current_round_list = calculateInitiative(units)
#	next_round_list = calculateInitiative()
	turn_counter = 0
	battle_controller.self_player.loadUnitDecks()
	battle_controller.enemy_player.loadUnitDecks()
	battle_controller.self_player.startRound()
	battle_controller.enemy_player.startRound()
	battle_gui.setupTurnTabs(current_round_list)
	active_tab = current_round_list[turn_counter]
	yield(get_tree(), "idle_frame")
	battle_controller.emit_signal("round_started")
	play_turn()

func play_turn() -> void:
	if active_tab is HexUnit:
		if active_tab.current_health > 0:
			battle_controller.emit_signal("turn_started",active_tab,active_tab.unit_owner) # This is a unit being played
		else:
			battle_controller.emit_signal("turn_ended",active_tab,active_tab.unit_owner)
	elif active_tab is Dictionary:
		if active_tab.card_caster.current_health > 0:
			battle_controller.emit_signal("unit_acted",active_tab.card_caster,active_tab.card_caster.unit_owner, active_tab, active_tab.card_caster.currentCell, active_tab.target_cell) # unit, player, card, from, to
		else:
			endTurn()

func endTurn() -> void:
	checkWinConditions()
	battle_gui.turn_tabs.shiftAllTabsDown()
	for unit in get_children():
		unit.queue_number -= 1
	if active_tab is HexUnit:
		active_tab.endTurn()
	if turn_counter < current_round_list.size() -1:
		turn_counter += 1
		active_tab = current_round_list[turn_counter]
		play_turn()
	else:
		battle_controller.battle_gui.endRound()

func endRound():
#	battle_controller.self_player.endRound()
#	battle_controller.enemy_player.endRound()
	for unit in units:
		unit.evasion_degradation = 0
	battle_controller.self_player.startRound()
	battle_controller.enemy_player.startRound()
	current_round_list = removeDeadFromList(calculateInitiative(units))
	for card in next_round_cards:
		current_round_list.insert(card[0],card[1])
	next_round_cards.clear()
	battle_gui.setupTurnTabs(current_round_list)
	if checkWinConditions() == "":
		active_tab = current_round_list[0]
		round_counter += 1
		turn_counter = 0
		battle_controller.emit_signal("round_started")
		play_turn()

func checkWinConditions() -> String:
	current_round_list = removeDeadFromList(current_round_list)
	var units_alive:int = 0
	var enemy_units_alive:int = 0
	for unit in units:
		if unit is HexUnit:
			if unit.player_owned and unit.current_health > 0:
				units_alive += 1
				still_alive = true
			if !unit.player_owned and unit.current_health > 0:
				enemy_units_alive += 1
				enemy_still_alive = true
	if units_alive == 0 and enemy_units_alive == 0:
		print("double knockout")
		battle_controller.emit_signal("match_ended", 1)
		return "double knockout"
	if units_alive == 0:
		print("all player's units are dead")
		battle_controller.emit_signal("match_ended", 0)
		return "lose"
	if enemy_units_alive == 0:
		print("all enemy units are dead")
		battle_controller.emit_signal("match_ended", 1)
		return "win"
	return ""

func sortUnits() -> Array:
	var valid_units:Array = get_children()
	valid_units.sort_custom(UnitSpeedSorter, "sort_descending")
	for i in valid_units.size():
		valid_units[i].queue_number = i + 1
	return valid_units

func calculateInitiative(units:Array = []) -> Array:
	var initiative_list:Array = []
#	valid_units.sort_custom(UnitSpeedSorter, "sort_descending")
	var break_loop:bool = false
	for i in range(100):
		if !break_loop:
			for unit in units:
				unit.initiative_counter += unit.current_speed
				if unit.initiative_counter >= 100:
					unit.initiative_counter = 0
					initiative_list.append(unit)
				if initiative_list.size() == units.size():
					break_loop = true
					break
		else:
			break
	for unit in initiative_list.size():
		initiative_list[unit].queue_number = unit + 1
	current_round_list = initiative_list
	return initiative_list

func addCardNextRound(index:int, card) -> void:
	next_round_cards.append([index,card])

func removeDeadFromList(list) -> Array:
	if list.size() > 0:
		var listWithoutDead:Array = list
		for i in range(listWithoutDead.size() - 1, -1, -1):
			if listWithoutDead[i] is HexUnit:
				if listWithoutDead[i].current_health <= 0:
					listWithoutDead.remove(i)
		return listWithoutDead
	return []

class UnitSpeedSorter:
	static func sort_descending(a, b):
		if a.current_speed > b.current_speed:
			return true
		return false
