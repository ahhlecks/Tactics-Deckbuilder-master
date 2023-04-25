extends Control

var CardGUI = preload("res://objects/UI/battle/CardGUI.tscn")
var UnitTabGUI = preload("res://objects/UI/battle/UnitTabGUI.tscn")
var NinePatchPrefab = preload("res://objects/UI/NinePatchRect.tscn")
var effect_text = preload("res://objects/UI/battle/EffectText.tscn")
var card_draw = preload("res://assets/sounds/ui/cards/Card_Draw.wav")

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
onready var prompts = $Prompts
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
var discard_card_pool:Array
var consume_card_pool:Array
var selected_slot
var selected_hex:HexCell
var valid_targets:Array
onready var card_actor = get_node("CardActor")

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
var card_spread
var spread = .08
var card_compression = 1 #.25
var card_number = 0
var oval_angle_vector = Vector2()
var is_act_toggled:bool = false
var unit_wait:bool = false
var turn_draw_points:int

signal drawn_card(card)
signal drawn_cards()
signal removed_card
signal removed_cards
signal selected_target()
signal discarded_cards()
signal consumed_cards()
signal card_name_popup_exit()
#signal unit_cancel_wait
#signal round_ended

func _ready():
# warning-ignore:return_value_discarded
	unit_wait = false
	get_tree().get_root().connect("size_changed", self, "update_position")
	update_position()
	wait_button.hint_tooltip = "Choose a facing direction and\nend this unit's turn."

func _input(event):
	if battle_controller.grid != null and !battle_controller.grid.clear:
		if !battle_controller.grid.editMode:
			if Input.is_action_just_pressed("ui_cancel"):
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
		#		cards.get_child(0).setup = true
		#		cards.get_child(0).card_selected = true
		#		cards.get_child(0).state = 2
		#		cards.get_child(0).previous_state = cards.get_child(0).state

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
		card_oval_radius_x = get_viewport().size.x * 1.35
		card_oval_radius_y = 800
		card_oval_center.x = get_viewport().size.x * .5
		card_oval_center.y = get_viewport().size.y + card_oval_radius_y - 18
		repositionCards(cards.get_child_count()-1)
		for prompts in $Prompts.get_children():
			prompts.update_position()

func addCard(card:Dictionary):
	var new_card = CardGUI.instance()
	new_card.card_info = card
	var cardcount:float = float(cards.get_child_count())
	var extra = max(cardcount+1,5)-5
	card_spread = spread / ((extra * card_compression)+1)
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
	UI_Sounds.createSound(UI_Sounds.card_draw)
	yield(new_card,"drawn_card")
	emit_signal("drawn_card", new_card)
#	draw_pile_label.text = str(int(draw_pile_label.text) - 1)
#	new_card.updateCardInfo(active_unit)
	if turn_draw_points != 0:
		if cards.get_child_count() == turn_draw_points:
			if cards.get_child_count() != new_card.card_number+1:
				yield(cards.get_tree(),"node_added")
			emit_signal("drawn_cards")
	return(new_card)

func addCards(card_array:Array):
	for card in card_array:
		var new_card = CardGUI.instance()
		new_card.card_info = card
		var cardcount:float = float(cards.get_child_count())
		var extra = max(cardcount+1,5)-5
		card_spread = spread / ((extra * card_compression)+1)
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
		UI_Sounds.createSound(UI_Sounds.card_draw)
		yield(self,"drawn_card")
	emit_signal("drawn_cards")

func getCardGUI(card_unique_id:String) -> CardGUI:
	for c in cards.get_children():
		if c.unique_id == card_unique_id:
			return c
	return null

func updateCards(unit = null) -> void:
	if unit != null:
		for card in cards.get_children():
			card.updateCardInfo(unit)
	else:
		for card in cards.get_children():
			card.updateCardInfo(active_unit)

func repositionCards(card_count) -> void:
	var cardcount:float = float(card_count)
	var extra = max(cardcount+1,5)-5
	card_spread = spread / ((extra * card_compression)+1)
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
	var actual_ap_cost:int
	if active_unit == null:
		return false
	for card in cards.get_children():
		if act:
			check = card.card_info.can_attack[card.card_info.card_level]
			actual_ap_cost = card.card_info.action_costs[card.card_info.card_level]
		else:
			check = card.card_info.can_defend[card.card_info.card_level]
