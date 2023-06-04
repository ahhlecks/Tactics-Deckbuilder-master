extends Node

class_name Card

#func get_class() -> String: return "Card"

const CARD_ART_DIR:String = "res://assets/images/card_art/"
const CARD_SAVE_DIR:String = "user://cards/"
var card_list_file:String = "card_list.dat"
var card_id
var unique_id
var item:Dictionary
export var card_name:String
enum CARD_CLASS {WARRIOR,RANGER,MAGE,WARRIORRANGER,RANGERMAGE,MAGEWARRIOR,ALL}
export(CARD_CLASS) var card_class
export var action_costs:PoolByteArray = [1,1,1]
export var card_level:int = 0
export var upgrade_costs:PoolByteArray = []
export var card_art:String
export var card_icon:String
enum CARD_TYPE {OFFENSE,DEFENSE,UTILITY}
export(CARD_TYPE) var card_type
export var item_type:Array = []
export var can_attack:PoolByteArray = []
export var can_defend:PoolByteArray = []
export var need_los:PoolByteArray = [] # check if this card needs line of sight (los)
export var is_homing:PoolByteArray = [] # check if this card can home in on target
export var has_combo:PoolByteArray = [] # check if this card can combo
export var is_piercing:PoolByteArray = [] # check if this card is piercing
export var is_shattering:PoolByteArray = [] # check if this card is piercing
export var is_consumable:PoolByteArray = [] # decide if card is consumed
export var has_counter:PoolByteArray = [] # decide if card has counter
export var has_reflex:PoolByteArray = [] # decide if card has reflex
export var self_eliminating:PoolByteArray = [] # decide if card is self eliminating
export var hexagonal_targeting:PoolByteArray = []
var self_statuses:Array = [[null,null]] # An array of card status effects, [Status,Duration] Duration is always counted as a full round
var target_statuses:Array = [[null,null]] # An array of card status effects, [Status,Duration] Duration is always counted as a full round
var prerequisites:Array = [[null,null,null]] # An array of card prerequisites, [Card Variable, Value, IsCost]
export var delay:Array = [0.0,0.0,0.0] # number of turns to wait before this card is casted
export var rarity:int = 10 # 10 is most common, 1 is most rare
export var description:PoolStringArray = ["Descriptive text.","Descriptive text.","Descriptive text."]
export var card_min_range:PoolByteArray = [0,0,0]
export var card_max_range:PoolByteArray = [0,0,0]
export var card_up_vertical_range:PoolByteArray = [0,0,0]
export var card_down_vertical_range:PoolByteArray = [0,0,0]
export var card_attack:PoolByteArray = [0,0,0]
export var card_added_accuracy:PoolByteArray = [0,0,0]
export var card_added_crit_accuracy:PoolByteArray = [0,0,0]
export var card_animation:Array = []
export var card_animation_left_weapon:Array = []
export var card_animation_right_weapon:Array = []
export var card_animation_projectile:Array = []
export var card_counter_anim_tandem:Array = []
export var bypass_popup:bool
export var ignore_item_stats:bool
export var elements:Array = [[BattleDictionary.ELEMENT.NONE,BattleDictionary.ELEMENT.NONE,BattleDictionary.ELEMENT.NONE]]
#enum ELEMENTS {NONE,FIRE,ICE,ELECTRIC}
var utility_value:int


var behavior_tree:BehaviorTree
var blackboard:Blackboard
var behavior_trees:Array
#var behavior_tree_idx:int = 1
var has_attack:bool = false
var is_valid:bool = true
var results:Array = [] # [[From, To, Attack, Attack Modifiers, List of Modifiers, Hit Rate, Utility Score], 
#						[From, To, Attack, Attack Modifiers, List of Modifiers, Hit Rate, Utility Score]] 2D Array

var is_reaction:bool
var card_owner:HexUnit
var card_caster:HexUnit
var source_cell:HexCell
var target_unit:HexUnit
var target_cell:HexCell
var splash_range:Array
var valid_targets:Array
var empty_targets:Array
var original_card_values:Array #[[stat,stat_value]]

