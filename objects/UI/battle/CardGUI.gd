extends Control

class_name CardGUI

# This is the Card GUI element that you see on screen

var card_info:Dictionary
#onready var card = get_node("CardActor")
var unique_id:String
onready var battle_gui = $'../..'
onready var battle_controller = $'../../..'
onready var card_art = $CardArt
onready var card_front = $CardFront
onready var card_highlight = $CardHighlight
onready var card_act = $TextureButton/Act
onready var card_react = $TextureButton/React
onready var card_ap = $VBoxContainer/HBoxContainer/AP
onready var card_name = $VBoxContainer/HBoxContainer/Name
onready var card_type = $VBoxContainer/HBoxContainer2/Type
onready var card_description = $TextureButton/HBoxContainer3/Description
onready var card_delay = $TextureButton/HBoxContainer/Delay
onready var card_delay_hint = $TextureButton/HBoxContainer/MarginContainer
onready var card_range = $TextureButton/HBoxContainer/Range
onready var card_range_hint = $TextureButton/HBoxContainer/MarginContainer3
onready var button = $TextureButton
var card_owner:HexUnit
var target_unit:HexUnit
var activated:bool = false
var clicked:bool = false
var mouse_in:bool = false

var card_front_paths = {
	0 : "res://assets/images/card_bases/WarriorCard.png",
	1 : "res://assets/images/card_bases/RangerCard.png", 
	2 : "res://assets/images/card_bases/MageCard.png",
	3 : "res://assets/images/card_bases/WarriorRangerCard.png",
	4 : "res://assets/images/card_bases/RangerMageCard.png",
	5 : "res://assets/images/card_bases/MageWarriorCard.png",
	6 : "res://assets/images/card_bases/AllClassCard.png"
	}

var card_types = {
	0 : "Skill",
	1 : "Physical Attack",
	2 : "Magic Attack",
	3 : "Magic Spell",
	4 : "Item"
	}

var card_pos:Vector2
var card_rotation
var start_pos:Vector2
var end_pos:Vector2
var middle_pos:Vector2
var start_rotation
var end_rotation
var start_scale:Vector2
var end_scale:Vector2 = Vector2(1,1)
var zoom_size:float = 1
var mouse_size:float = .75
var play_size:float = 1
var time:float = 0
var card_speed:float = .16
var move_time:float = card_speed * 1.1
var shift_time:float = card_speed
var zoom_time:float = card_speed / 2
var mouse_time:float = card_speed / 2
var active_shift:float = 60
var reaction_ap_add:bool = false

onready var card_focus = preload("res://assets/sounds/ui/cards/Card_Focus.wav")
onready var smooth_step = preload("res://resources/effects/smooth_step_curve.tres")

var active_slot

enum {
	InHand,
	InHandActive,
	InPlay,
	InSlot,
	InMouse,
	FocusInHand,
	MoveDrawnCardToHand,
	ReorganizeHand,
	MoveHandToDiscard,
	Discard
}

var state = InHand
var setup:bool = true
var reorganize_neighbors:bool = true
var num_cards_in_hand:int
var card_number:int
var move_neighbor_card_check = false
var drag_option:bool = false

signal drawn_card
signal discard_card
signal organized

var card_selected:bool = false
var previous_state = INF

# Called when the node enters the scene tree for the first time.
func _ready():
	deactivate()
#	card.load_card(card_info)
	pause_mode = PAUSE_MODE_INHERIT
#	card_info = card_info
#	updateCardInfo(null)

func loadNewCardData(data) -> void:
#	card.load_card(data)
	card_info = data