#			var additional_ap = 0
#			if card.card_info.has_counter[card.card_info.card_level]:
#				additional_ap = 1
			actual_ap_cost = card.card_info.action_costs[card.card_info.card_level]
		card_actor.load_card(card.card_info)
		card_actor.card_caster = active_unit
#		card_actor.source_cell = active_unit.currentCell
#		card_actor.target_cell = active_unit.currentCell
		if active_unit.current_action_points >= actual_ap_cost and check and card_actor.isValid():
			if active_unit.unit_class == 0:
				if card.card_info.get("card_class") == 0 or card.card_info.get("card_class") == 3 or card.card_info.get("card_class") == 5:
					if activate: card.activate()
					atleast_one = true
			elif active_unit.unit_class == 1:
				if card.card_info.get("card_class") == 1 or card.card_info.get("card_class") == 3 or card.card_info.get("card_class") == 4:
					if activate: card.activate()
					atleast_one = true
			elif active_unit.unit_class == 2:
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

func activateAllCards(activate:bool = true, vis = true) -> void:
	if activate:
		for card in cards.get_children():
			card.activate()
			if !vis:
				card.visible = false
			else:
				card.visible = true
	else:
		for card in cards.get_children():
			card.deactivate()
			if !vis:
				card.visible = false
			else:
				card.visible = true


func removeAllCards() -> void:
	for card in cards.get_children():
		discard_card_pool.append(card)
	removeCards()
	emit_signal("removed_cards")

func showRange(card_info) -> void:
	if selected_card != null and active_unit != null:
		active_unit.highlightRange(card_info)

func clearRange() -> void:
	if active_unit != null:
		active_unit.unit_id.clearValidRangeCells()

func updateUnitGUI(unit) -> void:
#	active_unit = unit
	if unit != null:
		unit_gui.updateGUI(unit)

func updateUnitTabGUI(unit_list) -> void:
	if unit_list != null:
		turn_tabs.current_round_list = unit_list
		turn_tabs.updateTabs()


func _on_BattleController_unit_moved(unit, player, from, to):
	if player.is_human:
		updateUnitGUI(unit)
#		actionPopout(move_panel)


func _on_BattleController_turn_started(unit, player):
	player = player
	unit_wait = false
	active_unit = unit
	unit.isActive = true
	updateUnitGUI(unit)
	camera.current_target = unit
	if unit is Dictionary:
		endCardTurn()
		return
	if !unit.player_owned:
		#run player ai
		actions.visible = false
		player.aiDoBestMove(unit)
		yield(player, "ai_complete")
		endTurn()
		return
	if unit.player_owned:
		#actions.visible = true
		updateCards(unit)
		if !unit.is_ai_controlled:
			actions.visible = false
			yield(unit.unit_owner,"hand_drawn")
			disableMouseHighlight()
			actions.visible = true
			actionPopout()
		else:
			actions.visible = false
			player.aiDoBestMove(unit)
			yield(player, "ai_complete")
			endTurn()
		return

func setupTurnTabs(current_round_list):
	turn_tabs.current_round_list = current_round_list
	turn_tabs.createTabs()

func endTurn():
	actions.visible = false
	actions_anim.play_backwards("popout")
	active_unit.isActive = false
	previous_unit = active_unit
#	active_unit = null
#	active_panel = null
	unit_wait = false
	turn_draw_points = 0
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
	battle_controller.emit_signal("round_ended")

func promptAct(message):
	removePrompts()
	var prompt = NinePatchPrefab.instance()
	$Prompts.add_child(prompt)
	prompt.setup(message)

func removePrompts() -> void:
	for prompts in $Prompts.get_children():
		prompts.clear()
		$Prompts.remove_child(prompts)

func clear() -> void:
	get_tree().get_root().disconnect("size_changed", self, "update_position")
	actions.visible = false
	unit_gui.visible = false
	discard_card_pool.clear()
	for i in cards.get_children():
		i.clear()
		cards.remove_child(i)
	turn_tabs.clear()
	removePrompts()

func playRandomPitchSound(sound) -> void:
	sfx.stream.audio_stream = sound
	sfx.play()

func targetUnit(caster, card, delay_turns, target, results):
	card.target_unit = target.unit
	battle_controller.emit_signal("unit_charging", caster, caster.unit_owner, card, delay_turns, caster.currentCell, target, results)
	if active_unit.player_owned:
		if !active_unit.is_ai_controlled:
			actions.visible = true
	