signal completed


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func export_vars() -> Dictionary:
	var data = {
		"card_id": card_id,
		"unique_id": unique_id,
		"card_name": card_name,
		"item": item,
		"card_owner": card_owner,
		"card_class": card_class,
		"action_costs": action_costs,
		"card_level": card_level,
		"upgrade_costs": upgrade_costs,
		"card_art": card_art,
		"card_icon": card_icon,
		"card_type": card_type,
		"item_type": item_type,
		"can_attack": can_attack,
		"can_defend": can_defend,
		"need_los": need_los,
		"is_homing": is_homing,
		"has_combo": has_combo,
		"is_piercing": is_piercing,
		"is_shattering": is_shattering,
		"is_consumable": is_consumable,
		"has_counter": has_counter,
		"has_reflex": has_reflex,
		"self_eliminating": self_eliminating,
		"hexagonal_targeting": hexagonal_targeting,
		"self_statuses": self_statuses,
		"target_statuses": target_statuses,
		"prerequisites": prerequisites,
		"delay": delay,
		"rarity": rarity,
		"description": description,
		"card_min_range": card_min_range ,
		"card_max_range": card_max_range,
		"card_up_vertical_range": card_up_vertical_range,
		"card_down_vertical_range": card_down_vertical_range,
		"card_attack": card_attack,
		"card_added_accuracy": card_added_accuracy,
		"card_added_crit_accuracy": card_added_crit_accuracy,
		"card_caster": card_caster,
		"source_cell": source_cell,
		"target_unit": target_unit,
		"target_cell": target_cell,
		"card_animation": card_animation,
		"card_animation_left_weapon": card_animation_left_weapon,
		"card_animation_right_weapon": card_animation_right_weapon,
		"card_animation_projectile": card_animation_projectile,
		"bypass_popup": bypass_popup,
		"ignore_item_stats": ignore_item_stats,
		"elements": elements,
		"behavior_trees": behavior_trees,
		"original_card_values": original_card_values
	}
	return data

func load_card(card_data:Dictionary):
	card_id = self
	ignore_item_stats = card_data.get("ignore_item_stats")
	item = card_data.get("item")
	unique_id = card_data.get("unique_id")
	card_name = card_data.get("card_name")
	card_owner = card_data.get("card_owner")
	card_class = card_data.get("card_class")
	action_costs = card_data.get("action_costs")
	card_level = card_data.get("card_level")
	upgrade_costs = card_data.get("upgrade_costs")
	card_art = CARD_ART_DIR + card_data.get("card_art")
	card_icon = card_data.get("card_icon")
	card_type = card_data.get("card_type")
	item_type = card_data.get("item_type")
	can_attack = card_data.get("can_attack")
	can_defend = card_data.get("can_defend")
	need_los = card_data.get("need_los")
	is_homing = card_data.get("is_homing")
	has_combo = card_data.get("has_combo")
	is_piercing = card_data.get("is_piercing")
	is_shattering = card_data.get("is_shattering")
	is_consumable = card_data.get("is_consumable")
	has_counter = card_data.get("has_counter")
	has_reflex = card_data.get("has_reflex")
	self_eliminating = card_data.get("self_eliminating")
	hexagonal_targeting = card_data.get("hexagonal_targeting")
	self_statuses = card_data.get("self_statuses")
	target_statuses = card_data.get("target_statuses")
	prerequisites = card_data.get("prerequisites")
	delay = card_data.get("delay")
	rarity = card_data.get("rarity")
	description = card_data.get("description")
	card_min_range = card_data.get("card_min_range")
	card_max_range = card_data.get("card_max_range")
	card_up_vertical_range = card_data.get("card_up_vertical_range")
	card_down_vertical_range = card_data.get("card_down_vertical_range")
	card_attack = card_data.get("card_attack")
	card_added_accuracy = card_data.get("card_added_accuracy")
	card_added_crit_accuracy = card_data.get("card_added_crit_accuracy")
	if card_data.get("card_animation") != null:
		card_animation = card_data.get("card_animation")
	if card_data.get("card_animation_left_weapon") != null:
		card_animation_left_weapon = card_data.get("card_animation_left_weapon")
	if card_data.get("card_animation_right_weapon") != null:
		card_animation_right_weapon = card_data.get("card_animation_right_weapon")
	if card_data.get("card_animation_projectile") != null:
		card_animation_projectile = card_data.get("card_animation_projectile")
	bypass_popup = card_data.get("bypass_popup")
	elements = card_data.get("elements")
	behavior_trees = card_data.get("behavior_trees")
	original_card_values = card_data.get("original_card_values")
	load_behavior_tree(behavior_trees[card_level])

