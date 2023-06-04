extends Node

signal unit_moved(unit, player, from, to)
signal unit_acted(unit, player, card, from, to)
signal unit_charging(unit, player, card, from, to)
signal unit_react(unit, player, card)
signal unit_acted_on_unit(unit, target_unit, player, card, from, to)
signal unit_turned(unit, player, old_facing)
signal unit_selected(unit, player)
signal unit_deselected(unit, player)
signal unit_targeted(unit, target_unit)
signal unit_died(unit, player, location)
signal match_started()
signal turn_started(unit, player)
signal turn_ended(unit, player)
signal turn_ready()
signal round_started()
signal round_ended()
signal match_ended(condition)

#signal unit_damaged(attacker, defender, amount)
#signal unit_healed(attacker, defender, amount)


var PlayerPrefab = preload("res://objects/scenes/Player.tscn")
var player_script = load("res://objects/scenes/Player.gd")
var ai_player_script = load("res://objects/scenes/AI_Player.gd")
var UnitPrefab = preload("res://objects/HexUnit.tscn")
onready var turn_queue = $TurnQueue
onready var battle_gui = $BattleGUI
onready var camera = $"../CameraRig"
onready var sfx = $"../../SFX"

var grid:Spatial
var unit_list:Array = []
var self_player
var enemy_player
var battle_history:Array = [] # [round, turn, unit, player, action, from_cell, to_cell]
var stack:Array = []
var signals_to_wait_for:int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func startMatch() -> void:
	# beginning animations before match
	battle_gui._ready()
	battle_gui.visible = true
	battle_gui.battle_controller = self
	yield(get_tree().create_timer(.1), "timeout")
	yield(get_tree(), "idle_frame")
	emit_signal("match_started")

func setUnitList(unit_list:Array, player_party:int) -> void:
	battle_gui.unit_gui.visible = true
	self.unit_list = unit_list
	self_player = PlayerPrefab.instance()
	self_player.set_script(player_script)
	add_child(self_player)
	self_player.battle_gui = battle_gui
	self_player.battle_controller = self
	battle_gui.player = self_player
	enemy_player = PlayerPrefab.instance()
	enemy_player.set_script(ai_player_script)
	add_child(enemy_player)
	enemy_player.battle_gui = battle_gui
	for unit in unit_list.size():
		unit_list[unit].grid = grid
		unit_list[unit].battle_controller = self
		unit_list[unit].setTeamColor()
		if unit_list[unit].team == player_party:
			unit_list[unit].unit_owner = self_player
			self_player.units.append(unit_list[unit])
		else:
			unit_list[unit].unit_owner = enemy_player
			enemy_player.units.append(unit_list[unit])
		
	turn_queue.units = unit_list
	yield(get_tree(), "idle_frame")
	startMatch()


#		var new_unit:HexUnit = UnitPrefab.instance()
#		new_unit.grid = grid
#		new_unit.battle_controller = self
#		new_unit.basicLoadData(unit_list[unit].basicSave())
#		new_unit.setTeamColor()
#		if new_unit.team == player_party:
#			new_unit.unit_owner = self_player
#			self_player.units.append(new_unit)
#		else:
#			new_unit.unit_owner = enemy_player
#			enemy_player.units.append(new_unit)

func clearAll() -> void:
	for i in turn_queue.get_children():
		i.clear()
		remove_child(i)
		i.call_deferred("queue_free")
	battle_gui.clear()
	battle_history.clear()
	if is_instance_valid(self_player):
		self_player.call_deferred("queue_free")
		remove_child(self_player)
	if is_instance_valid(enemy_player):
		enemy_player.call_deferred("queue_free")
		remove_child(enemy_player)