func targetTile(caster, card, delay_turns, target, results):
	card.target_unit = null
	card.target_cell = target
	battle_controller.emit_signal("unit_charging", caster, caster.unit_owner, card, delay_turns, caster.currentCell, target, results)
	if active_unit.player_owned:
		if !active_unit.is_ai_controlled:
			actions.visible = true

func setActCard(caster, card, target:HexCell,results:Array) -> void:
	var delay_turns:float = round(float(card.delay[card.card_level]) * float(battle_controller.turn_queue.get_child_count()) / 100.0) # turns = card delay x total units / 100
	if delay_turns <= 0:
		battle_controller.emit_signal("unit_acted",caster,caster.unit_owner,card,caster.currentCell,target)
	elif card.card_type == 2 or card.card_type == 3 or card.is_homing[card.card_level]:
		if target.unit != null: # If a unit is standing here and this card is a magic attack or magic spell or homing
			actions.visible = false
			var action_prompt = NinePatchPrefab.instance()
			$Prompts.add_child(action_prompt)
			action_prompt.centered = true
			action_prompt.setup("Target the Unit or Tile?")
			action_prompt.setupOptions("Unit","Tile",self,self,"targetUnit","targetTile",[caster, card, delay_turns, target, results],[caster, card, delay_turns, target, results])
		else:
			targetTile(caster, card, delay_turns,target, results)
	else:
		targetTile(caster, card, delay_turns,target, results)

func acceptReact(isReplacing:bool = false) -> void:
	if isReplacing:
		active_unit.discard_deck.append(active_unit.reaction)
	active_unit.reaction = selected_card.card_info.duplicate(true)
	selected_card.moveToBack()
	active_unit.current_action_points = clamp(active_unit.current_action_points - selected_card.card_info.action_costs[selected_card.card_info.card_level],0,INF)
	for p in card_actor.prerequisites[card_actor.card_level]:
		if p[0] != null and p[2] == true:
			match p[0]:
				"unit_deck_size":
					card_actor.card_caster.unit_owner.moveCards(card_actor.card_caster, p[1], randi() % card_actor.card_caster.active_deck.size(), "active_deck", "discard_deck", true)
				"unit_hand_size":
					card_actor.card_caster.unit_owner.moveCards(card_actor.card_caster, p[1], randi() % card_actor.card_caster.hand_deck.size(), "hand_deck", "discard_deck", true)
				"unit_discard_size":
					pass
				"unit_consumed_size":
					card_actor.card_caster.unit_owner.moveCards(card_actor.card_caster, p[1], randi() % card_actor.card_caster.consumed_deck.size(), "consumed_deck", "discard_deck", true)
				_:
					card_actor.card_caster.set(p[0], card_actor.card_caster.get(p[0]) - p[1])
	selected_card.reaction_ap_add = false
	selected_card.card_info.action_costs[selected_card.card_info.card_level] -= 1
	selected_card.card_ap.text = str(selected_card.card_info.action_costs[selected_card.card_info.card_level])
	player.unitEliminateCards(active_unit, 1, "hand_deck", "", selected_card.unique_id)
	selected_card = null
	removePrompts()
	updateCards(active_unit)
	updateUnitGUI(active_unit)
	updateUnitTabGUI(battle_controller.turn_queue.current_round_list)
	battle_controller.emit_signal("unit_react", active_unit, card_actor.card_caster.unit_owner, active_unit.reaction)
	actionPopout()

func declineReact() -> void:
	if active_unit.player_owned:
		if !active_unit.is_ai_controlled:
			actions.visible = true
	disableMouseHighlight()
	active_unit.clearValidRangeCells()
	selected_card.activated = true
	if active_panel == act_panel:
		activateCards(true, true)
		promptAct("Select a card.")
	if active_panel == react_panel:
		activateCards(false, true)
		promptAct("Select a card.")
	selected_card.card_highlight.visible = false
	selected_card.visible = true
	selected_card.moveToBack()
	if selected_card.reaction_ap_add:
		selected_card.reaction_ap_add = false
		selected_card.card_info.action_costs[selected_card.card_info.card_level] -= 1
		selected_card.card_ap.text = str(selected_card.card_info.action_costs[selected_card.card_info.card_level])
	selected_card.end_pos = selected_card.card_pos + (Vector2(0,-selected_card.active_shift) * int(selected_card.activated))
	selected_card.end_rotation = selected_card.card_rotation
	selected_card.state = selected_card.ReorganizeHand
	yield(selected_card, "organized")
	selected_card = null

