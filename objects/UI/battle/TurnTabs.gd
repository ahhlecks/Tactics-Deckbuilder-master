extends Control

var UnitTabGUI = preload("res://objects/UI/battle/UnitTabGUI.tscn")
var CardTabGUI = preload("res://objects/UI/battle/CardTabGUI.tscn")

onready var smooth_step = preload("res://resources/effects/smooth_step_curve.tres")

var current_round_list:Array
var next_round_list:Array

var tab_gap:int = 80

# Called when the node enters the scene tree for the first time.
func _ready():
	pause_mode = PAUSE_MODE_PROCESS

func addUnit(unit, index) -> void:
	var unit_tab = UnitTabGUI.instance()
	unit_tab.updateGUI(unit)
	unit_tab.add_to_group("units")
	add_child(unit_tab)
	unit_tab.rect_position = Vector2(0, rect_size.y) - Vector2(0, (index) * (tab_gap))
	unit_tab.set_meta("index", index)
	if get_child_count() > 0:
		shiftTabs(unit_tab)

func addCard(card, index) -> void:
	var card_tab = CardTabGUI.instance()
	card_tab.updateGUI(card)
	card_tab.add_to_group("cards")
	add_child(card_tab)
	card_tab.rect_position = Vector2(0, rect_size.y) - Vector2(0, (index) * (tab_gap))
	card_tab.set_meta("index", index)
	if get_child_count() > 0:
		shiftTabs(card_tab)

func updateTabs() -> void:
	var unit_tabs:Array = get_tree().get_nodes_in_group("units")
	var card_tabs:Array = get_tree().get_nodes_in_group("cards")
	var unit_list:Array = getUnitList(current_round_list)
	var card_list:Array = getCardList(current_round_list)
	for i in unit_list.size():
		unit_tabs[i].updateGUI(unit_list[i])
	for i in card_list.size():
		card_tabs[i].updateGUI(card_list[i])

func createTabs() -> void:
	for old_tabs in get_children():
		old_tabs.call_deferred("queue_free")
	for i in current_round_list.size():
		if current_round_list[i] is HexUnit:
			addUnit(current_round_list[i], i)
		elif current_round_list[i] is Dictionary:
			addCard(current_round_list[i], i)

func shiftTabs(new_tab) -> void: # Shifts all tabs above "new_tab" up
	for tab in get_children():
		if tab != new_tab:
			var old_index:int = tab.get_meta("index")
			if tab.get_meta("index") >= new_tab.get_meta("index"):
				tab.set_meta("index", old_index + 1)
				var new_index:int = tab.get_meta("index")
#				tab.rect_position = Vector2(0, rect_size.y) - Vector2(0, (new_index) * (tab_gap))
				tab.end_pos.y = tab.rect_position.y - tab_gap
				tab.setup = true
				tab.shifting = true

func shiftAllTabsDown() -> void:
	for tab in get_children():
		tab.end_pos.y = tab.rect_position.y + tab_gap
		tab.setup = true
		tab.shifting = true

func updatePositions() -> void:
	rect_position = Vector2(0,0)
	for tab in get_children():
		tab.rect_position = Vector2(0, rect_size.y) - Vector2(0, (tab.get_meta("index")) * (tab_gap))
		tab.rect_position.y += $"../../".turn_queue.turn_counter * tab_gap

func getUnitList(round_list) -> Array:
	var unit_list:Array
	for i in round_list:
		if i is HexUnit:
			unit_list.append(i)
	return unit_list

func getCardList(round_list) -> Array:
	var card_list:Array
	for i in round_list:
		if i is Dictionary:
			card_list.append(i)
	return card_list

func clear() -> void:
	for tab in get_children():
		tab.call_deferred("queue_free")
		remove_child(tab)
