extends Node

func get_class() -> String: return "CardSaver"

const CARD_ART_DIR:String = "res://assets/images/card_art/"
const CARD_SAVE_DIR:String = "user://cards/"
var card_list_file:String = "card_list.dat"

var card_id
export var card_name:String
enum CARD_CLASS {WARRIOR,RANGER,MAGE,WARRIORRANGER,RANGERMAGE,MAGEWARRIOR,ALL}
export(CARD_CLASS) var card_class
export var action_costs:PoolByteArray = [1,1,1]
export var card_level:int = 0
export var upgrade_costs:PoolByteArray = []
export var card_art:String
enum CARD_TYPE {SKILL,PHYSICALATTACK,MAGICATTACK,MAGICSPELL,ITEM}
export(CARD_TYPE) var card_type
export var can_attack:PoolByteArray = []
export var can_defend:PoolByteArray = []
export var need_los:PoolByteArray = [] # check if this card needs line of sight (los)
export var is_homing:PoolByteArray = [] # check if this card needs line of sight (los)
export var is_unblockable:PoolByteArray = [] # check if this card is unblockable
export var is_undeflectable:PoolByteArray = [] # check if this card is undeflectable
export var is_consumable:PoolByteArray = [] # decide if card is consumed
export var has_counter:PoolByteArray = [] # decide if card has counter
export var has_reflex:PoolByteArray = [] # decide if card has reflex counter
var self_statuses:Array = [] # An array of card status effects, [Status,Duration] Duration is always counted as a full cycle
var target_statuses:Array = [] # An array of card status effects, [Status,Duration] Duration is always counted as a full cycle
export var delay:Array = [0.0,0.0,0.0] # number of turns to wait before this card is casted
#export var is_delay_full_cycle:PoolByteArray = [] # decide if delay is a full turn cycle or each turn
export var rarity:int = 10 # 10 is most common, 1 is most rare
export var description:PoolStringArray = ["Descriptive text.","Descriptive text.","Descriptive text."]
export var card_min_range:PoolByteArray = [0,0,0]
export var card_max_range:PoolByteArray = [0,0,0]
export var card_up_vertical_range:PoolByteArray = [0,0,0]
export var card_down_vertical_range:PoolByteArray = [0,0,0]
export var card_attack:PoolByteArray = [0,0,0]
export var card_animation:PoolStringArray = []
export var card_animation_weapon:PoolStringArray = []
export var card_animation_projectile:PoolStringArray = []
#export var valid_targets:Array = [[1,0,0],[1,1,0]] # Self, Ally, Enemy
export var elements:Array = [[BattleDictionary.ELEMENT.NONE,BattleDictionary.ELEMENT.NONE,BattleDictionary.ELEMENT.NONE]]
enum ELEMENTS {NONE,FIRE,ICE,ELECTRIC}



onready var blackboard:Blackboard = $Blackboard
onready var behavior_tree:BehaviorTree = $BehaviorTree
var saved_behavior:Array
var behavior_tree_idx:int = 1

var card_owner
var target_cell:HexCell
var source_cell:HexCell


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
#	#Save
#	loadSingleCardFile("Fireball")
	var debug:bool = true
	saveCardToFile(debug, true)

func save_card_debug() -> Dictionary:
	var data = {
		"card_id" : self,
		"card_name": "Fireball",
		"card_class": CARD_CLASS.MAGE,
		"action_costs": [2,2,2],
		"card_level" : 0,
		"upgrade_costs": [1,2],
		"card_art": "empty.png",
		"card_type": CARD_TYPE.MAGICATTACK,
		"can_attack": [true,true,true],
		"can_defend": [false,false,false],
		"need_los" : [true,true,true],
		"is_homing" : [false,false,false],
		"is_unblockable" : [false,false,false],
		"is_undeflectable" : [false,false,false],
		"is_consumable" : [false,false,false],
		"has_counter" : [false,false,false],
		"has_reflex" : [false,false,false],
		"self_statuses": [[[null,null]],[[null,null]],[[null,null]]], # [Status, Number of Rounds Duration]
		"target_statuses": [[[null,null]],[[null,null]],[[BattleDictionary.STATUS.FIREDEFENSEDOWN,2]]], # [Status, Number of Rounds Duration]
		"delay" : [30,30,30],
		"rarity": 5,
		"card_attack": [7,12,17],
		"card_min_range": [1,1,1],
		"card_max_range": [3,3,3],
		"card_up_vertical_range": [10,10,10],
		"card_down_vertical_range": [20,20,20],
		"card_animation" : ["magic_throw", "magic_throw", "magic_throw"],
		"card_animation_weapon" : [null, null, null],
		"card_animation_projectile" : ["fire", "fire2", "fire3"],
		"valid_targets": [[1,1,1],[1,1,1],[1,1,1]], # Self, Ally, Enemy
		"elements": [[BattleDictionary.ELEMENT.FIRE],[BattleDictionary.ELEMENT.FIRE],[BattleDictionary.ELEMENT.FIRE]],
		"behavior_tree" : save_behavior_tree(behavior_tree)
	}
	data.description = ["Deal [b]" + str(data.card_attack[0]) + "[/b] damage.", "Deal [b]" + str(data.card_attack[1]) + "[/b] damage.", "Deal [b]" + str(data.card_attack[2]) + "[/b] damage."]
	return data