func setReactCard() -> void:
	if !active_unit.reaction.empty():
		var action_prompt = NinePatchPrefab.instance()
		$Prompts.add_child(action_prompt)
		action_prompt.centered = true
		action_prompt.setup("Replace " + active_unit.reaction.card_name + " reaction card?")
		action_prompt.setupOptions("Accept","Decline",self,self,"acceptReact","declineReact",[true])
	else:
		acceptReact()

func accept_target() -> void:
	removePrompts()
	if !active_unit.is_ai_controlled:
		selected_card.card_highlight.visible = false
		selected_card.visible = true
		selected_card.end_pos = selected_card.card_pos + (Vector2(0,-selected_card.active_shift) * int(selected_card.activated))
		selected_card.end_rotation = selected_card.card_rotation
		selected_card.state = selected_card.ReorganizeHand
		if valid_targets != null:
			for target in valid_targets:
				if target is HexUnit:
					target.currentCell.unvalidifyAttack()
		if !valid_targets.empty():
			for target in valid_targets:
				if target is HexCell:
					target.unvalidifyAttack()
		active_unit.clearValidRangeCells()
		selected_card.moveToFront()
		actions.visible = false
	var delay_turns = round(float(card_actor.delay[card_actor.card_level]) * float(battle_controller.turn_queue.get_child_count()) / 100.0)
	if active_panel == act_panel:
		setActCard(active_unit, selected_card.card_info,selected_hex,card_actor.results)
	for p in card_actor.prerequisites[card_actor.card_level]:
		if p[0] != null and p[2] == true:
			match p[0]:
				"unit_deck_size":
					card_actor.card_caster.unit_owner.moveCards(card_actor.card_caster, p[1], randi() % card_actor.card_caster.active_deck.size(), "active_deck", "discard_deck", true)
				"unit_hand_size":
					card_actor.card_caster.unit_owner.moveCards(card_actor.card_caster, p[1], randi() % card_actor.card_caster.hand_deck.size(), "hand_deck", "discard_deck", true)
				"unit_discard_size":
					pass
				"unit_consumed_size":
					card_actor.card_caster.unit_owner.moveCards(card_actor.card_caster, p[1], randi() % card_actor.card_caster.consumed_deck.size(), "consumed_deck", "discard_deck", true)
				_:
					card_actor.card_caster.set(p[0], card_actor.card_caster.get(p[0]) - p[1])
	if delay_turns > 0:
		if active_unit.player_owned:
			if !active_unit.is_ai_controlled:
				actions.visible = true
	active_unit.current_action_points = clamp(active_unit.current_action_points - (selected_card.card_info.action_costs[selected_card.card_info.card_level] - int(card_actor.has_combo[card_actor.card_level] and active_unit.has_combo)),0,INF)
	if card_actor.has_combo[card_actor.card_level]:
		active_unit.has_combo = card_actor.has_combo[card_actor.card_level]
	if card_actor.is_consumable[card_actor.card_level]:
		player.unitConsumeCards(active_unit, 1, "hand_deck", "", selected_card.unique_id, "none", null, 0, false)
	elif card_actor.self_eliminating[card_actor.card_level]:
		player.unitEliminateCards(active_unit, 1, "hand_deck", "", selected_card.unique_id, "none", null, 0, true)
	else:
		player.unitDiscardCards(active_unit, 1, "hand_deck", "", selected_card.unique_id, "none", null, 0, false)
	selected_card.moveToBack()
	selected_card = null
	selected_hex = null
	valid_targets.clear()
	updateCards(active_unit)
	updateUnitGUI(active_unit)
	updateUnitTabGUI(battle_controller.turn_queue.current_round_list)
	if delay_turns > 0:
		actionPopout()


func decline_target():
	removePrompts()
	actions.visible = true
	disableMouseHighlight()
	if card_actor != null:
		for cell in battle_controller.grid.cells:
			cell.unvalidifyAttack()
		card_actor.clearData()
	active_unit.clearValidRangeCells()
	selected_card.activated = true
	if active_panel == act_panel:
		activateCards(true, true)
		promptAct("Select a card.")
	if active_panel == react_panel:
		activateCards(false, true)
		promptAct("Select a card.")
	selected_card.card_highlight.visible = false
	selected_card.visible = true
	selected_card.moveToBack()
	selected_card.end_pos = selected_card.card_pos + (Vector2(0,-selected_card.active_shift) * int(selected_card.activated))
	selected_card.end_rotation = selected_card.card_rotation
	selected_card.state = selected_card.ReorganizeHand
	yield(selected_card, "organized")
	selected_card = null
	selected_hex = null
	valid_targets.clear()