func updateCardInfo(unit:HexUnit) -> void:
	card_owner = card_info.card_owner
	unique_id = card_info.unique_id
	card_art.texture = load("res://assets/images/card_art/"+card_info.card_art)
	card_front.texture = load(card_front_paths.get(card_info.card_class))
	card_act.visible = card_info.can_attack[card_info.card_level]
	card_react.visible = card_info.can_defend[card_info.card_level]
	if unit != null:
		card_ap.text = str(max(card_info.action_costs[card_info.card_level] - int(card_info.has_combo[card_info.card_level] and unit.has_combo),0))
		$TextureButton/AP_Hint.hint_tooltip = str(max(card_info.action_costs[card_info.card_level] - int(card_info.has_combo[card_info.card_level] and unit.has_combo),0)) + " Action Points are required to play this card."
	else:
		card_ap.text = str(card_info.action_costs[card_info.card_level])
		$TextureButton/AP_Hint.hint_tooltip = str(card_info.action_costs[card_info.card_level]) + " Action Points are required to play this card."
	card_name.text = card_info.card_name + " " + BattleDictionary.toRoman(card_info.card_level + 1)
	card_type.text = card_types.get(card_info.card_type)
	card_description.bbcode_text = "[center]" + card_info.description[card_info.card_level] + "[/center]"
	card_delay.text = str(round(float(card_info.delay[card_info.card_level]) * float(battle_controller.turn_queue.get_child_count()) / 100.0))
	card_range.text = str(card_info.card_min_range[card_info.card_level]) + " - " + str(card_info.card_max_range[card_info.card_level])

func _input(event):
	if activated:
		match state:
			FocusInHand, InMouse:
				if drag_option:
					if event.is_action_pressed("mouse_left"):
						card_selected = true
						if card_selected:
							setup = true
							end_rotation = 0
							end_pos.y = get_viewport().size.y - ((card_front.texture.get_size().y / 2)*play_size)
							end_pos.x = battle_gui.bottom.x
							state = InMouse
							previous_state = state
					if event.is_action_released("mouse_left"):
						if card_selected:
							if rect_position.y < battle_gui.bottom.y - 200:
								visible = false
								setup = true
		#						end_pos = Vector2(304,3) + battle_gui.selected_unit.get_global_position()
								state = InPlay
								previous_state = state
							else:
								visible = true
								setup = true
								end_rotation = card_rotation
								end_pos = card_pos
								end_pos.y -= active_shift
								state = FocusInHand
								previous_state = state
								card_selected = false
				else:
					if event.is_action_pressed("mouse_left"):
						card_selected = true
						if card_selected:
							setup = true
							end_rotation = 0
							end_pos.y = get_viewport().size.y - ((card_front.texture.get_size().y / 2)*play_size)
							end_pos.x = battle_gui.bottom.x
							state = InPlay
							previous_state = state
			InPlay:
				if event.is_action_pressed("mouse_left") and button.get_global_rect().has_point(get_global_mouse_position()):
					if battle_gui.selected_hex != null:
						get_tree().paused = false
						battle_gui.accept_target()

func _physics_process(delta):
	match state:
		InHand:
			if setup:
				setup()
			if time <= 1:
				rect_position.x = start_pos.x + (smooth_step.interpolate(time) * (end_pos.x - start_pos.x))
				rect_position.y = start_pos.y + (smooth_step.interpolate(time) * (end_pos.y - start_pos.y))
				rect_scale.x = start_scale.x + (smooth_step.interpolate(time) * (end_scale.x - start_scale.x))
				rect_scale.y = start_scale.y + (smooth_step.interpolate(time) * (end_scale.y - start_scale.y))
				time += delta / move_time
			else:
				rect_position = end_pos
		InHandActive:
			if setup:
				setup()
			if time <= 1:
				rect_position.x = start_pos.x + (smooth_step.interpolate(time) * (end_pos.x - start_pos.x))
				rect_position.y = start_pos.y + (smooth_step.interpolate(time) * (end_pos.y - start_pos.y))
				rect_scale.x = start_scale.x + (smooth_step.interpolate(time) * (end_scale.x - start_scale.x))
				rect_scale.y = start_scale.y + (smooth_step.interpolate(time) * (end_scale.y - start_scale.y))
				time += delta / move_time
			else:
				rect_position = end_pos
		InPlay:
			if setup:
				setup()
				pause_mode = PAUSE_MODE_PROCESS
				var unit = battle_gui.active_unit
#				if card_selected:
				battle_gui.selected_card = self # make this card the battle gui selected card
				battle_gui.card_actor.load_card(card_info)
