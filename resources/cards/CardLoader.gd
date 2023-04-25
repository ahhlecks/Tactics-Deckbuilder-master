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

func loadSingleCardFile(card_name:String, save_dir:bool) -> Dictionary:
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
		elif dir.file_exists(PlayerVars.CARD_SAVE_DIR + card_name + ".crd"):
			var file:File = File.new()
			var error = file.open(PlayerVars.CARD_SAVE_DIR + card_name + ".crd", File.READ)
			if error == OK:
				var card_data:Dictionary = file.get_var()
	#			load_card(card_data)
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
		elif dir.file_exists(PlayerVars.CARD_LOAD_DIR + card_name + ".crd"):
			var file:File = File.new()
			var error = file.open(PlayerVars.CARD_LOAD_DIR + card_name + ".crd", File.READ)
			if error == OK:
				var card_data:Dictionary = file.get_var()
	#			load_card(card_data)
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