func load_behavior_tree(behavior_array) -> void:
	for child in get_children():
		child.free()
	var new_blackboard = Blackboard.new()
	new_blackboard.name = "Blackboard"
	add_child(new_blackboard)
	blackboard = new_blackboard
	var new_behavior_tree = BehaviorTree.new()
	new_behavior_tree.name = "BehaviorTree"
	new_behavior_tree.sync_mode = "once"
	add_child(new_behavior_tree)
	behavior_tree = new_behavior_tree
	load_behavior_tree_item(behavior_tree,behavior_array)
#
func load_behavior_tree_item(parent, bt_node_array) -> void:
	var new_parent
	for bt_node in bt_node_array.size():
		if typeof(bt_node_array[bt_node]) == TYPE_ARRAY:
			load_behavior_tree_item(new_parent, bt_node_array[bt_node])
		else:
			match bt_node_array[bt_node]:
				#Composites
				"BTSelector":
					var bt_composite = BTSelector.new()
					bt_composite.name = bt_composite.get_class()
					parent.add_child(bt_composite)
					new_parent = bt_composite
				"BTSequence":
					var bt_composite = BTSequence.new()
					bt_composite.name = bt_composite.get_class()
					parent.add_child(bt_composite)
					new_parent = bt_composite
				"BTRandomSelector":
					var bt_composite = BTRandomSelector.new()
					bt_composite.name = bt_composite.get_class()
					parent.add_child(bt_composite)
					new_parent = bt_composite
				"BTRandomSequence":
					var bt_composite = BTRandomSequence.new()
					bt_composite.name = bt_composite.get_class()
					parent.add_child(bt_composite)
					new_parent = bt_composite
				#Decorators
				"BTInvert":
					var bt_decorator = BTInvert.new()
					bt_decorator.name = bt_decorator.get_class()
					parent.add_child(bt_decorator)
					new_parent = bt_decorator
				"BTAlwaysSucceed":
					var bt_decorator = BTAlwaysSucceed.new()
					bt_decorator.name = bt_decorator.get_class()
					parent.add_child(bt_decorator)
					new_parent = bt_decorator
				"BTAlwaysFail":
					var bt_decorator = BTAlwaysFail.new()
					bt_decorator.name = bt_decorator.get_class()
					parent.add_child(bt_decorator)
					new_parent = bt_decorator
				"BTRepeat":
					var bt_decorator = BTRepeat.new()
					bt_decorator.name = bt_decorator.get_class()
					bt_decorator.times_to_repeat = bt_node_array[bt_node+1]
					parent.add_child(bt_decorator)
					new_parent = bt_decorator
				"BTRepeatUntil":
					var bt_decorator = BTRepeatUntil.new()
					bt_decorator.name = bt_decorator.get_class()
					bt_decorator.until_what = bt_node_array[bt_node+1]
					parent.add_child(bt_decorator)
					new_parent = bt_decorator
				"BTCheckLastCard":
					var bt_decorator = BTCheckLastCard.new()
					bt_decorator.name = bt_decorator.get_class()
					bt_decorator.card_source = bt_node_array[bt_node+1]
					bt_decorator.target_condition = bt_node_array[bt_node+2]
					bt_decorator.card = bt_node_array[bt_node+3]
					parent.add_child(bt_decorator)
					new_parent = bt_decorator
				"BTConditional":
					var bt_decorator = BTConditional.new()
					bt_decorator.name = bt_decorator.get_class()
					bt_decorator.comparison = bt_node_array[bt_node+1]
					bt_decorator.array_check = bt_node_array[bt_node+2]
					parent.add_child(bt_decorator)
					new_parent = bt_decorator
				"BTPercentSucceed":
					var bt_decorator = BTPercentSucceed.new()
					bt_decorator.name = bt_decorator.get_class()
					bt_decorator.success_rate = bt_node_array[bt_node+1]
					bt_decorator.int_arg = bt_node_array[bt_node+2]
					parent.add_child(bt_decorator)
					new_parent = bt_decorator
				#Leaves
				"Attack":
					var bt_leaf = Attack.new()
					bt_leaf.name = bt_leaf.get_class()
					bt_leaf.valid_targets = bt_node_array[bt_node+1]
					parent.add_child(bt_leaf)
					has_attack = true
				"SetSingleTarget":
					var bt_leaf = SetSingleTarget.new()
					bt_leaf.name = bt_leaf.get_class()
					bt_leaf.target_source = bt_node_array[bt_node+1]
					parent.add_child(bt_leaf)
				"SetSplashTargets":
					var bt_leaf = SetSplashTargets.new()
					bt_leaf.name = bt_leaf.get_class()
					bt_leaf.target_source = bt_node_array[bt_node+1]
					bt_leaf.splash_min_range = bt_node_array[bt_node+2]
					bt_leaf.splash_max_range = bt_node_array[bt_node+3]
					bt_leaf.splash_up_vertical_range = bt_node_array[bt_node+4]
					bt_leaf.splash_down_vertical_range = bt_node_array[bt_node+5]
					bt_leaf.valid_targets = bt_node_array[bt_node+6]
					parent.add_child(bt_leaf)
					if bt_leaf.target_source == 1:
						splash_range = [bt_leaf.splash_min_range,bt_leaf.splash_max_range,bt_leaf.splash_up_vertical_range,bt_leaf.splash_down_vertical_range]
				"SetInlineTargets":
					var bt_leaf = SetInlineTargets.new()
					bt_leaf.name = bt_leaf.get_class()
					bt_leaf.inline_inner_range = bt_node_array[bt_node+1]
					bt_leaf.inline_outer_range = bt_node_array[bt_node+2]
					bt_leaf.inline_up_vertical_range = bt_node_array[bt_node+3]
					bt_leaf.inline_down_vertical_range = bt_node_array[bt_node+4]
					bt_leaf.valid_targets = bt_node_array[bt_node+5]
					parent.add_child(bt_leaf)
				"SetLeftRightTargets":
					var bt_leaf = SetLeftRightTargets.new()
					bt_leaf.name = bt_leaf.get_class()
					bt_leaf.width = bt_node_array[bt_node+1]
					bt_leaf.depth = bt_node_array[bt_node+2]
					bt_leaf.splash_up_vertical_range = bt_node_array[bt_node+3]
					bt_leaf.splash_down_vertical_range = bt_node_array[bt_node+4]
					bt_leaf.valid_targets = bt_node_array[bt_node+5]
					parent.add_child(bt_leaf)
				"ClearTargets":
					var bt_leaf = ClearTargets.new()
					bt_leaf.name = bt_leaf.get_class()
					parent.add_child(bt_leaf)
				"SetIntArg":
					var bt_leaf = SetIntArg.new()
					bt_leaf.name = bt_leaf.get_class()
					bt_leaf.int_arg = bt_node_array[bt_node+1]
					bt_leaf.int_source = bt_node_array[bt_node+2]
					bt_leaf.integer = bt_node_array[bt_node+3]
					bt_leaf.unit_variable = bt_node_array[bt_node+4]
					bt_leaf.card_variable = bt_node_array[bt_node+5]
					bt_leaf.target_calculation = bt_node_array[bt_node+6]
					parent.add_child(bt_leaf)
				"SetStatus":
					var bt_leaf = SetStatus.new()
					bt_leaf.name = bt_leaf.get_class()
					parent.add_child(bt_leaf)
				"CasterAddStatus":
					var bt_leaf = CasterAddStatus.new()
					bt_leaf.name = bt_leaf.get_class()
					bt_leaf.status = bt_node_array[bt_node+1]
					bt_leaf.duration = bt_node_array[bt_node+2]
					parent.add_child(bt_leaf)
				"TargetAddStatus":
					var bt_leaf = TargetAddStatus.new()
					bt_leaf.name = bt_leaf.get_class()
					bt_leaf.status = bt_node_array[bt_node+1]
					bt_leaf.duration = bt_node_array[bt_node+2]
					bt_leaf.valid_targets = bt_node_array[bt_node+3]
					parent.add_child(bt_leaf)
				"CasterDrawCard":
					var bt_leaf = CasterDrawCard.new()
					bt_leaf.name = bt_leaf.get_class()
					bt_leaf.draw_amount = bt_node_array[bt_node+1]
					bt_leaf.deck = bt_node_array[bt_node+2]
					bt_leaf.card_variable = bt_node_array[bt_node+3]
					bt_leaf.card_variable_value = String(bt_node_array[bt_node+4])
					bt_leaf.comparison = bt_node_array[bt_node+5]
					bt_leaf.fallback = bt_node_array[bt_node+6]
					parent.add_child(bt_leaf)
				"TargetDrawCard":
					var bt_leaf = TargetDrawCard.new()
					bt_leaf.name = bt_leaf.get_class()
					bt_leaf.draw_amount = bt_node_array[bt_node+1]
					bt_leaf.deck = bt_node_array[bt_node+2]
					bt_leaf.card_variable = bt_node_array[bt_node+3]
					bt_leaf.card_variable_value = String(bt_node_array[bt_node+4])
					bt_leaf.comparison = bt_node_array[bt_node+5]
					bt_leaf.valid_targets = bt_node_array[bt_node+6]
					bt_leaf.fallback = bt_node_array[bt_node+7]
					parent.add_child(bt_leaf)
				"CasterModifyStat":
					var bt_leaf = CasterModifyStat.new()
					bt_leaf.name = bt_leaf.get_class()
					bt_leaf.operation = bt_node_array[bt_node+1]
					bt_leaf.stat = bt_node_array[bt_node+2]
					bt_leaf.stat_value = bt_node_array[bt_node+3]
					bt_leaf.int_arg = bt_node_array[bt_node+4]
					parent.add_child(bt_leaf)
				"TargetModifyStat":
					var bt_leaf = TargetModifyStat.new()
					bt_leaf.name = bt_leaf.get_class()
					bt_leaf.operation = bt_node_array[bt_node+1]
					bt_leaf.stat = bt_node_array[bt_node+2]
					bt_leaf.stat_value = bt_node_array[bt_node+3]
					bt_leaf.int_arg = bt_node_array[bt_node+4]
					bt_leaf.valid_targets = bt_node_array[bt_node+5]
					parent.add_child(bt_leaf)
				"CasterModifyStatDuration":
					var bt_leaf = CasterModifyStatDuration.new()
					bt_leaf.name = bt_leaf.get_class()
					bt_leaf.operation = bt_node_array[bt_node+1]
					bt_leaf.stat = bt_node_array[bt_node+2]
					bt_leaf.stat_value = bt_node_array[bt_node+3]
					bt_leaf.int_arg = bt_node_array[bt_node+4]
					bt_leaf.duration = bt_node_array[bt_node+5]
					parent.add_child(bt_leaf)
				"TargetModifyStatDuration":
					var bt_leaf = TargetModifyStatDuration.new()
					bt_leaf.name = bt_leaf.get_class()
					bt_leaf.operation = bt_node_array[bt_node+1]
					bt_leaf.stat = bt_node_array[bt_node+2]
					bt_leaf.stat_value = bt_node_array[bt_node+3]
					bt_leaf.int_arg = bt_node_array[bt_node+4]
					bt_leaf.duration = bt_node_array[bt_node+5]
					bt_leaf.valid_targets = bt_node_array[bt_node+6]
					parent.add_child(bt_leaf)
				"CasterAddCard":
					var bt_leaf = CasterAddCard.new()
					bt_leaf.name = bt_leaf.get_class()
					bt_leaf.add_amount = bt_node_array[bt_node+1]
					bt_leaf.card_name = bt_node_array[bt_node+2]
					bt_leaf.card_level = bt_node_array[bt_node+3]
					bt_leaf.deck = bt_node_array[bt_node+4]
					parent.add_child(bt_leaf)
				"TargetAddCard":
					var bt_leaf = TargetAddCard.new()
					bt_leaf.name = bt_leaf.get_class()
					bt_leaf.add_amount = bt_node_array[bt_node+1]
					bt_leaf.card_name = bt_node_array[bt_node+2]
					bt_leaf.card_level = bt_node_array[bt_node+3]
					bt_leaf.deck = bt_node_array[bt_node+4]
					bt_leaf.valid_targets = bt_node_array[bt_node+5]
					parent.add_child(bt_leaf)
				"HandModifyStat":
					var bt_leaf = HandModifyStat.new()
					bt_leaf.name = bt_leaf.get_class()
					bt_leaf.operation = bt_node_array[bt_node+1]
					bt_leaf.stat = bt_node_array[bt_node+2]
					bt_leaf.stat_value = bt_node_array[bt_node+3]
					bt_leaf.stat_requirement = bt_node_array[bt_node+4]
					bt_leaf.stat_requirement_value = bt_node_array[bt_node+5]
					bt_leaf.int_arg = bt_node_array[bt_node+6]
					parent.add_child(bt_leaf)
				"CardModifyStat":
					var bt_leaf = CardModifyStat.new()
					bt_leaf.name = bt_leaf.get_class()
					bt_leaf.operation = bt_node_array[bt_node+1]
					bt_leaf.stat = bt_node_array[bt_node+2]
					bt_leaf.stat_value = bt_node_array[bt_node+3]
					bt_leaf.int_arg = bt_node_array[bt_node+4]
					parent.add_child(bt_leaf)
				"Pull":
					var bt_leaf = Pull.new()
					bt_leaf.name = bt_leaf.get_class()
					bt_leaf.valid_targets = bt_node_array[bt_node+1]
					bt_leaf.strength = bt_node_array[bt_node+2]
					parent.add_child(bt_leaf)
				"Push":
					var bt_leaf = Push.new()
					bt_leaf.name = bt_leaf.get_class()
					bt_leaf.valid_targets = bt_node_array[bt_node+1]
					bt_leaf.strength = bt_node_array[bt_node+2]
					parent.add_child(bt_leaf)