func save_card() -> Dictionary:
	var data = {
		"card_id" : self,
		"card_name": card_name,
		"card_class": card_class,
		"action_costs": action_costs,
		"card_level": card_level,
		"upgrade_costs": upgrade_costs,
		"card_art": card_art,
		"card_type": card_type,
		"can_attack": can_attack,
		"can_defend": can_defend,
		"need_los" : need_los,
		"is_homing" : is_homing,
		"is_unblockable" : is_unblockable,
		"is_undeflectable" : is_undeflectable,
		"is_consumable" : is_consumable,
		"has_counter" : has_counter,
		"has_reflex": has_reflex,
		"self_statuses": self_statuses,
		"target_statuses": target_statuses,
		"delay" : delay,
		"rarity": rarity,
		"description": description,
		"card_min_range": card_min_range,
		"card_max_range": card_max_range,
		"card_up_vertical_range": card_up_vertical_range,
		"card_down_vertical_range": card_down_vertical_range,
		"card_attack": card_attack,
		"card_animation": card_animation,
		"card_animation_weapon": card_animation_weapon,
		"card_animation_projectile": card_animation_projectile,
#		"valid_targets": valid_targets,
		"elements": elements
	}
	if saved_behavior.size() > 0:
		data["behavior_tree"] = saved_behavior
	else:
		data["behavior_tree"] = save_behavior_tree(behavior_tree)
	return data

func load_card(card_data:Dictionary):
	card_id = self
	card_name = card_data.get("card_name")
	card_class = card_data.get("card_class")
	action_costs = card_data.get("action_costs")
	card_level = card_data.get("card_level")
	upgrade_costs = card_data.get("upgrade_costs")
	card_art = CARD_ART_DIR + card_data.get("card_art")
	card_type = card_data.get("card_type")
	can_attack = card_data.get("can_attack")
	can_defend = card_data.get("can_defend")
	need_los = card_data.get("need_los")
	is_homing = card_data.get("is_homing")
	is_unblockable = card_data.get("is_unblockable")
	is_undeflectable = card_data.get("is_undeflectable")
	is_consumable = card_data.get("is_consumable")
	has_counter = card_data.get("has_counter")
	has_reflex = card_data.get("has_reflex")
	self_statuses = card_data.get("self_statuses")
	target_statuses = card_data.get("target_statuses")
	delay = card_data.get("delay")
	rarity = card_data.get("rarity")
	description = card_data.get("description")
	card_min_range = card_data.get("card_min_range")
	card_max_range = card_data.get("card_max_range")
	card_up_vertical_range = card_data.get("card_up_vertical_range")
	card_down_vertical_range = card_data.get("card_down_vertical_range")
	card_attack = card_data.get("card_attack")
	card_animation = card_data.get("card_animation")
	card_animation_weapon = card_data.get("card_animation_weapon")
	card_animation_projectile = card_data.get("card_animation_projectile")
#	valid_targets = card_data.get("valid_targets")
	elements = card_data.get("elements")
	for child in get_children():
		child.free()
	load_behavior_tree(card_data.get("behavior_tree"))

func loadCardList() -> Array: # loadAllCards
	var dir = Directory.new()
	if !dir.dir_exists(CARD_SAVE_DIR):
		dir.make_dir_recursive(CARD_SAVE_DIR)
	var file:File = File.new()
	var card_list:Array = []
	var error = file.open(CARD_SAVE_DIR + card_list_file, File.READ)
	if error == OK:
		var card_file = file.get_var()
		if card_file != null:
			card_list = card_file
	file.close()
	return card_list

func loadSingleCardFile(card_name:String) -> Dictionary:
	var dir = Directory.new()
	if !dir.dir_exists(CARD_SAVE_DIR):
		dir.make_dir_recursive(CARD_SAVE_DIR)
		return {}
	if dir.file_exists(CARD_SAVE_DIR + card_name + ".crd"):
		var file:File = File.new()
		var error = file.open(CARD_SAVE_DIR + card_name + ".crd", File.READ)
		if error == OK:
			var card_data:Dictionary = file.get_var()
			load_card(card_data)
			file.close()
			return card_data
		else:
			file.close()
	else:
		print("Can't find file: " + CARD_SAVE_DIR + card_name + ".crd")
	return {}

