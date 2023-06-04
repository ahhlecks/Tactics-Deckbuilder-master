extends Node

var ENEMY_UNIT_LOAD_DIR:String = "res://data/units/enemy/"
var ENEMY_UNIT_LOAD_DIR_:String = "res://data/units/enemy"
var ALLY_UNIT_LOAD_DIR:String = "res://data/units/ally/"
var ALLY_UNIT_LOAD_DIR_:String = "res://data/units/ally"
var ENEMY_UNIT_SAVE_DIR:String = "user://units/enemy/"
var ENEMY_UNIT_SAVE_DIR_:String = "user://units/enemy"
var ALLY_UNIT_SAVE_DIR:String = "user://units/ally/"
var ALLY_UNIT_SAVE_DIR_:String = "user://units/ally"
#var PLAYER_UNIT_LIST_FILE:String = "player_units.dat"#
#var UNIT_LIST_FILE:String = "unit_list.dat"#
var DELETED_DIR:String = "res://data/deleted/"

var CARD_LOAD_DIR:String = "res://data/cards/"
var CARD_LOAD_DIR_:String = "res://data/cards"
var CARD_SAVE_DIR:String = "user://cards/"
var CARD_SAVE_DIR_:String = "user://cards"
var CARD_LIST_FILE:String = "card_list.dat"#

var CARD_ART_DIR:String = "res://assets/images/card_art/"

var MAP_LOAD_DIR:String = "res://data/maps/"
var MAP_LOAD_DIR_:String = "res://data/maps"
var MAP_SAVE_DIR:String = "user://maps/"
var MAP_SAVE_DIR_:String = "user://maps"

var EQUIPMENT_LOAD_DIR:String = "res://data/equipment/"

var PLAYER_SAVE_DIR:String = "user://player_data/"
var PLAYER_LOAD_DIR:String = "res://data/player_data/"
var player_name = "Player1"

var file:File = File.new()
var save_name:String = "Slot 1"
var start_date_time = ""
var version = ""
var missions:Array
var gold:int
var units:Array
var inventory:Array

func save_exists() -> bool:
	return file.file_exists(PLAYER_SAVE_DIR+"\""+save_name)

func new_save() -> void:
	start_date_time = Time.get_date_string_from_system()
	
	version = ""
	if file.open("res://CHANGELOG.md", File.READ) == OK:
		var content:String = file.get_as_text()
		version = content.substr(content.find("##") + 4,5)
	
	var error = file.open_encrypted_with_pass(PLAYER_SAVE_DIR+start_date_time+save_name,File.WRITE, "09polkmn")
	if error != OK:
		printerr("Could not save the file %s. Aborting load operation. Error code: %s" % [PLAYER_SAVE_DIR+start_date_time+save_name, error])
		return
	
	var data:Dictionary = {
		"save_name": save_name,
		"start_date_time": start_date_time,
		"version": version,
		"missions": missions,
		"gold": gold,
		"units" : units,
		"inventory" : inventory
	}
	
	file.store_var(data)
	file.close()
#	var json_string = JSON.print(data)
#	file.store_string(json_string)
#	file.close()

func read_save() -> void:
	var error = file.open_encrypted_with_pass(PLAYER_SAVE_DIR+start_date_time+save_name,File.READ, "09polkmn")
	if error != OK:
		printerr("Could not open the file %s. Aborting load operation. Error code: %s" % [PLAYER_SAVE_DIR+start_date_time+save_name, error])
		return
	
	#var content:String = file.get_as_text()
	var data:Dictionary = file.get_var()
	file.close()
	
	#var data:Dictionary = JSON.parse(content).result
	save_name = data.save_name
	missions = data.missions
	gold = data.gold
	units = data.units
	inventory = data.unventory
	
	