#					battle_gui.lockUnits(true)
#					battle_gui.lockActionPanels(true)
				battle_gui.activateAllCards(false,false)
				activate()
				visible = false
				if battle_gui.active_panel == battle_gui.act_panel:
					if card_info.card_max_range[card_info.card_level] != 0:
						battle_gui.showRange(card_info)
						battle_gui.world_environment.environment.dof_blur_far_enabled = false
						battle_gui.promptAct("Select a target.")
						battle_gui.enableMouseHighlight()
						battle_gui.camera.unfocusTarget()
					else:
						battle_gui.card_actor.card_caster = battle_gui.active_unit
						battle_gui.card_actor.source_cell = battle_gui.active_unit.currentCell
						battle_gui.card_actor.target_cell = battle_gui.card_actor.source_cell
						battle_gui.world_environment.environment.dof_blur_far_enabled = false
						battle_gui.card_actor.execute(false)
						battle_gui.selected_hex = battle_gui.card_actor.source_cell
						if battle_gui.card_actor.blackboard.has_data("targets"):
							battle_gui.valid_targets = battle_gui.card_actor.blackboard.get_data("targets")
						else:
							battle_gui.valid_targets = [battle_gui.card_actor.target_cell]
						battle_gui.accept_target()
				elif battle_gui.active_panel == battle_gui.react_panel:
					battle_gui.card_actor.card_caster = battle_gui.active_unit
					battle_gui.card_actor.source_cell = battle_gui.active_unit.currentCell
					battle_gui.card_actor.target_cell = battle_gui.card_actor.source_cell
					battle_gui.selected_hex = battle_gui.card_actor.source_cell
					battle_gui.world_environment.environment.dof_blur_far_enabled = false
					battle_gui.setReactCard()
			if time <= 1:
				rect_position.x = start_pos.x + (smooth_step.interpolate(time) * (end_pos.x - start_pos.x))
				rect_position.y = start_pos.y + (smooth_step.interpolate(time) * (end_pos.y - start_pos.y))
				rect_scale.x = start_scale.x + (smooth_step.interpolate(time) * (end_scale.x*play_size - start_scale.x))
				rect_scale.y = start_scale.y + (smooth_step.interpolate(time) * (end_scale.y*play_size - start_scale.y))
				rect_rotation = start_rotation * (1-time)
				time += delta / mouse_time
			else:
				rect_rotation = 0
				rect_scale = end_scale*play_size
				rect_position = end_pos
				moveToFront()
#				if visible:
#					moveToBack()
#				visible = false
		InMouse:
			if setup:
				setup()
#				var unit = battle_gui.selected_unit.unit_id
#				if card_selected:
#					battle_gui.selected_card = self # make this card the battle gui selected card
#					battle_gui.lockUnits(true)
#					battle_gui.activateAllCards(false)
#					battle_gui.showRange(card_info)
#					battle_gui.activateCard(self)
#					battle_gui.promptAct("Select a target")
#					battle_gui.camera.unfocusTarget()
			if time <= 1:
				rect_position.x = start_pos.x + (smooth_step.interpolate(time) * (get_global_mouse_position().x - start_pos.x))
				rect_position.y = start_pos.y + (smooth_step.interpolate(time) * (get_global_mouse_position().y - start_pos.y))
				rect_scale.x = start_scale.x + (smooth_step.interpolate(time) * (end_scale.x*mouse_size - start_scale.x))
				rect_scale.y = start_scale.y + (smooth_step.interpolate(time) * (end_scale.y*mouse_size - start_scale.y))
				rect_rotation = start_rotation * (1-time)
				time += delta / mouse_time
			else:
				rect_rotation = 0
				rect_scale = end_scale*mouse_size
				rect_position = get_global_mouse_position()
				#print(get_global_mouse_position())