func saveCardToFile(debug:bool, overwrite:bool = false):
	var card_data:Dictionary
	if debug:
		card_data = save_card_debug()
	else:
		card_data = save_card()
	
	var dir = Directory.new()
	if !dir.dir_exists(CARD_SAVE_DIR):
		dir.make_dir_recursive(CARD_SAVE_DIR)
	
#	var saved_cards:Array = loadCardList()
	
#	var file:File = File.new()
#	var error = file.open(CARD_SAVE_DIR + card_list_file, File.WRITE)
#	if error == OK:
#		if !saved_cards.has(card_data.get("card_name")):
#			print("Successfully created new card!")
#			saved_cards.append(card_data.get("card_name"))
#		else:
#			print("Card already exists.")
#			if !overwrite:
#				file.store_var(saved_cards)
#				return
#			print("Overwriting.")
#		file.store_var(saved_cards)
#	file.close()
	var file2:File = File.new()
	var error2 = file2.open(CARD_SAVE_DIR + card_data.get("card_name") + ".crd", File.WRITE)
	if error2 == OK:
		file2.store_var(card_data)
		print("done")
	file2.close()

func saveCardDataToFile(card_data:Dictionary) -> void:
	var dir = Directory.new()
	if !dir.dir_exists(CARD_SAVE_DIR):
		dir.make_dir_recursive(CARD_SAVE_DIR)
	var saved_cards:Array = loadCardList()
	var file2:File = File.new()
	var error2 = file2.open(CARD_SAVE_DIR + card_data.get("card_name") + ".crd", File.WRITE)
	if error2 == OK:
		if !saved_cards.has(card_data.get("card_name")):
			file2.store_var(card_data)
			print("Done")
		else:
			print("Card already exists.")
	file2.close()

func save_behavior_tree(behavior_tree) -> Array:
	if behavior_tree.get_child_count() == 0:
		pass
#		saved_behavior.append("Attack")
#		saved_behavior.append("SetStatus")
	else:
		saved_behavior.append(behavior_tree.get_child(0).get_class())
		if behavior_tree.get_child(0).get_child_count() > 0:
			saved_behavior.append(populate_behavior_tree(behavior_tree.get_child(0)))
	for child in get_children():
		child.free()
	return saved_behavior

func populate_behavior_tree(node:Node) -> Array:
	var num_items:int = 0
	var branch:Array = []
	if node.get_child_count() > 0:
		for bt_node in node.get_children():
			match bt_node.get_class():
				#Composites
				"BTSelector":
					branch.append([bt_node.get_class(), populate_behavior_tree(bt_node)])
					num_items += 1
				"BTSequence":
					branch.append([bt_node.get_class(), populate_behavior_tree(bt_node)])
					num_items += 1
				"BTRandomSelector":
					branch.append([bt_node.get_class(), populate_behavior_tree(bt_node)])
					num_items += 1
				"BTRandomSequence":
					branch.append([bt_node.get_class(), populate_behavior_tree(bt_node)])
					num_items += 1
				#Decorators
				"BTInvert":
					branch.append([bt_node.get_class(), populate_behavior_tree(bt_node)])
					num_items += 1
				"BTAlwaysSucceed":
					branch.append([bt_node.get_class(), populate_behavior_tree(bt_node)])
					num_items += 1
				"BTAlwaysFail":
					branch.append([bt_node.get_class(), populate_behavior_tree(bt_node)])
					num_items += 1
				"BTRepeat":
					branch.append([bt_node.get_class(), bt_node.times_to_repeat, populate_behavior_tree(bt_node)])
					num_items += 1
				"BTRepeatUntil":
					branch.append([bt_node.get_class(), bt_node.until_what, populate_behavior_tree(bt_node)])
					num_items += 1
				"BTCheckLastCard":
					branch.append([bt_node.get_class(), bt_node.card_source, bt_node.target_condition, bt_node.card, populate_behavior_tree(bt_node)])
					num_items += 1
				"BTConditional":
					branch.append([bt_node.get_class(), bt_node.comparison, bt_node.array_check, populate_behavior_tree(bt_node)])
					num_items += 1
				"IsUnitLevel":
					branch.append([bt_node.get_class(), bt_node.unit_level, populate_behavior_tree(bt_node)])
					num_items += 1
				"IsCardLevel":
					branch.append([bt_node.get_class(), bt_node.card_level, populate_behavior_tree(bt_node)])
					num_items += 1
				#Leaves
				"SetSingleTarget":
					branch.append([bt_node.get_class()])
					num_items += 1
				"SetSplashTargets":
					branch.append([bt_node.get_class(), bt_node.splash_min_range, bt_node.splash_max_range, bt_node.splash_up_vertical_range, bt_node.splash_down_vertical_range, bt_node.valid_targets])
					num_items += 1
				"SetIntArg":
					branch.append([bt_node.get_class(), bt_node.int_arg, bt_node.int_source, bt_node.integer, bt_node.unit_variable])
					num_items += 1
				"Attack":
					branch.append([bt_node.get_class(), bt_node.valid_targets])
					num_items += 1
				"SetAttack":
					branch.append([bt_node.get_class(), bt_node.int_source, bt_node.attack_value, bt_node.unit_variable, bt_node.target_calculation])
					num_items += 1
				"ModifyAttack":
					branch.append([bt_node.get_class(), bt_node.operation, bt_node.int_source, bt_node.attack_value, bt_node.unit_variable, bt_node.target_calculation])
					num_items += 1
				"SetStatus":
					branch.append([bt_node.get_class()])
					num_items += 1
				"CasterDrawCard":
					branch.append([bt_node.get_class(), bt_node.draw_amount])
					num_items += 1
	var output = []
	for i in num_items:
		output += branch[i]
	return output

