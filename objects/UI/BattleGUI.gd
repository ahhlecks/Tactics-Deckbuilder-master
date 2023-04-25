extends Control

var CardGUI = preload("res://objects/UI/battle/CardGUI.tscn")
var UnitTabGUI = preload("res://objects/UI/battle/UnitTabGUI.tscn")
var NinePatchPrefab = preload("res://objects/UI/NinePatchRect.tscn")
var effect_text = preload("res://objects/UI/battle/EffectText.tscn")
var card_draw = preload("res://assets/sounds/ui/cards/Card_Draw.wav")
var deck_shuffle = preload("res://assets/sounds/ui/cards/Deck_Shuffle.wav")

onready var end_turn_button = $EndTurn
onready var cards = $Cards
onready var turn_tabs = $TurnTabs
onready var unit_gui = $UnitGUI
onready var actions = $Actions
onready var actions_anim = $Actions/ActionsAnimation
onready var move_button = $Actions/Move/MoveButton
onready var act_button = $Actions/Act/ActButton
onready var react_button = $Actions/React/ReactButton
onready var wait_button = $Actions/Wait/WaitButton
onready var move_panel = $Actions/Move
onready var act_panel = $Actions/Act
onready var react_panel = $Actions/React
onready var wait_panel = $Actions/Wait
onready var effect_texts = $EffectTexts
var active_panel:Control

onready var sfx = $SFX
onready var discard_pile_label = $DiscardPile/Label
onready var draw_pile_label = $DrawPile/Label
onready var camera = $'../../CameraRig'
onready var world_environment:WorldEnvironment = $'../../WorldEnvironment'
onready var battle_controller:Node = $'..'
var player

var active_unit:HexUnit
var previous_unit:HexUnit
var selected_card:CardGUI
var selected_slot

var top_left:Vector2 = Vector2(0,0)
var top_right:Vector2
var bottom_left:Vector2
var bottom_right:Vector2
var bottom:Vector2
var center:Vector2
var card_oval_center:Vector2
var card_oval_radius_x
var card_oval_radius_y
var angle
var card_spread = .16
var card_number = 0
var oval_angle_vector = Vector2()
var is_act_toggled:bool = false

signal drawn_card(card)
signal removed_cards
signal unit_wait
signal unit_cancel_wait
signal round_ended

func _ready():
# warning-ignore:return_value_discarded
	get_tree().get_root().connect("size_changed", self, "update_position")
	update_position()
	wait_button.hint_tooltip = "Choose a facing direction and\nend this unit's turn."

func _input(event):
	if(Input.is_action_just_pressed("ui_cancel")):
		uiBack()
	if active_unit != null and actions.visible:
		if(Input.is_action_just_pressed("ui_act")):
			if !act_button.disabled and act_panel.visible:
				act_button.pressed = !act_button.pressed
				_on_ActButton_toggled(act_button.pressed)
		if(Input.is_action_just_pressed("ui_move")):
			if !move_button.disabled and move_panel.visible:
				move_button.pressed = !move_button.pressed
				_on_MoveButton_toggled(move_button.pressed)
		if(Input.is_action_just_pressed("ui_react")):
			if !react_button.disabled and react_panel.visible:
				react_button.pressed = !react_button.pressed
				_on_ReactButton_toggled(react_button.pressed)
		if(Input.is_action_just_pressed("ui_wait")):
			if !wait_button.disabled and wait_panel.visible:
				wait_button.pressed = !wait_button.pressed
				_on_WaitButton_toggled(wait_button.pressed)

func update_position() -> void:
	if get_viewport() != null:
		top_right = Vector2(get_viewport().size.x,0)
		bottom_left = Vector2(0,get_viewport().size.y)
		bottom_right = Vector2(get_viewport().size.x,get_viewport().size.y)
		bottom = Vector2(get_viewport().size.x/2,get_viewport().size.y)
		center = Vector2(get_viewport().size.x/2,get_viewport().size.y/2)
		$DiscardPile.global_position = Vector2(bottom_right.x - $DiscardPile.texture.get_size().x - 20, bottom_right.y - $DiscardPile.texture.get_size().y - 20)
		$DrawPile.global_position = Vector2(bottom_left.x + $DrawPile.texture.get_size().x + 20, bottom_left.y - $DrawPile.texture.get_size().y - 20)
		actions.global_position = center
		unit_gui.rect_global_position = bottom_left - Vector2(0, unit_gui.get_rect().size.y)
		turn_tabs.rect_size.x = 256
		turn_tabs.rect_size.y = get_viewport().size.y - unit_gui.rect_size.y
		turn_tabs.updatePositions()
		effect_texts.rect_size = get_viewport().size
		card_oval_center.x = get_viewport().size.x * .5
		card_oval_center.y = get_viewport().size.y + 120
		card_oval_radius_x = get_viewport().size.x * .8
		card_oval_radius_y = 80
		card_spread = 205 / get_viewport().size.x 
		repositionCards(cards.get_child_count()-1)
		for prompts in $Prompts.get_children():
			prompts.update_position()