#				if rect_position.y < battle_gui.bottom.y - 260:
#					print('high enough')
		FocusInHand:
			if setup:
				setup()
				card_selected = false
			if time <= 1:
				rect_position.x = start_pos.x + (smooth_step.interpolate(time) * (end_pos.x - start_pos.x))
				rect_position.y = start_pos.y + (smooth_step.interpolate(time) * (end_pos.y - start_pos.y))
				rect_scale.x = start_scale.x + (smooth_step.interpolate(time) * (end_scale.x*zoom_size - start_scale.x))
				rect_scale.y = start_scale.y + (smooth_step.interpolate(time) * (end_scale.y*zoom_size - start_scale.y))
				rect_rotation = start_rotation * (1-time)
				time += delta / zoom_time
				if reorganize_neighbors:
					reorganize_neighbors = false
					num_cards_in_hand = $'../'.get_child_count()
					if card_number - 1 >= 0:
						moveNeighborCard(card_number - 1,true,1)
					if card_number - 2 >= 0:
						moveNeighborCard(card_number - 2,true,.33)
					if card_number + 1 < num_cards_in_hand:
						moveNeighborCard(card_number + 1,false,1)
					if card_number + 2 < num_cards_in_hand:
						moveNeighborCard(card_number + 2,false,.33)
			else:
				rect_position = end_pos
				rect_rotation = end_rotation
				rect_scale = end_scale*zoom_size
		MoveDrawnCardToHand:
			if setup:
				setup()
#				card = Card.new()
#				card.load_card(card_info)
				updateCardInfo(battle_gui.active_unit)
			if time <= 1:
				rect_position.x = start_pos.x + (smooth_step.interpolate(time) * (end_pos.x - start_pos.x))
				rect_position.y = start_pos.y + (smooth_step.interpolate(time) * (end_pos.y - start_pos.y))
				rect_scale.x = start_scale.x + (smooth_step.interpolate(time) * (end_scale.x - start_scale.x))
				rect_scale.y = start_scale.y + (smooth_step.interpolate(time) * (end_scale.y - start_scale.y))
				rect_rotation = start_rotation * (1-time) + end_rotation * time
				time += delta / move_time
			else:
				rect_position = end_pos
				rect_rotation = end_rotation
				rect_scale = end_scale
				state = InHand
				emit_signal("drawn_card")
		ReorganizeHand:
			if setup:
				setup()
			if time <= 1:
				if move_neighbor_card_check:
					move_neighbor_card_check = false
				rect_position.x = start_pos.x + (smooth_step.interpolate(time) * (end_pos.x - start_pos.x))
				rect_position.y = start_pos.y + (smooth_step.interpolate(time) * (end_pos.y - start_pos.y))
				rect_scale.x = start_scale.x + (smooth_step.interpolate(time) * (end_scale.x - start_scale.x))
				rect_scale.y = start_scale.y + (smooth_step.interpolate(time) * (end_scale.y - start_scale.y))
				rect_rotation = start_rotation * (1-time) + end_rotation * time
				time += delta / shift_time
				if !reorganize_neighbors:
					reorganize_neighbors = true
					if card_number - 1 >= 0:
						reset(card_number - 1)
					if card_number - 2 >= 0:
						reset(card_number - 2)
					if card_number + 1 < num_cards_in_hand:
						reset(card_number + 1)
					if card_number + 2 < num_cards_in_hand:
						reset(card_number + 2)
			else:
				rect_position = end_pos
				rect_rotation = end_rotation
				rect_scale = end_scale
				emit_signal("organized")
		MoveHandToDiscard:
			visible = true
			if reaction_ap_add:
				reaction_ap_add = false
				card_info.action_costs[card_info.card_level] -= 1
				card_ap.text = str(card_info.action_costs[card_info.card_level])
			if setup:
				setup()
				for i in battle_gui.cards.get_children():
					if i.card_number > card_number:
						i.card_number -= 1
			if time <= 1:
				rect_position.x = start_pos.x + (smooth_step.interpolate(time) * (end_pos.x - start_pos.x))
				rect_position.y = start_pos.y + (smooth_step.interpolate(time) * (end_pos.y - start_pos.y))
				rect_scale.x = start_scale.x + (smooth_step.interpolate(time) * (end_scale.x - start_scale.x))
				rect_scale.y = start_scale.y + (smooth_step.interpolate(time) * (end_scale.y - start_scale.y))
				rect_rotation = start_rotation * (1-time) + end_rotation * time
				time += delta / move_time
			else:
				rect_position = end_pos
				rect_rotation = end_rotation
				rect_scale = end_scale
				card_selected = false
#				for cards in battle_gui.active_unit.hand_deck:
#					if card_info.card_id == cards.card_id:
#						battle_gui.active_unit.hand_deck.erase(cards)
#						battle_gui.active_unit.unit_hand_size = battle_gui.active_unit.hand_deck.size()
#						battle_gui.active_unit.discard_deck.append(card_info)
#						battle_gui.active_unit.unit_discard_size = battle_gui.active_unit.discard_deck.size()
#				print(unique_id)
				moveToBack()