func execute(is_real:bool, initial_cast:bool = false) -> void:
	utility_value = 0
	results = []
	behavior_tree.is_real = is_real
	behavior_tree.is_active = true
	behavior_tree.initial_cast = initial_cast
	behavior_tree.run()
	if !is_real:
		if blackboard.has_data("utility_value"):
			utility_value = blackboard.get_data("utility_value")
			if blackboard.has_data("utility_value_multiplier"):
				utility_value *= blackboard.get_data("utility_value_multiplier")
#		for key in blackboard.data.keys():
#			if key.begins_with("caster_stat_"):
#				var stat:String = key.right(12)
#				prints(stat,card_caster.get(stat),blackboard.get_data(key))
#				utility_value += blackboard.get_data(key) - card_caster.get(stat)

#if blackboard.has_data("caster_strength"):
#	print(blackboard.get_data("caster_strength"))

func isValid(change_AP:bool = false) -> bool:
	for p in prerequisites[card_level]:
		if p[0] != null:
			match p[0]:
				"unit_deck_size":
					if card_caster.active_deck.size() < p[1]:
						return false
				"unit_hand_size":
					if card_caster.hand_deck.size() < p[1]:
						return false
				"unit_discard_size":
					if card_caster.discard_deck.size() < p[1]:
						return false
				"unit_consumed_size":
					if card_caster.consumed_deck.size() < p[1]:
						return false
				_:
					if card_caster.get(p[0]) < p[1]:
						return false
	if change_AP:
		if has_combo[card_level] and card_caster.has_combo:
			saveCardStat("action_costs")
			action_costs[card_level] =  max(action_costs[card_level] - int(has_combo[card_level] and card_caster.has_combo),0)
		if !has_counter[card_level] and is_reaction:
			saveCardStat("action_costs")
			action_costs[card_level] +=  1
	return card_caster.current_action_points >= action_costs[card_level]