func addCard(card:Dictionary):
	var new_card = CardGUI.instance()
	new_card.card_info = card
	var cardcount:float = float(cards.get_child_count())
	angle = PI/2 + card_spread * ((cardcount / 2.0) - cardcount)
	oval_angle_vector = Vector2(card_oval_radius_x * cos(angle), - card_oval_radius_y * sin(angle))
	new_card.rect_position = $DrawPile.global_position + Vector2(40,0)
	new_card.start_pos = $DrawPile.global_position + Vector2(40,0)
	new_card.end_pos = card_oval_center + oval_angle_vector
	new_card.card_pos = new_card.end_pos
	new_card.middle_pos = bottom
	new_card.rect_rotation = -30
	new_card.start_rotation = -30
	new_card.end_rotation = (90 - rad2deg(angle)) * .4
	new_card.card_rotation = new_card.end_rotation
	new_card.state = new_card.MoveDrawnCardToHand
	new_card.card_number = int(cardcount)
	repositionCards(cards.get_child_count())
	cards.add_child(new_card)
	draw_pile_label.text = str(int(draw_pile_label.text) - 1)
	playRandomPitchSound(card_draw)
	return(new_card)

func updateCards() -> void:
	for card in cards.get_children():
		card._ready()

func repositionCards(card_count) -> void:
	var cardcount:float = float(card_count)
	card_number = 0
	for card in cards.get_children():
		angle = PI/2 + (card_spread * ((cardcount / 2.0) - card_number))
		oval_angle_vector = Vector2(card_oval_radius_x * cos(angle), - card_oval_radius_y * sin(angle))
		#card.start_pos = card.rect_position
		card.end_pos = card_oval_center + oval_angle_vector
		card.card_pos = card.end_pos
		card.start_rotation = card.rect_rotation
		card.end_rotation = (90 - rad2deg(angle)) * .4
		card.card_rotation = card.end_rotation
		card_number += 1
		
		if card.state == card.InHand or card.InHandActive or card.InHand:
			card.setup = true
			card.state = card.ReorganizeHand
		elif card.state == card.MoveDrawnCardToHand:
			card.start_pos = card.end_pos - ((card.end_pos - card.rect_position) / (1-card.time))

func activateCard(card) -> void:
	card.activate()

func activateCards(act:bool, activate:bool) -> bool:
	var atleast_one:bool = false
	var check:bool
	if active_unit == null:
		return false
	for card in cards.get_children():
		if act:
			check = card.card_info.can_attack[card.card_info.card_level]
		else:
			check = card.card_info.can_defend[card.card_info.card_level]
		if active_unit.current_action_points >= card.card_info.action_costs[card.card_info.card_level] and check:
			if active_unit.unit_class == 0:
				if card.card_info.get("card_class") == 0 or card.card_info.get("card_class") == 3 or card.card_info.get("card_class") == 5:
					if activate: card.activate()
					atleast_one = true
			if active_unit.unit_class == 1:
				if card.card_info.get("card_class") == 1 or card.card_info.get("card_class") == 3 or card.card_info.get("card_class") == 4:
					if activate: card.activate()
					atleast_one = true
			if active_unit.unit_class == 2:
				if card.card_info.get("card_class") == 2 or card.card_info.get("card_class") == 4 or card.card_info.get("card_class") == 5:
					if activate: card.activate()
					atleast_one = true
			if card.card_info.get("card_class") == 6:
				if activate: card.activate()
				atleast_one = true
	return atleast_one

func deactivateCards() -> bool:
	if active_unit == null:
		return false
	for card in cards.get_children():
		if active_unit.unit_class == 0:
			if card.card_info.get("card_class") == 0 or card.card_info.get("card_class") == 3 or card.card_info.get("card_class") == 5:
				card.deactivate()
		if active_unit.unit_class == 1:
			if card.card_info.get("card_class") == 1 or card.card_info.get("card_class") == 3 or card.card_info.get("card_class") == 4:
				card.deactivate()
		if active_unit.unit_class == 2:
			if card.card_info.get("card_class") == 2 or card.card_info.get("card_class") == 4 or card.card_info.get("card_class") == 5:
				card.deactivate()
		if card.card_info.get("card_class") == 6:
			card.deactivate()
	return true

func activateAllCards(activate:bool) -> void:
	if activate:
		for card in cards.get_children():
			card.activate()
	else:
		for card in cards.get_children():
			card.deactivate()


