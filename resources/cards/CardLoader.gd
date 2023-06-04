extends Node

func get_class() -> String: return "CardLoader"

#var card_id
#export var card_name:String
#enum CARD_CLASS {WARRIOR,RANGER,MAGE,WARRIORRANGER,RANGERMAGE,MAGEWARRIOR,ALL}
#export(CARD_CLASS) var card_class
#export var action_costs:PoolByteArray = [1,1,1]
#export var card_level:int = 0
#export var upgrade_costs:PoolByteArray = []
#export var card_art:String
#enum CARD_TYPE {SKILL,PHYSICALATTACK,MAGICATTACK,MAGICSPELL,ITEM}
#export(CARD_TYPE) var card_type
#export var can_attack:PoolByteArray = []
#export var can_defend:PoolByteArray = []
#export var need_los:PoolByteArray = [] # check if this card needs line of sight (los)
#export var is_homing:PoolByteArray = [] # check if this card needs line of sight (los)
#export var is_unblockable:PoolByteArray = [] # check if this card is unblockable
#export var is_undeflectable:PoolByteArray = [] # check if this card is undeflectable
#export var is_consumable:PoolByteArray = [] # decide if card is consumed
#export var has_counter:PoolByteArray = [] # decide if card has counter
#export var has_reflex:PoolByteArray = [] # decide if card has counter
#var self_statuses:Array = [[null,null]] # An array of card status effects, [Status,Duration] Duration is always counted as a full cycle
#var target_statuses:Array = [[null,null]] # An array of card status effects, [Status,Duration] Duration is always counted as a full cycle
#export var delay:Array = [0.0,0.0,0.0] # number of turns to wait before this card is casted
##export var is_delay_full_cycle:PoolByteArray = [] # decide if delay is a full turn cycle or each turn
#export var rarity:int = 10 # 10 is most common, 1 is most rare
#export var description:PoolStringArray = ["Descriptive text.","Descriptive text.","Descriptive text."]
#export var card_min_range:PoolByteArray = [0,0,0]
#export var card_max_range:PoolByteArray = [0,0,0]
#export var card_up_vertical_range:PoolByteArray = [0,0,0]
#export var card_down_vertical_range:PoolByteArray = [0,0,0]
#export var card_attack:PoolByteArray = [0,0,0]
#export var card_animation:PoolStringArray = []
#export var card_animation_weapon:PoolStringArray = []
#export var card_animation_projectile:PoolStringArray = []
##export var valid_targets:Array = [[1,0,0],[1,1,0]] # Self, Ally, Enemy
#export var elements:Array = [[BattleDictionary.ELEMENT.NONE,BattleDictionary.ELEMENT.NONE,BattleDictionary.ELEMENT.NONE]]
#enum ELEMENTS {NONE,FIRE,ICE,ELECTRIC}



#onready var behavior_tree:BehaviorTree = $BehaviorTree
#onready var blackboard:Blackboard = $Blackboard
#var behavior_trees:Array
#var behavior_tree_idx:int = 1

#var card_owner
#var target_cell:HexCell
#var source_cell:HexCell

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func copyRecursively(from, to) -> void:
	var directory = Directory.new()
	
	# If it doesn't exists, create target directory
	if not directory.dir_exists(to):
		directory.make_dir_recursive(to)
	
	# Open directory
	var error = directory.open(from)
	if error == OK:
		# List directory content
		directory.list_dir_begin(true)
		var file_name = directory.get_next()
		while file_name != "":
			if directory.current_is_dir():
				copyRecursively(from + "/" + file_name, to + "/" + file_name)
			else:
				directory.copy(from + "/" + file_name, to + "/" + file_name)
			file_name = directory.get_next()
	else:
		print("Error copying " + from + " to " + to)

func loadCardList(save_dir:bool) -> Array: # loadAllCards
	var card_list:Array = []
	var dir = Directory.new()
	var file:File = File.new()
	if !save_dir:
		if dir.open(PlayerVars.CARD_LOAD_DIR) == OK:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if dir.current_is_dir():
					pass
	#				print("Found directory: " + file_name)
				if !dir.current_is_dir():
	#				print("Found file: " + file_name)
					var error = file.open(PlayerVars.CARD_LOAD_DIR + file_name, File.READ)
					if error == OK:
#						var card_data:Dictionary = file.get_var()
						card_list.append(file_name.replace(".crd",""))
					else:
						print("Invalid card file.")
					file.close()
				file_name = dir.get_next()
		if card_list.empty():
			dir.open(PlayerVars.CARD_SAVE_DIR)
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if dir.current_is_dir():
					pass
	#				print("Found directory: " + file_name)
				if !dir.current_is_dir():
	#				print("Found file: " + file_name)
					var error = file.open(PlayerVars.CARD_SAVE_DIR + file_name, File.READ)
					if error == OK:
#						var card_data:Dictionary = file.get_var()
						card_list.append(file_name.replace(".crd",""))
					else:
						print("Invalid card file.")
					file.close()
				file_name = dir.get_next()
	else:
		if dir.open(PlayerVars.CARD_SAVE_DIR) == OK:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if dir.current_is_dir():
					pass
	#				print("Found directory: " + file_name)
				if !dir.current_is_dir():
	#				print("Found file: " + file_name)
					var error = file.open(PlayerVars.CARD_SAVE_DIR + file_name, File.READ)
					if error == OK:
#						var card_data:Dictionary = file.get_var()
						card_list.append(file_name.replace(".crd",""))
					else:
						print("Invalid card file.")
					file.close()
				file_name = dir.get_next()
		if card_list.empty():
			dir.open(PlayerVars.CARD_LOAD_DIR)
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if dir.current_is_dir():
					pass
	#				print("Found directory: " + file_name)
				if !dir.current_is_dir():
	#				print("Found file: " + file_name)
					var error = file.open(PlayerVars.CARD_LOAD_DIR + file_name, File.READ)
					if error == OK:
#						var card_data:Dictionary = file.get_var()
						card_list.append(file_name.replace(".crd",""))
					else:
						print("Invalid card file.")
					file.close()
				file_name = dir.get_next()
	return card_list

#	var dir = Directory.new()
#	if !dir.dir_exists(CARD_SAVE_DIR):
#		dir.make_dir_recursive(CARD_SAVE_DIR)
#	var file:File = File.new()
#	var card_list:Array = []
#	var error = file.open(CARD_SAVE_DIR + card_list_file, File.READ)
#	if error == OK:
#		var card_file = file.get_var()
#		if card_file != null:
#			card_list = card_file
#	file.close()
#	return card_list

func loadSingleCardFile(card_name:String, save_dir:bool = false) -> Dictionary:
	var dir = Directory.new()
#	if !dir.dir_exists(PlayerVars.CARD_LOAD_DIR):
#		dir.make_dir_recursive(PlayerVars.CARD_LOAD_DIR)
#		return {}
	if !save_dir:
		if dir.file_exists(PlayerVars.CARD_LOAD_DIR + card_name + ".crd"):
			var file:File = File.new()
			var error = file.open(PlayerVars.CARD_LOAD_DIR + card_name + ".crd", File.READ)
			if error == OK:
				var card_data:Dictionary = file.get_var()
	#			load_card(card_data)
				file.close()
				return card_data
			else:
				file.close()
		elif dir.file_exists(card_name):
			var file:File = File.new()
			var error = file.open(card_name, File.READ)
			if error == OK:
				var card_data:Dictionary = file.get_var()
				file.close()
				return card_data
			else:
				file.close()
	else:
		if dir.file_exists(PlayerVars.CARD_SAVE_DIR + card_name + ".crd"):
			var file:File = File.new()
			var error = file.open(PlayerVars.CARD_SAVE_DIR + card_name + ".crd", File.READ)
			if error == OK:
				var card_data:Dictionary = file.get_var()
	#			load_card(card_data)
				file.close()
				return card_data
			else:
				file.close()
		elif dir.file_exists(card_name):
			var file:File = File.new()
			var error = file.open(card_name, File.READ)
			if error == OK:
				var card_data:Dictionary = file.get_var()
				file.close()
				return card_data
			else:
				file.close()
	return {}