#				remove_child(card)
#				card.free()
				battle_gui.cards.remove_child(self)
				emit_signal("discard_card")
				clear()

# warning-ignore:function_conflicts_variable
func setup() -> void:
	start_pos = rect_position
	start_rotation = rect_rotation
	start_scale = rect_scale
	time = 0
	setup = false

func moveNeighborCard(card_number:int,is_left:bool,spread_factor:float) ->void:
	var neighbor_card = $'..'.get_child(card_number)
	if neighbor_card != null:
		if neighbor_card.state != MoveDrawnCardToHand and neighbor_card.activated and neighbor_card.state != InPlay:
			if is_left:
				neighbor_card.end_pos = neighbor_card.card_pos - spread_factor*Vector2(50,0) - Vector2(0,active_shift)
			else:
				neighbor_card.end_pos = neighbor_card.card_pos + spread_factor*Vector2(50,0) - Vector2(0,active_shift)
			neighbor_card.setup = true
			neighbor_card.state = ReorganizeHand
			neighbor_card.move_neighbor_card_check = true

func reset(card_number) -> void:
	var neighbor_card = $'..'.get_child(card_number)
	if neighbor_card != null:
		if neighbor_card.move_neighbor_card_check == false and neighbor_card.state != FocusInHand and neighbor_card.activated and neighbor_card.state != InPlay:
			neighbor_card.end_pos = neighbor_card.card_pos + Vector2(0,-active_shift)
			neighbor_card.end_rotation = neighbor_card.card_rotation
			neighbor_card.setup = true
			if neighbor_card.state != FocusInHand:
				neighbor_card.state = ReorganizeHand


func moveToBack() -> void:
#	show_on_top = false
#	mouse_filter = MOUSE_FILTER_IGNORE
#	button.mouse_filter = MOUSE_FILTER_IGNORE
#	for hints in button.get_children():
#		hints.mouse_filter = MOUSE_FILTER_IGNORE
#	card_description.mouse_filter = MOUSE_FILTER_IGNORE
#	card_delay_hint.mouse_filter = MOUSE_FILTER_IGNORE
#	card_range_hint.mouse_filter = MOUSE_FILTER_IGNORE
	if get_parent().get_child_count() > 0:
		for cards in $'..'.get_children():
#			if cards.card_number != card_number:
			cards.show_on_top = true
			cards.mouse_filter = MOUSE_FILTER_PASS
			cards.button.mouse_filter = MOUSE_FILTER_PASS
			for hints in cards.button.get_children():
				hints.mouse_filter = MOUSE_FILTER_PASS
			cards.card_description.mouse_filter = MOUSE_FILTER_PASS
			cards.card_delay_hint.mouse_filter = MOUSE_FILTER_PASS
			cards.card_range_hint.mouse_filter = MOUSE_FILTER_PASS

func moveToFront() -> void:
#	pass
	show_on_top = true
	mouse_filter = MOUSE_FILTER_PASS
	button.mouse_filter = MOUSE_FILTER_PASS
	for hints in button.get_children():
		hints.mouse_filter = MOUSE_FILTER_PASS
	card_description.mouse_filter = MOUSE_FILTER_PASS
	card_delay_hint.mouse_filter = MOUSE_FILTER_PASS
	card_range_hint.mouse_filter = MOUSE_FILTER_PASS
	if get_parent().get_child_count() > 1:
		for cards in $'..'.get_children():
			if cards.card_number > card_number:
				cards.show_on_top = false
				cards.mouse_filter = MOUSE_FILTER_IGNORE
				cards.button.mouse_filter = MOUSE_FILTER_IGNORE
				for hints in cards.button.get_children():
					hints.mouse_filter = MOUSE_FILTER_IGNORE
				cards.card_description.mouse_filter = MOUSE_FILTER_IGNORE
				cards.card_delay_hint.mouse_filter = MOUSE_FILTER_IGNORE
				cards.card_range_hint.mouse_filter = MOUSE_FILTER_IGNORE