func _on_BattleController_turn_started(unit, player):
	battle_history.append([turn_queue.round_counter, turn_queue.turn_counter, unit, player, "Start Turn"])
	print(battle_history.back())
	if battle_gui.effect_texts.hasText():
		yield(self,"turn_ready")
	unit.emit_signal("turn_started", turn_queue.round_counter, turn_queue.turn_counter)
	unit.setupTurn()
	if unit.player_owned:
		if !unit.is_ai_controlled:
			battle_gui.actions.visible = true
	if turn_queue.active_tab is HexUnit:
		battle_gui.active_unit = turn_queue.active_tab
		battle_gui.turn_draw_points = turn_queue.active_tab.current_draw_points
		battle_gui.updateUnitGUI(battle_gui.active_unit)
	else:
		battle_gui.updateUnitGUI(battle_gui.previous_unit)
	battle_gui.updateUnitTabGUI(turn_queue.current_round_list)
	if turn_queue.active_tab.current_draw_points > 0:
		player.moveCards(unit,unit.current_draw_points,0,"active_deck","hand_deck")


func _on_BattleController_turn_ended(unit, player):
	battle_history.append([turn_queue.round_counter, turn_queue.turn_counter, unit, player, "End Turn"])
	print(battle_history.back())
	if unit.hand_deck.size() > 0:
		player.moveCards(unit,unit.hand_deck.size(),0,"hand_deck","discard_deck")
		if player.is_human:
			yield(battle_gui,"discarded_cards")
	turn_queue.endTurn()

func _on_BattleController_unit_acted(unit, player, card, from, to): #self,unit_owner,card,currentCell,target
	battle_history.append([turn_queue.round_counter, turn_queue.turn_counter, unit, player, card.card_name, from, to]) # [turn, player, unit, card, from_cell, to_cell]
	print(battle_history.back())
	battle_gui.actions.visible = false
	battle_gui.disableMouseHighlight()
	camera.current_target = unit
	var card_actor:Card = Card.new()
	card_actor.load_card(card)
	card_actor.card_caster = unit
	card_actor.source_cell = from
	card_actor.target_cell = to
	card_actor.execute(false)
	stack.push_front([unit,player,card_actor.export_vars(),from, to])
	
	var targets = card_actor.valid_targets
	if targets != null:
		for target in targets:
			target.emit_signal("targeted", card_actor.export_vars(), unit)
			if !target.reaction.empty() and target.current_health > 0:
				if target.reaction.has_reflex[target.reaction.card_level]:
					target._on_HexUnit_reflex_targeted(unit,player,card_actor.export_vars(),from, to)
				else:
					target._on_HexUnit_targeted(unit,player,card_actor.export_vars(),from, to)
			target.currentCell.unvalidifyAttack()
	var empty_targets = card_actor.empty_targets
	for target in empty_targets:
		target.unvalidifyAttack()
	
	while stack.size() > 0:
		var card_vars = stack.front()[2]
		card_actor.load_card(card_vars)
		card_actor.card_caster = stack.front()[0]
		card_actor.source_cell = stack.front()[3]
		card_actor.target_cell = stack.front()[4]
		if card_actor.card_caster.current_health <= 0:
			stack.pop_front()
			continue
		if card_actor.card_caster.needToTurn(stack.front()[4]):
			card_actor.card_caster.turnTo(stack.front()[4])
			yield(card_actor.card_caster,"turned")
		