func getCardFileDirectory(card_name:String) -> String:
	var dir = Directory.new()
	if dir.file_exists(PlayerVars.CARD_LOAD_DIR + card_name + ".crd"):
		var file:File = File.new()
		var error = file.open(PlayerVars.CARD_LOAD_DIR + card_name + ".crd", File.READ)
		if error == OK:
			file.close()
			return PlayerVars.CARD_LOAD_DIR
	if dir.file_exists(PlayerVars.CARD_SAVE_DIR + card_name + ".crd"):
		var file:File = File.new()
		var error = file.open(PlayerVars.CARD_SAVE_DIR + card_name + ".crd", File.READ)
		if error == OK:
			file.close()
			return PlayerVars.CARD_SAVE_DIR
		else:
			file.close()
	return ""

#"name": name,
#		"type": type,
#		"slot": slot,
#		"is_two_handed": is_two_handed,
#		"rarity": rarity,
#		"texture": texture,
#		"base_damage": base_damage,
#		"base_ap": base_ap,
#		"inscriptions": inscriptions,
#		"offense_tier1": offense_tier1,
#		"offense_tier2": offense_tier2,
#		"offense_tier3": offense_tier3,
#		"offense_tier4": offense_tier4,
#		"defense_tier1": defense_tier1,
#		"defense_tier2": defense_tier2,
#		"defense_tier3": defense_tier3,
#		"defense_tier4": defense_tier4,
#		"utility_tier1": utility_tier1,
#		"utility_tier2": utility_tier2,
#		"utility_tier3": utility_tier3,
#		"utility_tier4": utility_tier4
func combineCardItem(card_data:Dictionary, item_data:Dictionary) -> Dictionary:
	#var card_data = card.duplicate()
	#var item_data = item.duplicate()
	var ignore_item:bool = card_data.ignore_item_stats
	
	var data = {
		"card_id": card_data.card_id, #
		"unique_id": card_data.unique_id, #
		"card_name": card_data.card_name, #
		"item": item_data, #
		#"card_owner": card_data.card_owner, #
		"card_class": card_data.card_class, #
		"action_costs": card_data.action_costs,
		"card_level": card_data.card_level, #
		"upgrade_costs": card_data.upgrade_costs, #
		"card_art": card_data.card_art, #
		"card_icon": card_data.card_icon, #
		"card_type": card_data.card_type, #
		"item_type": card_data.item_type, #
		
		"can_attack": card_data.can_attack,
		"can_defend": card_data.can_defend,
		"need_los": card_data.need_los,
		"is_homing": card_data.is_homing,
		"has_combo": card_data.has_combo,
		"is_piercing": card_data.is_piercing,
		"is_shattering": card_data.is_shattering,
		"is_consumable": card_data.is_consumable,
		"has_counter": card_data.has_counter,
		"has_reflex": card_data.has_reflex,
		"self_eliminating": card_data.self_eliminating,
		"hexagonal_targeting": card_data.hexagonal_targeting,
		"self_statuses": card_data.self_statuses,
		"target_statuses": card_data.target_statuses,
		"prerequisites": card_data.prerequisites,
		"delay": card_data.delay,
		"rarity": card_data.rarity,
		"description": card_data.description,
		"card_min_range": card_data.card_min_range,
		"card_max_range": card_data.card_max_range,
		"card_up_vertical_range": card_data.card_up_vertical_range,
		"card_down_vertical_range": card_data.card_down_vertical_range,
		"card_attack": card_data.card_attack,
		"card_added_accuracy": card_data.card_added_accuracy,
		"card_added_crit_accuracy": card_data.card_added_crit_accuracy,
#		"card_caster": card_caster,
#		"source_cell": source_cell,
#		"target_unit": target_unit,
#		"target_cell": target_cell,
		"card_animation": card_data.card_animation,
		"card_animation_left_weapon": card_data.card_animation_left_weapon,
		"card_animation_right_weapon": card_data.card_animation_right_weapon,
		"card_animation_projectile": card_data.card_animation_projectile,
		"bypass_popup": card_data.bypass_popup,
		#"ignore_item_stats": card_data.ignore_item_stats,
		"elements": card_data.elements,
		#"behavior_trees": card_data.behavior_trees,
		"original_card_values": card_data
	}
	if item_data.base_ap != null:
		if ignore_item:
			data.action_costs = card_data.action_costs
		else:
			for i in data.action_costs.size():
				data.action_costs[i] += item_data.base_ap
	if item_data.base_damage != null:
		if ignore_item:
			data.card_attack = card_data.card_attack
		else:
			for i in data.card_attack.size():
				data.card_attack[i] *= item_data.base_damage
				data.card_attack[i] = round(data.card_attack[i])
	if item_data.inscriptions.has("can_attack"):
		data.can_attack = card_data.can_attack if ignore_item else item_data.can_attack
	if item_data.inscriptions.has("can_defend"):
		data.can_defend = card_data.can_defend if ignore_item else item_data.can_defend
	if item_data.inscriptions.has("need_los"):
		data.need_los = card_data.need_los if ignore_item else item_data.need_los
	if item_data.inscriptions.has("is_homing"):
		data.is_homing = card_data.is_homing if ignore_item else item_data.is_homing
	if item_data.inscriptions.has("has_combo"):
		data.has_combo = card_data.has_combo if ignore_item else item_data.has_combo
	if item_data.inscriptions.has("is_piercing"):
		data.is_piercing = card_data.is_piercing if ignore_item else item_data.is_piercing
	if item_data.inscriptions.has("is_shattering"):
		data.is_shattering = card_data.is_shattering if ignore_item else item_data.is_shattering
	if item_data.inscriptions.has("is_consumable"):
		data.is_consumable = card_data.is_consumable if ignore_item else item_data.is_consumable
	if item_data.inscriptions.has("has_counter"):
		data.has_counter = card_data.has_counter if ignore_item else item_data.has_counter
	if item_data.inscriptions.has("has_reflex"):
		data.has_reflex = card_data.has_reflex if ignore_item else item_data.has_reflex
	if item_data.inscriptions.has("self_eliminating"):
		data.self_eliminating = card_data.self_eliminating if ignore_item else item_data.self_eliminating
	if item_data.inscriptions.has("hexagonal_targeting"):
		data.hexagonal_targeting = card_data.hexagonal_targeting if ignore_item else item_data.hexagonal_targeting
	if item_data.inscriptions.has("self_statuses"):
		data.self_statuses = card_data.self_statuses if ignore_item else item_data.self_statuses
	if item_data.inscriptions.has("target_statuses"):
		data.target_statuses = card_data.target_statuses if ignore_item else item_data.target_statuses
	if item_data.inscriptions.has("prerequisites"):
		data.prerequisites = card_data.prerequisites if ignore_item else item_data.prerequisites
	if item_data.inscriptions.has("delay"):
		data.delay = card_data.delay if ignore_item else item_data.delay
	if item_data.inscriptions.has("card_min_range"):
		data.card_min_range = card_data.card_min_range if ignore_item else item_data.card_min_range
	if item_data.inscriptions.has("card_max_range"):
		data.card_max_range = card_data.card_max_range if ignore_item else item_data.card_max_range
	if item_data.inscriptions.has("card_up_vertical_range"):
		data.card_up_vertical_range = card_data.card_up_vertical_range if ignore_item else item_data.card_up_vertical_range
	if item_data.inscriptions.has("card_down_vertical_range"):
		data.card_down_vertical_range = card_data.card_down_vertical_range if ignore_item else item_data.card_down_vertical_range
	if item_data.inscriptions.has("card_added_accuracy"):
		data.card_added_accuracy = card_data.card_added_accuracy if ignore_item else item_data.card_added_accuracy
	if item_data.inscriptions.has("card_added_crit_accuracy"):
		data.card_added_crit_accuracy = card_data.card_added_crit_accuracy if ignore_item else item_data.card_added_crit_accuracy
	if item_data.inscriptions.has("card_animation"):
		data.card_animation = card_data.card_animation if ignore_item else item_data.card_animation
	if item_data.inscriptions.has("card_animation_left_weapon"):
		data.card_animation_left_weapon = card_data.card_animation_left_weapon if ignore_item else item_data.card_animation_left_weapon
	if item_data.inscriptions.has("card_animation_right_weapon"):
		data.card_animation_right_weapon = card_data.card_animation_right_weapon if ignore_item else item_data.card_animation_right_weapon
	if item_data.inscriptions.has("card_animation_projectile"):
		data.card_animation_projectile = card_data.card_animation_projectile if ignore_item else item_data.card_animation_projectile
	if item_data.inscriptions.has("bypass_popup"):
		data.bypass_popup = card_data.bypass_popup if ignore_item else item_data.bypass_popup
	if item_data.inscriptions.has("elements"):
		data.elements = card_data.elements if ignore_item else item_data.elements
	return data