func removeCard(card:CardGUI) -> void:
	UI_Sounds.createSound(UI_Sounds.card_draw)
	var card_num = card.card_number
	card.setup = true
	card.end_pos = $DiscardPile.global_position + Vector2(40,0)
	card.end_rotation = 30
	card.state = card.MoveHandToDiscard
#	yield(card, "discard_card")
	yield(card,"tree_exited")
	repositionCards(cards.get_child_count())
	update_position()
	emit_signal("removed_card")


func removeCards():
	var original_num_cards = cards.get_child_count()
	var num_cards:int = discard_card_pool.size()
	for card in discard_card_pool:
		UI_Sounds.createSound(UI_Sounds.card_draw)
		card.setup = true
		card.end_pos = $DiscardPile.global_position + Vector2(40,0)
		card.end_rotation = 30
		card.state = card.MoveHandToDiscard
		yield(card, "discard_card")
		repositionCards(num_cards)
		num_cards -= 1
	discard_card_pool.clear()
	update_position()
	if cards.get_child_count() >= original_num_cards:
		yield(get_tree(),"node_removed")
	emit_signal("discarded_cards")

func consumeCards():
	var original_num_cards = cards.get_child_count()
	var num_cards:int = consume_card_pool.size()
	for card in consume_card_pool:
		UI_Sounds.createSound(UI_Sounds.card_draw)
		card.setup = true
		card.end_pos = $DiscardPile.global_position + Vector2(40,0)
		card.end_rotation = 30
		card.state = card.MoveHandToDiscard
		yield(card, "discard_card")
		repositionCards(num_cards)
		num_cards -= 1
	consume_card_pool.clear()
	update_position()
	if cards.get_child_count() >= original_num_cards:
		yield(get_tree(),"node_removed")
	emit_signal("consumed_cards")


func _on_MoveButton_toggled(button_pressed):
	if button_pressed:
		enableMouseHighlight()
		actionPopin(move_panel)
		
	else:
		actionPopout(move_panel)
		disableMouseHighlight()


func _on_ActButton_toggled(button_pressed):
	if button_pressed:
		actionPopin(act_panel)
	else:
		actionPopout(act_panel)
		disableMouseHighlight()


func _on_ReactButton_toggled(button_pressed):
	if button_pressed:
		actionPopin(react_panel)
	else:
		actionPopout(react_panel)
		disableMouseHighlight()


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
		move_button.disabled = true
		act_button.disabled = true
		react_button.disabled = true
		actions_anim.play_backwards("popout")
		yield(actions_anim,"animation_finished")
		if active_unit != null:
			move_button.disabled = active_unit.current_movement_points <= 0
			act_button.disabled = false #!activateCards(true, false)
			react_button.disabled = false #!activateCards(false, false)
		yield(get_tree(),"idle_frame")
		if move_button.disabled == true and act_button.disabled == true and react_button.disabled == true:
			unit_wait = true

func actionPopout(panel:Control = null) -> void:
	if !active_unit.is_ai_controlled:
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
			wait_panel.get_node("Label").text = "End Turn"
			active_unit.hideDirections()
			wait_button.hint_tooltip = "Choose a facing direction and\nend this unit's turn."
		if panel == react_panel or panel == null:
			react_panel.get_node("Label").text = "React"
			if selected_card != null:
				yield(decline_target(),"completed")
			activateAllCards(false)
			react_button.hint_tooltip = "Play a card as a reaction."
		if panel == act_panel or panel == null:
			act_panel.get_node("Label").text = "Act"
			if selected_card != null:
				yield(decline_target(),"completed")
			activateAllCards(false)
			act_button.hint_tooltip = "Play a card as an action."
		if panel == move_panel or panel == null:
			move_panel.get_node("Label").text = "Move"
			move_button.hint_tooltip = "Move unit on the field."
		camera.current_target = active_unit
		move_button.disabled = true
		act_button.disabled = true
		react_button.disabled = true
		actions_anim.play("popout")
		yield(actions_anim,"animation_finished")
		if active_unit != null:
			move_button.disabled = active_unit.current_movement_points <= 0
			act_button.disabled = !activateCards(true, false)
			react_button.disabled = !activateCards(false, false)
			active_unit.clearValidRangeCells()
			active_unit.clearValidMoveCells()
		removePrompts()
		yield(get_tree(),"idle_frame")
		if move_button.disabled == true and act_button.disabled == true and react_button.disabled == true:
			unit_wait = true