#		DO ANIMATION
		if !card_actor.bypass_popup:
			battle_gui.cardNamePopup(card_vars.card_name + " " + BattleDictionary.toRoman(card_vars.card_level + 1))
			yield(battle_gui,"card_name_popup_exit")
		card_actor.execute(true)
		yield(get_tree(), "idle_frame")
		var anim_reacting:bool = false
		if typeof(card_actor.card_animation[card_actor.card_level]) == TYPE_ARRAY:
			if card_actor.card_animation[card_actor.card_level][0] != 0:
				anim_reacting = true
				card_actor.card_caster.animate(card_actor.card_animation[card_actor.card_level],
				card_actor.card_animation_left_weapon[card_actor.card_level],
				card_actor.card_animation_right_weapon[card_actor.card_level],
				card_actor.card_animation_projectile[card_actor.card_level])
		var card_targets = card_actor.valid_targets
		
		
		if card_targets != null:
			for target_unit in card_targets:
				if anim_reacting and target_unit != card_actor.card_caster and target_unit.reaction_animation != 0:
					if not card_actor.card_caster.get_node("Character_Mesh").is_connected("trigger_animation_react",target_unit,"animate_react"):
						card_actor.card_caster.get_node("Character_Mesh").connect("trigger_animation_react",target_unit,"animate_react")
						signals_to_wait_for += 1
		
		while signals_to_wait_for > 0:
			yield(get_tree(), "idle_frame")
		
		if card_targets != null:
			for target_unit in card_targets:
				card_actor.card_caster.get_node("Character_Mesh").disconnect("trigger_animation_react",target_unit,"animate_react")
		
		stack.pop_front()
		#end of stack loop
	
	if battle_gui.effect_texts.hasText():
		battle_gui.playEffectTexts()
		yield(battle_gui.effect_texts,"completed")
		
	card_actor.free()
	if turn_queue.active_tab is HexUnit:
		battle_gui.updateUnitGUI(battle_gui.active_unit)
	else:
		battle_gui.updateUnitGUI(battle_gui.previous_unit)
	battle_gui.updateUnitTabGUI(turn_queue.current_round_list)
	yield(get_tree(), "idle_frame")
	if turn_queue.checkWinConditions() == "":
		if battle_gui.active_unit.player_owned:
			if !battle_gui.active_unit.is_ai_controlled:
				battle_gui.actions.visible = true
		if player.is_human and !(turn_queue.active_tab is Dictionary):
			battle_gui.actionPopout()
		if turn_queue.active_tab is Dictionary:
			turn_queue.endTurn()
		else:
			if player.is_human:
				battle_gui.active_unit.select()
	emit_signal("turn_ready")

func _on_BattleController_unit_react(unit, player, card):
	battle_history.append([turn_queue.round_counter, turn_queue.turn_counter, unit, player, card.card_name + " react setup"])
	print(battle_history.back())

func _on_BattleController_unit_charging(unit, player, card, delay, from, to, results = []):
	battle_history.append([turn_queue.round_counter, turn_queue.turn_counter, unit, player, "Charge " + card.card_name + " " + str(delay) + " turn", from, to])
	print(battle_history.back())
	card.card_caster = unit
	card.source_cell = from
	card.target_cell = to
	card.results = results
	if delay + turn_queue.turn_counter <= turn_queue.current_round_list.size():
		turn_queue.current_round_list.insert(turn_queue.turn_counter + delay, card)
		battle_gui.turn_tabs.addCard(card,turn_queue.turn_counter + delay)
	else:
		var remainder_turns = turn_queue.current_round_list.size() - turn_queue.turn_counter
		turn_queue.addCardNextRound(delay - remainder_turns -1, card) # The -1 is for the zero index of an array
#		turn_queue.next_round_list.insert(delay - remainder_turns -1, card) # The -1 is for the zero index of an array


func _on_BattleController_unit_moved(unit, player, from, to):
	battle_history.append([turn_queue.round_counter, turn_queue.turn_counter, unit, player, "Move", from, to])
	print(battle_history.back())

func _on_BattleController_round_started():
	battle_history.append([turn_queue.round_counter, turn_queue.turn_counter, "Start Round"])
	print(battle_history.back())

func _on_BattleController_round_ended():
	battle_history.append([turn_queue.round_counter, turn_queue.turn_counter, "End Round"])
	print(battle_history.back())
	yield(get_tree().create_timer(.5), "timeout")
	yield(get_tree(), "idle_frame")
	turn_queue.endRound()



func _on_BattleController_match_ended(condition):
	if condition == 0:
		print("Lose")
	if condition == 1:
		print("Win")