func removeAllCards() -> void:
	for card in cards.get_children():
		removeCard(card)
		playRandomPitchSound(card_draw)
		yield(card,"discard_card")
	emit_signal("removed_cards")

func showRange(card_info) -> void:
	if selected_card != null and active_unit != null:
		active_unit.highlightRange(card_info)

func clearRange() -> void:
	if active_unit != null:
		active_unit.unit_id.clearValidRangeCells()

func updateUnitGUI(unit) -> void:
	active_unit = unit
	unit_gui.updateGUI(unit)

func updateUnitTabGUI(unit_list) -> void:
	turn_tabs.current_round_list = unit_list
	turn_tabs.updateTabs()


func _on_BattleController_unit_moved(unit, player, from, to):
	if player.is_human:
		updateUnitGUI(unit)
#		actionPopout(move_panel)


func _on_BattleController_turn_started(unit, player):
	active_unit = unit
	unit.isActive = true
	updateUnitGUI(unit)
	camera.current_target = unit
	if !unit.is_ai_controlled:
		actions.visible = true
		actionPopout()
	elif unit is Dictionary:
		endCardTurn()
	else:
#		yield(get_tree().create_timer(.1),"timeout")
		endTurn()

func setupTurnTabs(current_round_list, next_round_list):
	turn_tabs.current_round_list = current_round_list
	turn_tabs.next_round_list = next_round_list
	turn_tabs.createTabs()

func endTurn():
	actions.visible = false
	actionPopin()
	active_unit.isActive = false
	previous_unit = active_unit
	active_unit = null
	active_panel = null
	turn_tabs.shiftAllTabsDown()
	battle_controller.emit_signal("turn_ended",battle_controller.turn_queue.active_tab,battle_controller.turn_queue.active_tab.unit_owner)

func endCardTurn():
	actions.visible = false
	actionPopin()
	active_unit.isActive = false
	active_unit = null
	active_panel = null
	battle_controller.emit_signal("turn_ended",battle_controller.turn_queue.active_tab,battle_controller.turn_queue.active_tab.unit_owner)

func endRound():
	actions.visible = false
	actions_anim.play_backwards("popout")
	active_unit = null
	active_panel = null
	if cards.get_child_count() > 0:
		removeAllCards()
		yield(self,"removed_cards")
	battle_controller.emit_signal("round_ended")

func promptAct(message):
	for prompts in $Prompts.get_children():
		prompts.call_deferred("queue_free")
	var prompt = NinePatchPrefab.instance()
	$Prompts.add_child(prompt)
	prompt.setup(message)
	prompt.pulsing_time = 3
	

func removePrompts() -> void:
	for prompts in $Prompts.get_children():
		prompts.call_deferred("queue_free")

func clear() -> void:
	for i in cards.get_children():
		i.call_deferred("queue_free")
	for i in turn_tabs.get_children():
		i.call_deferred("queue_free")

func playRandomPitchSound(sound) -> void:
	sfx.stream.audio_stream = sound
	sfx.play()


func accept_target(hex) -> void:
	active_unit.current_action_points -= selected_card.card_info.action_costs[selected_card.card_info.card_level]
	updateUnitGUI(active_unit)
	active_unit.clearValidRangeCells()
	if active_panel == act_panel:
		active_unit.setActCard(selected_card.card_info,hex)
		removeCard(selected_card)
		selected_card = null
		removePrompts()
	actionPopout()


func decline_target(card_actor):
	if card_actor != null:
		card_actor.clearData()
	active_unit.clearValidRangeCells()
	selected_card.activated = true
	if active_panel == act_panel:
		activateCards(true, true)
		promptAct("Select a card.")
	if active_panel == react_panel:
		activateCards(false, true)
		promptAct("Select a card.")
	playRandomPitchSound(card_draw)
	selected_card.card_highlight.visible = false
	selected_card.visible = true
	selected_card.end_pos = selected_card.card_pos + (Vector2(0,-selected_card.active_shift) * int(selected_card.activated))
	selected_card.end_rotation = selected_card.card_rotation
	selected_card.state = selected_card.ReorganizeHand
	yield(selected_card, "organized")
	selected_card = null


func removeCard(card:CardGUI) -> void:
	var card_num = card.card_number
	card.setup = true
	card.end_pos = $DiscardPile.global_position + Vector2(40,0)
	card.end_rotation = 30
	card.state = card.MoveHandToDiscard
	for i in cards.get_children():
		if i.card_number > card_num:
			i.card_number -= 1
	yield(card,"discard_card")
	repositionCards(cards.get_child_count())
	update_position()


func _on_MoveButton_toggled(button_pressed):
	if button_pressed:
		actionPopin(move_panel)
	else:
		actionPopout(move_panel)


func _on_ActButton_toggled(button_pressed):
	if button_pressed:
		actionPopin(act_panel)
	else:
		actionPopout(act_panel)