func activate() -> void:
	if battle_gui.active_panel == battle_gui.react_panel and reaction_ap_add == false:
		reaction_ap_add = true
		card_info.action_costs[card_info.card_level] += 1
		card_ap.text = str(card_info.action_costs[card_info.card_level])
	visible = true
	battle_gui.world_environment.environment.dof_blur_far_enabled = true
	activated = true
	modulate = Color.white
	match state:
		InHand, ReorganizeHand:
			setup = true
			end_rotation = card_rotation
			end_pos = card_pos - Vector2(0,active_shift)
			state = InHandActive

func deactivate() -> void:
	if reaction_ap_add:
		reaction_ap_add = false
		card_info.action_costs[card_info.card_level] -= 1
		card_ap.text = str(card_info.action_costs[card_info.card_level])
	battle_gui.world_environment.environment.dof_blur_far_enabled = false
	activated = false
	modulate = Color.white.darkened(.66)
	match state:
		InHandActive, ReorganizeHand:
			setup = true
			end_rotation = card_rotation
			end_pos = card_pos
			state = InHand

func cancelInPlay() -> void:
	activate()
	var slot = battle_gui.selected_slot
	var unit = battle_gui.active_unit
	battle_gui.selected_card = null
	visible = true
	unit.clearValidRangeCells()
#	battle_gui.camera.toggleFocus()

#func playInPlay() -> void:
#	var slot = battle_gui.selected_slot
#	var card_slot_pos = slot.global_position
#	var card_slot_size = (slot.texture.get_size()/2) * .27
#	var mouse_pos = get_global_mouse_position()
#	var unit = battle_gui.selected_unit.unit_id
#	if mouse_pos.x > card_slot_pos.x - card_slot_size.x and mouse_pos.x < card_slot_pos.x + card_slot_size.x:
#		if mouse_pos.y > card_slot_pos.y - card_slot_size.y and mouse_pos.y < card_slot_pos.y + card_slot_size.y:
#	setup = true
#	end_rotation = 0
#	end_pos = card_pos
#	end_pos.y = get_viewport().size.y - ((card_front.texture.get_size().y / 2) * zoom_size)
#	state = FocusInHand
#	previous_state = state
#	slot = battle_gui.selected_unit.gui_card_slot
#	card_selected = false
#	battle_gui.lockUnits(false)
#	battle_gui.clearRange()
##	battle_gui.removePrompts()
#	unit.highlightMove(unit.grid.cells)
#	battle_gui.camera.moveTo(unit)

func _on_TextureButton_mouse_entered():
	moveToFront()
	if !mouse_in:
		UI_Sounds.createSound(UI_Sounds.card_focus)
		mouse_in = true
	card_highlight.visible = true
	match state:
		InHand, InHandActive, ReorganizeHand:
			setup = true
			end_rotation = 0
			end_pos = card_pos
			end_pos.y = get_viewport().size.y - ((card_front.texture.get_size().y / 2) * zoom_size)
			state = FocusInHand
#	pass


func _on_TextureButton_mouse_exited():
	moveToBack()
	mouse_in = button.get_global_rect().has_point(get_global_mouse_position())
	card_highlight.visible = false
#	if !mouse_in:
#		moveToBack()
	match state:
		FocusInHand:
			setup = true
			end_rotation = card_rotation
			end_pos = card_pos + (Vector2(0,-active_shift) * int(activated))
			state = ReorganizeHand
#	pass

func returnCardPosition():
	moveToBack()
	state = FocusInHand
	setup = true
	end_rotation = card_rotation
	end_pos = card_pos + (Vector2(0,-active_shift) * int(activated))
	state = ReorganizeHand

func _on_TextureButton_pressed():
	clicked = true


func _on_CardHighlight_mouse_entered():
	mouse_in = button.get_global_rect().has_point(get_global_mouse_position())


func _on_CardHighlight_mouse_exited():
	mouse_in = button.get_global_rect().has_point(get_global_mouse_position())

func _init():
	GameUtils.connect("freeing_orphans", self, "_free_if_orphaned")

func _free_if_orphaned():
	if not is_inside_tree(): # Optional check - don't free if in the scene tree
		queue_free()

func clear() -> void:
	call_deferred("queue_free")