func uiBack():
	if active_panel != null:
		active_panel.get_child(1).pressed = false
		actionPopout(active_panel)
		enableMouseHighlight()
	else:
		actions.visible = !actions.visible
		if actions.visible:
			disableMouseHighlight()
		else:
			enableMouseHighlight()
		camera.toggleFocus()


func unitWait():
	unit_wait = true
#	actions.visible = false
	actions_anim.play_backwards("popout")
	promptAct("Choose a direction to face.")
	active_unit.showDirections()


func _on_BattleController_unit_selected(unit, player):
	pass
#	actionPopout()
#	uiBack()


func _on_BattleController_unit_turned(unit, player, old_facing):
	removePrompts()
	actions.visible = false
	acceptFacing()
#	var turn_prompt = NinePatchPrefab.instance()
#	turn_prompt.centered = true
#	$Prompts.add_child(turn_prompt)
#	turn_prompt.setup("Face Here?")
#	turn_prompt.setupOptions("Accept","Decline",self,self,"acceptFacing","declineFacing",[],[old_facing])

func acceptFacing():
	active_unit.hideDirections()
	actionPopout(wait_panel)
	if unit_wait:
		wait_button.pressed = false
		yield(get_tree().create_timer(.1), "timeout")
		yield(get_tree(),"idle_frame")
		endTurn()
	else:
		uiBack()
		if active_unit.player_owned:
			if !active_unit.is_ai_controlled:
				actions.visible = true
		camera.current_target = active_unit

func declineFacing(old_facing):
	unit_wait = false
	if active_unit.player_owned:
		if !active_unit.is_ai_controlled:
			actions.visible = true
	active_unit.loadFacing(old_facing)
	wait_button.pressed = true
	actionPopin(wait_panel)

func addEffectText(message:String, target:Spatial) -> void:
	var new_effect_text = effect_text.instance()
	effect_texts.add_child(new_effect_text)
	new_effect_text.addText(message, target)
#	var num_texts = effect_texts.get_child_count()
#	for texts in effect_texts.get_children():
#		texts.animation.playback_speed = max(1.0,float(num_texts) / 3)

func playEffectTexts() -> void:
	effect_texts.playText()


func _on_BattleGUI_drawn_card(card):
	repositionCards(cards.get_child_count()-1)

func disableMouseHighlight() -> void:
	battle_controller.grid.disableHexHighlight = true
	if battle_controller.grid.lastHighlighted != null:
		battle_controller.grid.lastHighlighted.visible = false

func enableMouseHighlight() -> void:
	battle_controller.grid.disableHexHighlight = false
	if battle_controller.grid.lastHighlighted != null:
		battle_controller.grid.lastHighlighted.visible = true


func actionPrompt(selectedHex) -> void:
	selected_card.visible = true
	card_actor.load_card(selected_card.card_info)
	card_actor.card_caster = active_unit
	card_actor.source_cell = active_unit.currentCell
	card_actor.target_cell = selectedHex
	card_actor.execute(false)
	yield(get_tree().create_timer(0.1),"timeout")
	removePrompts()
	var action_prompt = NinePatchPrefab.instance()
	$Prompts.add_child(action_prompt)
	action_prompt.setup("Execute " + card_actor.card_name + " " + BattleDictionary.toRoman(card_actor.card_level + 1) + "?")
	if card_actor.results.size() > 0:
		action_prompt.addUnitTabMini(card_actor.results)
	actions.visible = false
	selected_hex = selectedHex
	valid_targets = card_actor.valid_targets
	action_prompt.setupOptions("Accept","Decline",self,self,"accept_target","decline_target")
#						accept:bool, decline:bool, accept_signal_node:Node, decline_signal_node:Node, accept_signal, decline_signal, accept_params = [], decline_params = [])

func cardNamePopup(card_name:String, time:float = 1) -> void:
	removePrompts()
	var action_prompt = NinePatchPrefab.instance()
	action_prompt.close_time = time
	$Prompts.add_child(action_prompt)
	action_prompt.setup(card_name)
	yield(action_prompt,"tree_exited")
	emit_signal("card_name_popup_exit")

#func _init():
#	GameUtils.connect("freeing_orphans", self, "_free_if_orphaned")
#
#func _free_if_orphaned():
#	if not is_inside_tree(): # Optional check - don't free if in the scene tree
#		queue_free()