func saveCardStat(stat:String) -> void:
	var has_modifier:bool = false
	for card_values in original_card_values:
		if card_values[0] == stat:
			has_modifier = true
	if !has_modifier:
		var old_stat = [stat]
		original_card_values.append([stat,old_stat])

func loadOriginalCardStats() -> void:
	for stat in original_card_values:
		set(stat[0],stat[1])
	original_card_values.clear()


func showResults() -> String:
	var output:String
	for result in results:
# warning-ignore:unassigned_variable_op_assign
		output += result[1].unit_name + " " + str(result[1].current_health) + " -> " + str(max(0,result[1].current_health - result[2]))
		for multipliers in result[4]:
			if multipliers != 0:
				output += " " + BattleDictionary.valid_statuses[multipliers][0]
		output += "\n"
	return output

func complete():
	card_caster.unit_owner.battle_gui.updateUnitGUI(card_caster)
	if get_node("Blackboard").has_data("target_units"):
		valid_targets = get_node("Blackboard").get_data("target_units")
	if get_node("Blackboard").has_data("empty_targets"):
		empty_targets = get_node("Blackboard").get_data("empty_targets")
	get_node("BehaviorTree").call_deferred("queue_free")
	remove_child(get_node("BehaviorTree"))
	get_node("Blackboard").call_deferred("queue_free")
	remove_child(get_node("Blackboard"))
	if behavior_tree.is_real:
		loadOriginalCardStats()
		utility_value = 0
		card_caster.cards_played.append(export_vars())
		if is_instance_valid(blackboard):
			blackboard.clear_all_data()
	emit_signal("completed")

func clearData():
	if is_instance_valid(blackboard):
		blackboard.clear_all_data()
	card_id = null
	card_owner = null
	card_caster = null
	source_cell = null
	target_unit = null
	target_cell = null
	results = []

func hasSplashRange() -> bool:
	return !splash_range.empty()

func clear() -> void:
	clearData()
	if has_node("BehaviorTree"):
		get_node("BehaviorTree").call_deferred("queue_free")
		remove_child(get_node("BehaviorTree"))
	if has_node("Blackboard"):
		get_node("Blackboard").call_deferred("queue_free")
		remove_child(get_node("Blackboard"))
	queue_free()