func load_behavior_tree(behavior_array) -> void:
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
					var bt_decorator = BTConditional.new()
					bt_decorator.name = bt_decorator.get_class()
					bt_decorator.card_source = bt_node_array[bt_node+1]
					bt_decorator.target_condition = bt_node_array[bt_node+2]
					bt_decorator.card = bt_node_array[bt_node+3]
					parent.add_child(bt_decorator)
				"BTConditional":
					var bt_decorator = BTConditional.new()
					bt_decorator.name = bt_decorator.get_class()
					bt_decorator.comparison = bt_node_array[bt_node+1]
					bt_decorator.array_check = bt_node_array[bt_node+2]
					parent.add_child(bt_decorator)
				#Leaves
				"Attack":
					var bt_leaf = Attack.new()
					bt_leaf.name = bt_leaf.get_class()
					bt_leaf.valid_targets = bt_node_array[bt_node+1]
					parent.add_child(bt_leaf)
				"SetAttack":
					var bt_leaf = SetAttack.new()
					bt_leaf.name = bt_leaf.get_class()
					bt_leaf.int_source = bt_node_array[bt_node+1]
					bt_leaf.attack_value = bt_node_array[bt_node+2]
					bt_leaf.unit_variable = bt_node_array[bt_node+3]
					bt_leaf.target_calculation = bt_node_array[bt_node+4]
					parent.add_child(bt_leaf)
				"ModifyAttack":
					var bt_leaf = ModifyAttack.new()
					bt_leaf.name = bt_leaf.get_class()
					bt_leaf.operation = bt_node_array[bt_node+1]
					bt_leaf.int_source = bt_node_array[bt_node+2]
					bt_leaf.attack_value = bt_node_array[bt_node+3]
					bt_leaf.unit_variable = bt_node_array[bt_node+4]
					bt_leaf.target_calculation = bt_node_array[bt_node+5]
					parent.add_child(bt_leaf)
				"SetSingleTarget":
					var bt_leaf = SetSingleTarget.new()
					bt_leaf.name = bt_leaf.get_class()
					parent.add_child(bt_leaf)
				"SetSplashTargets":
					var bt_leaf = SetSplashTargets.new()
					bt_leaf.name = bt_leaf.get_class()
					bt_leaf.splash_min_range = bt_node_array[bt_node+1]
					bt_leaf.splash_max_range = bt_node_array[bt_node+2]
					bt_leaf.splash_up_vertical_range = bt_node_array[bt_node+3]
					bt_leaf.splash_down_vertical_range = bt_node_array[bt_node+4]
					bt_leaf.valid_targets = bt_node_array[bt_node+5]
					parent.add_child(bt_leaf)
				"SetIntArg":
					var bt_leaf = SetIntArg.new()
					bt_leaf.name = bt_leaf.get_class()
					bt_leaf.int_arg = bt_node_array[bt_node+1]
					bt_leaf.int_source = bt_node_array[bt_node+2]
					bt_leaf.integer = bt_node_array[bt_node+3]
					bt_leaf.unit_variable = bt_node_array[bt_node+4]
					parent.add_child(bt_leaf)
				"SetStatus":
					var bt_leaf = SetStatus.new()
					bt_leaf.name = bt_leaf.get_class()
					parent.add_child(bt_leaf)
				"CasterDrawCard":
					var bt_leaf = CasterDrawCard.new()
					bt_leaf.name = bt_leaf.get_class()
					bt_leaf.draw_amount = bt_node_array[bt_node+1]
					bt_leaf.card_variable = bt_node_array[bt_node+2]
					bt_leaf.card_variable_value = String(bt_node_array[bt_node+3])
					bt_leaf.valid_targets = bt_node_array[bt_node+4]
					parent.add_child(bt_leaf)