func _on_ReactButton_toggled(button_pressed):
	if button_pressed:
		actionPopin(react_panel)
	else:
		actionPopout(react_panel)


func _on_WaitButton_toggled(button_pressed):
	if button_pressed:
		actionPopin(wait_panel)
	else:
		actionPopout(wait_panel)


func actionPopin(panel:Control = null) -> void:
	if active_unit is HexUnit:
		active_panel = panel
		for panels in actions.get_children():
			if panels != panel and panels is Control:
				panels.visible = false
		if panel != null:
			panel.raise()
		if panel == wait_panel:
			wait_panel.get_node("Label").text = "Cancel"
#			active_panel = wait_panel
			unitWait()
			wait_button.hint_tooltip = ""
		if panel == react_panel:
			react_panel.get_node("Label").text = "Cancel"
			if activateCards(false, true):
				promptAct("Select a card.")
			react_button.hint_tooltip = ""
		if panel == act_panel:
			act_panel.get_node("Label").text = "Cancel"
			if activateCards(true, true):
				promptAct("Select a card.")
			act_button.hint_tooltip = ""
		if panel == move_panel:
			move_panel.get_node("Label").text = "Cancel"
			camera.toggleFocus()
			active_unit.highlightMove()
			promptAct("Select a tile to move to.")
			move_button.hint_tooltip = ""
		move_button.disabled = active_unit.current_movement_points <= 0
		act_button.disabled = !activateCards(true, false)
		react_button.disabled = !activateCards(false, false)
		actions_anim.play_backwards("popout")
		if move_button.disabled == true and act_button.disabled == true and react_button.disabled == true:
			unitWait()

func actionPopout(panel:Control = null) -> void:
	if !active_unit.is_ai_controlled:
#		if panel != wait_panel:
#			active_panel = null
		active_panel = null
		act_panel.visible = true
		react_panel.visible = true
		move_panel.visible = true
		wait_panel.visible = true
		act_button.pressed = false
		react_button.pressed = false
		move_button.pressed = false
		wait_button.pressed = false
		if panel == wait_panel or panel == null:
			wait_panel.get_node("Label").text = "Wait"
			active_unit.hideDirections()
			wait_button.hint_tooltip = "Choose a facing direction and\nend this unit's turn."
		if panel == react_panel or panel == null:
			react_panel.get_node("Label").text = "React"
			if selected_card != null:
				yield(decline_target(null),"completed")
			activateAllCards(false)
			react_button.hint_tooltip = "Play a card as a reaction."
		if panel == act_panel or panel == null:
			act_panel.get_node("Label").text = "Act"
			if selected_card != null:
				yield(decline_target(null),"completed")
			activateAllCards(false)
			act_button.hint_tooltip = "Play a card as an action."
		if panel == move_panel or panel == null:
			move_panel.get_node("Label").text = "Move"
			move_button.hint_tooltip = "Move unit on the field."
		camera.current_target = active_unit
		move_button.disabled = active_unit.current_movement_points <= 0
		act_button.disabled = !activateCards(true, false)
		react_button.disabled = !activateCards(false, false)
		actions_anim.play("popout")
		active_unit.clearValidRangeCells()
		active_unit.clearValidMoveCells()
		removePrompts()
		if move_button.disabled == true and act_button.disabled == true and react_button.disabled == true:
			unitWait()

func uiBack():
	if active_panel != null:
		active_panel.get_child(1).pressed = false
		actionPopout(active_panel)
	else:
		actions.visible = !actions.visible
		camera.toggleFocus()


func unitWait():
	promptAct("Choose a direction to face.")
	active_unit.showDirections()


func _on_BattleController_unit_selected(unit, player):
	uiBack()


func _on_BattleController_unit_turned(unit, player, old_facing):
	removePrompts()
	actions.visible = false
	var turn_prompt = NinePatchPrefab.instance()
	turn_prompt.centered = true
	$Prompts.add_child(turn_prompt)
	turn_prompt.setup("Face Here?")
	turn_prompt.setupOptions("Accept","Decline",self,self,"acceptFacing","declineFacing",[],[old_facing])

func acceptFacing():
	active_unit.hideDirections()
	if active_panel == wait_panel:
		actionPopout(wait_panel)
		wait_button.pressed = false
		endTurn()
	else:
		uiBack()
		actions.visible = true
		camera.current_target = active_unit

func declineFacing(old_facing):
	actions.visible = true
	active_unit.loadFacing(old_facing)
	wait_button.pressed = true
	actionPopin(wait_panel)

func createEffectText(message:String, target:Spatial) -> void:
	var new_effect_text = effect_text.instance()
	effect_texts.add_child(new_effect_text)
	new_effect_text.showText(message,target)
