extends Control

class_name UnitMaker

const UNIT_SAVE_DIR:String = "user://units/"
var unit_list_file:String = "player_units.dat"

const CARD_SAVE_DIR:String = "user://cards/"
var card_list_file:String = "card_list.dat"
const CARD_ART_DIR:String = "res://assets/images/card_art/"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#onready var hexGrid = get_node("../../HexGrid")
onready var vbox = get_node("Stats/HBoxContainer/VBoxContainer")
onready var stats_box = get_node("Stats")
onready var update_unit_node = get_node("Stats/HBoxContainer/VBoxContainer/UpdateUnit/UpdateUnit")
onready var update_label = get_node("Stats/HBoxContainer/VBoxContainer/UpdateUnit/Updated")
onready var owned_button = get_node("Units/VBoxContainer/HBoxContainer/Owned")
onready var unit_cards = get_node("Stats/HBoxContainer/VBoxContainer2/Cards/Cards/VBoxContainer")
onready var team_value = get_node("Stats/HBoxContainer/VBoxContainer/Team/TeamValue")

# List of all the saved units in data
var unit_list:Array = []

var current_unit:Dictionary = {}
var id:String = ""
var last_button:Button
#var current_selection:int
var list_dir:String = "ally"
#
var unit_name:String = "TestUnit"
var team:int = 0
##var alliance:int = 0
var unit_class:int = 0
var unit_class_name:String = "Warrior"
#var bio:String = "Bio"
var current_health:int = 30
var max_health:int = 30
#var is_alive:bool = true
#var is_casting:bool = false
#var current_action_points:int = 0
var max_action_points:int = 4
var base_action_points_regen:int = 2
var current_action_points_regen:int = 2
var current_movement_points:int = 2
var max_movement_points:int = 2
var current_jump_points:int = 2
var max_jump_points:int = 2
var base_speed:float = 4
var current_speed:float
var base_physical_accuracy:float = 100
var current_physical_accuracy:float = 100
var base_magic_accuracy:float = 100
var current_magic_accuracy:float = 100
var base_physical_evasion:float = 5
var current_physical_evasion:float = 5
var base_magic_evasion:float = 5
var current_magic_evasion:float = 5
var base_draw_points:int = 4
var current_draw_points:int = 4
var base_crit_damage:int = 50
var current_crit_damage:int = 50
var base_crit_chance:int = 0
var current_crit_chance:int = 0
var base_crit_evasion:int = 0
var current_crit_evasion:int = 0
var experience:int = 0
var level:int = 1
#var block:int = 0
#var deflect:int = 0
#var strength:int = 0
#var willpower:int = 0
#var traits:Array
#var statuses:Array
var deck:Array = []
var proficiencies:Array = []
var player_owned:bool = true
#var is_ai_controlled:bool = false
var ai_type:int = 0
#
#var unit_prefab:HexUnit



# Called when the node enters the scene tree for the first time.
func _ready():
#	unit_prefab = HexUnit.new()
	clear()
	yield(get_tree().create_timer(1),"timeout")
	yield(get_tree(),"idle_frame")
	$Stats.visible = false
	$MenuControl/CardEditor.visible = false
	$MenuControl/TestMap.visible = false
	update_label.modulate.a = 0
	intializeList()
	intializeCardList()
	get_tree().get_root().connect("size_changed", self, "update_position")
	update_position()

func menuReady():
	$Units.visible = true
	$Stats.visible = false
	$Stats/HBoxContainer/VBoxContainer/AIControlled/AIControlled.pressed = false
	$Stats/HBoxContainer/VBoxContainer/Name/NameEdit.editable = true
	$Stats/HBoxContainer/VBoxContainer/AIType.visible = true
	$Stats/HBoxContainer/VBoxContainer/UpdateUnit.visible = true

func update_position():
	rect_size = get_viewport().size
	$BG.rect_size = rect_size
	$MenuControl.rect_position = Vector2(rect_size.x - $MenuControl.rect_size.x, 0)

func testUnit():
	_on_Owned_toggled(true)
	id = "28876951158a8636595733d405cbdbccd9defc6440c956ee6dd92ceb792c0510"
#	unit_prefab.loadData(UnitLoader.loadSingleAllyUnitFile(id,true))
	update_fields(UnitLoader.loadSingleAllyUnitFile(id,true),true)
	$MenuControl/CardEditor.visible = true
	$MenuControl/TestMap.visible = true
	$Units.visible = false
	$Stats.visible = true
	$Stats/HBoxContainer/VBoxContainer/AIControlled/AIControlled.pressed = true
	$Stats/HBoxContainer/VBoxContainer/Name/NameEdit.editable = false
	$Stats/HBoxContainer/VBoxContainer/AIType.visible = true
	$Stats/HBoxContainer/VBoxContainer/UpdateUnit.visible = false

func _input(event):
	pass
#	if event is InputEventKey and event .scancode == KEY_ESCAPE:
#		get_tree().quit()

func update_fields(unit:Dictionary, ally:bool = true):
	current_unit = unit
	makeVisible(true)
#	if ally:
#		if !UnitLoader.loadSingleAllyUnitFile(unit.id, true).empty():
#			unit_prefab.loadData(UnitLoader.loadSingleAllyUnitFile(unit.id, true))
#	else:
#		if !UnitLoader.loadSingleEnemyUnitFile(unit.id).empty():
#			unit_prefab.loadData(UnitLoader.loadSingleEnemyUnitFile(unit.id, true))
	vbox.get_node("Name/NameEdit").text = unit.unit_name
	vbox.get_node("Bio/BioText").text = unit.bio
	vbox.get_node("Team/TeamValue").value = unit.team
	vbox.get_node("Class/OptionButton").selected = unit.unit_class
	vbox.get_node("MaxHealthPoints/HealthValue").value = unit.max_health
	vbox.get_node("MaxAP/APValue").value = unit.max_action_points
	vbox.get_node("MaxMovementPoints/MovementPointsValue").value = unit.max_movement_points
	vbox.get_node("MaxJumpPoints/JumpPointsValue").value = unit.max_jump_points
	vbox.get_node("UnitBaseSpeed/UnitBaseSpeedValue").value = unit.base_speed
	vbox.get_node("BasePhysicalEvasion/BasePhysicalEvasionValue").value = unit.base_physical_evasion
	vbox.get_node("BaseMagicEvasion/BaseMagicEvasionValue").value = unit.base_magic_evasion
	vbox.get_node("MaxDrawPoints/DrawPointsValue").value = unit.base_draw_points
	vbox.get_node("BaseCritDamage/BaseCritDamageValue").value = unit.base_crit_damage
	vbox.get_node("BaseCritChance/BaseCritChanceValue").value = unit.base_crit_chance
	vbox.get_node("BaseCritEvasion/BaseCritEvasionValue").value = unit.base_crit_evasion
	vbox.get_node("Experience/ExperienceValue").value = unit.experience
	vbox.get_node("Level/LevelValue").value = unit.level
	vbox.get_node("AIControlled/AIControlled").pressed = unit.is_ai_controlled
	intializeUnitCardList(unit)
	intializeUnitProficienciesList(unit)
#	vbox.get_node("CurrentSpeed").text = "Current Speed: " + str(getUnitSpeed(unit.base_speed, unit))
#	vbox.get_node("DeckSpeed").text = "Deck Speed: " + str(getDeckSpeed(unit))


func updateUnit() -> Dictionary:
#	unit_prefab.id = id
#	unit_prefab.unit_name = vbox.get_node("Name/NameEdit").text
#	unit_prefab.team = vbox.get_node("Team/TeamValue").value
#	unit_prefab.unit_class = vbox.get_node("Class/OptionButton").selected
#	unit_prefab.unit_class_name = unit_class_name
#	unit_prefab.bio = vbox.get_node("Bio/BioText").text
#	unit_prefab.current_health = vbox.get_node("MaxHealthPoints/HealthValue").value
#	unit_prefab.max_health = vbox.get_node("MaxHealthPoints/HealthValue").value
#	unit_prefab.current_action_points = 0
#	unit_prefab.max_action_points = vbox.get_node("MaxAP/APValue").value
#	unit_prefab.base_action_points_regen = vbox.get_node("APRegen/APRegenValue").value
#	unit_prefab.current_action_points_regen = vbox.get_node("APRegen/APRegenValue").value
#	unit_prefab.current_movement_points = vbox.get_node("MaxMovementPoints/MovementPointsValue").value
#	unit_prefab.max_movement_points = vbox.get_node("MaxMovementPoints/MovementPointsValue").value
#	unit_prefab.current_jump_points = vbox.get_node("MaxJumpPoints/JumpPointsValue").value
#	unit_prefab.max_jump_points = vbox.get_node("MaxJumpPoints/JumpPointsValue").value
#	unit_prefab.base_speed = vbox.get_node("UnitBaseSpeed/UnitBaseSpeedValue").value
#	unit_prefab.base_physical_accuracy = vbox.get_node("BasePhysicalAccuracy/BasePhysicalAccuracyValue").value
#	unit_prefab.current_physical_accuracy = vbox.get_node("BasePhysicalAccuracy/BasePhysicalAccuracyValue").value
#	unit_prefab.base_magic_accuracy = vbox.get_node("BaseMagicAccuracy/BaseMagicAccuracyValue").value
#	unit_prefab.current_magic_accuracy = vbox.get_node("BaseMagicAccuracy/BaseMagicAccuracyValue").value
#	unit_prefab.base_physical_evasion = vbox.get_node("BasePhysicalEvasion/BasePhysicalEvasionValue").value
#	unit_prefab.current_physical_evasion = vbox.get_node("BasePhysicalEvasion/BasePhysicalEvasionValue").value
#	unit_prefab.base_magic_evasion = vbox.get_node("BaseMagicEvasion/BaseMagicEvasionValue").value
#	unit_prefab.current_magic_evasion = vbox.get_node("BaseMagicEvasion/BaseMagicEvasionValue").value
#	unit_prefab.base_draw_points = vbox.get_node("MaxDrawPoints/DrawPointsValue").value
#	unit_prefab.current_draw_points = vbox.get_node("MaxDrawPoints/DrawPointsValue").value
#	unit_prefab.base_crit_damage = vbox.get_node("BaseCritDamage/BaseCritDamageValue").value
#	unit_prefab.current_crit_damage = vbox.get_node("BaseCritDamage/BaseCritDamageValue").value
#	unit_prefab.base_crit_chance = vbox.get_node("BaseCritChance/BaseCritChanceValue").value
#	unit_prefab.current_crit_chance = vbox.get_node("BaseCritChance/BaseCritChanceValue").value
#	unit_prefab.experience = vbox.get_node("Experience/ExperienceValue").value
#	unit_prefab.level = vbox.get_node("Level/LevelValue").value
#	unit_prefab.block = block
#	unit_prefab.deflect = deflect
#	unit_prefab.strength = strength
#	unit_prefab.willpower = willpower
#	unit_prefab.player_owned = player_owned
#	unit_prefab.is_ai_controlled = vbox.get_node("AIControlled/AIControlled").pressed
#	unit_prefab.ai_type = ai_type
##	unit_prefab.deck = deck
##	unit_prefab.proficiencies = proficiencies
#	unit_prefab.current_speed = unit_prefab.getUnitSpeed()
#	vbox.get_node("CurrentSpeed").text = "Current Speed: " + str(unit_prefab.current_speed)
#	vbox.get_node("DeckSpeed").text = "Deck Speed: " + str(unit_prefab.getDeckSpeed())
	var unit = {
		"id" : id,
		"unit_name" : vbox.get_node("Name/NameEdit").text,
		"team" : vbox.get_node("Team/TeamValue").value,
		"unit_class" : vbox.get_node("Class/OptionButton").selected,
		"unit_class_name" : BattleDictionary.job_list[vbox.get_node("Class/OptionButton").selected],
		"bio": vbox.get_node("Bio/BioText").text,
		"current_health" : vbox.get_node("MaxHealthPoints/HealthValue").value,
		"max_health" : vbox.get_node("MaxHealthPoints/HealthValue").value,
		"current_action_points" : 0,
		"max_action_points" : vbox.get_node("MaxAP/APValue").value,
		"base_action_points_regen" : vbox.get_node("APRegen/APRegenValue").value,
		"current_action_points_regen" : vbox.get_node("APRegen/APRegenValue").value,
		"current_movement_points" : vbox.get_node("MaxMovementPoints/MovementPointsValue").value,
		"max_movement_points" : vbox.get_node("MaxMovementPoints/MovementPointsValue").value,
		"current_jump_points" : vbox.get_node("MaxJumpPoints/JumpPointsValue").value,
		"max_jump_points" : vbox.get_node("MaxJumpPoints/JumpPointsValue").value,
		"base_speed" : vbox.get_node("UnitBaseSpeed/UnitBaseSpeedValue").value,
		"base_physical_accuracy" : vbox.get_node("BasePhysicalAccuracy/BasePhysicalAccuracyValue").value,
		"current_physical_accuracy" : vbox.get_node("BasePhysicalAccuracy/BasePhysicalAccuracyValue").value,
		"base_magic_accuracy" : vbox.get_node("BaseMagicAccuracy/BaseMagicAccuracyValue").value,
		"current_magic_accuracy" : vbox.get_node("BaseMagicAccuracy/BaseMagicAccuracyValue").value,
		"base_physical_evasion" : vbox.get_node("BasePhysicalEvasion/BasePhysicalEvasionValue").value,
		"current_physical_evasion" : vbox.get_node("BasePhysicalEvasion/BasePhysicalEvasionValue").value,
		"base_magic_evasion" : vbox.get_node("BaseMagicEvasion/BaseMagicEvasionValue").value,
		"current_magic_evasion" : vbox.get_node("BaseMagicEvasion/BaseMagicEvasionValue").value,
		"current_draw_points" : vbox.get_node("MaxDrawPoints/DrawPointsValue").value,
		"base_draw_points" : vbox.get_node("MaxDrawPoints/DrawPointsValue").value,
		"base_crit_damage" : vbox.get_node("BaseCritDamage/BaseCritDamageValue").value,
		"current_crit_damage" : vbox.get_node("BaseCritDamage/BaseCritDamageValue").value,
		"base_crit_chance" : vbox.get_node("BaseCritChance/BaseCritChanceValue").value,
		"current_crit_chance" : vbox.get_node("BaseCritChance/BaseCritChanceValue").value,
		"base_crit_evasion" : vbox.get_node("BaseCritEvasion/BaseCritEvasionValue").value,
		"current_crit_evasion" : vbox.get_node("BaseCritEvasion/BaseCritEvasionValue").value,
		"experience" : vbox.get_node("Experience/ExperienceValue").value,
		"level" : vbox.get_node("Level/LevelValue").value,
		"block" : 0,
		"strength" : 0,
		"willpower" : 0,
		"traits" : [],
		"statuses" : [],
		"player_owned" : player_owned,
		"is_ai_controlled" : vbox.get_node("AIControlled/AIControlled").pressed,
		"ai_type" : ai_type,
		"deck" : current_unit.deck,
		"proficiencies" : current_unit.proficiencies
	}
	return unit


func _on_UpdateUnit_pressed():
	id = current_unit.id
	current_unit = updateUnit()
	saveUserUnitList()


func saveUserUnitList():
#	print(unit_prefab)
#	print(unit_prefab.save())
#	var data = unit_prefab.save()
	if list_dir == "ally":
		var file:File = File.new()
		var error = file.open(PlayerVars.ALLY_UNIT_SAVE_DIR + str(current_unit.id) + ".dat", File.WRITE)
		if error == OK:
			file.store_var(current_unit)
			file.close()
		error = file.open(PlayerVars.ALLY_UNIT_LOAD_DIR + str(current_unit.id) + ".dat", File.WRITE)
		if error == OK:
			file.store_var(current_unit)
			file.close()
			intializeList()
			file.call_deferred("queue_free")
	if list_dir == "enemy":
		var file:File = File.new()
		var error = file.open(PlayerVars.ENEMY_UNIT_SAVE_DIR + str(current_unit.id) + ".dat", File.WRITE)
		if error == OK:
			file.store_var(current_unit)
			file.close()
		error = file.open(PlayerVars.ENEMY_UNIT_LOAD_DIR + str(current_unit.id) + ".dat", File.WRITE)
		if error == OK:
			file.store_var(current_unit)
			file.close()
			intializeList()
			file.call_deferred("queue_free")
	UI_Sounds.createSound(UI_Sounds.unit_create)
	var tween = get_node("Stats/HBoxContainer/VBoxContainer/UpdateUnit/Tween")
	tween.interpolate_property(update_label,"modulate:a",0,1, .8, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_completed")
	tween.interpolate_property(update_label,"modulate:a",1,0, .8, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.start()


func _on_NameEdit_text_changed(new_text):
	unit_name = new_text


func _on_TeamValue_value_changed(value):
	team = value


# warning-ignore:shadowed_variable
func _on_OptionButton_item_selected(index):
	unit_class = index
	unit_class_name = get_node("Stats/HBoxContainer/VBoxContainer/Class/OptionButton").get_item_text(index)


func _on_JobOptionButton_item_selected(index):
	match index:
		0,1,2,3:
			$Stats/HBoxContainer/VBoxContainer/Class/OptionButton.select(0)
		4,5,6,7:
			$Stats/HBoxContainer/VBoxContainer/Class/OptionButton.select(1)
		8,9,10,11:
			$Stats/HBoxContainer/VBoxContainer/Class/OptionButton.select(2)
	match index:
		0:
			max_health = 80
			current_health = 80
			$Stats/HBoxContainer/VBoxContainer/MaxHealthPoints/HealthValue.value = 80
			base_speed = 6
			$Stats/HBoxContainer/VBoxContainer/UnitBaseSpeed/UnitBaseSpeedValue.value = 6


func _on_HealthValue_value_changed(value):
	max_health = value
	current_health = value


func _on_APValue_value_changed(value):
	max_action_points = value


func _on_APRegenValue_value_changed(value):
	base_action_points_regen = value
	current_action_points_regen = value


func _on_MovementPointsValue_value_changed(value):
	max_movement_points = value
	current_movement_points = value


func _on_JumpPointsValue_value_changed(value):
	max_jump_points = value
	current_jump_points = value


func _on_UnitBaseSpeedValue_value_changed(value):
	base_speed = value


func _on_BasePhysicalAccuracyValue_value_changed(value):
	base_physical_accuracy = value
	current_physical_accuracy = value


func _on_BaseMagicAccuracyValue_value_changed(value):
	base_magic_accuracy = value
	current_magic_accuracy = value


func _on_BasePhysicalEvasionValue_value_changed(value):
	base_physical_evasion = value
	current_physical_evasion = value


func _on_BaseMagicEvasionValue_value_changed(value):
	base_magic_evasion = value
	current_magic_evasion = value


func _on_DrawPointsValue_value_changed(value):
	base_draw_points = value
	current_draw_points = value


func _on_BaseCritDamageValue_value_changed(value):
	base_crit_damage = value
	current_crit_damage = value

func _on_BaseCritChanceValue_value_changed(value):
	base_crit_chance = value
	current_crit_chance = value

func _on_BaseCritEvasionValue_value_changed(value):
	base_crit_evasion = value
	current_crit_evasion = value

func _on_LevelValue_value_changed(value):
	level = value


func _on_ExperienceValue_value_changed(value):
	experience = value


func _on_AIControlled_toggled(button_pressed):
	get_node("Stats/HBoxContainer/VBoxContainer/AIType").visible = button_pressed


func _on_AIType_item_selected(index):
	ai_type = index


func clearList():
	for buttons in get_node("Units/VBoxContainer/Units/VBoxContainer").get_children():
		get_node("Units/VBoxContainer/Units/VBoxContainer").remove_child(buttons)
		buttons.call_deferred("queue_free")
	unit_list = []

func intializeList():
	clearList()
	var unit_list:Array
	if list_dir == "ally":
		unit_list = UnitLoader.loadAllyUnitList(true)
		if unit_list != null and unit_list.size() > 0:
			for unit in unit_list:
				var unit_data:Dictionary = UnitLoader.loadSingleAllyUnitFile(unit,true)
				var new_button = Button.new()
				new_button.text = unit_data.unit_name
				new_button.size_flags_horizontal = SIZE_EXPAND_FILL
				new_button.align = new_button.ALIGN_LEFT
				new_button.clip_text = true
				new_button.toggle_mode = false
#				new_button.hint_tooltip = unit_data.id
				get_node("Units/VBoxContainer/Units/VBoxContainer").add_child(new_button)
#				if unit_data.unit_name.to_lower().begins_with("testunit"):
#					new_button.disabled = true
				new_button.connect("pressed",self,"update_fields",[unit_data.duplicate(true), true])
	if list_dir == "enemy":
		unit_list = UnitLoader.loadEnemyUnitList(true)
		if unit_list != null and unit_list.size() > 0:
			for unit in unit_list:
				var unit_data:Dictionary = UnitLoader.loadSingleEnemyUnitFile(unit,true)
				var new_button = Button.new()
				new_button.text = unit_data.unit_name
				new_button.size_flags_horizontal = SIZE_EXPAND_FILL
				new_button.align = new_button.ALIGN_LEFT
				new_button.clip_text = true
				new_button.toggle_mode = false
#				new_button.hint_tooltip = unit_data.id
				get_node("Units/VBoxContainer/Units/VBoxContainer").add_child(new_button)
#				if unit_data.unit_name.to_lower().begins_with("testunit"):
#					new_button.disabled = true
				new_button.connect("pressed",self,"update_fields",[unit_data.duplicate(true), false])


func defaultUnit(id = null) -> Dictionary:
	var default_unit = {
		"id" : id,
		"unit_name" : "New Unit",
		"team" : int(!player_owned),
		"unit_class" : 0,
		"unit_class_name" : "Warrior",
		"bio": "Bio",
		"current_health" : 30,
		"max_health" : 30,
		"current_action_points" : 0,
		"max_action_points" : 4,
		"base_action_points_regen" : 2,
		"current_action_points_regen" : 2,
		"current_movement_points" : 2,
		"max_movement_points" : 2,
		"current_jump_points" : 2,
		"max_jump_points" : 2,
		"base_speed" : 4,
		"base_physical_accuracy" : 100,
		"current_physical_accuracy" : 100,
		"base_magic_accuracy" : 100,
		"current_magic_accuracy" : 100,
		"base_physical_evasion" : 5,
		"current_physical_evasion" : 5,
		"base_magic_evasion" : 5,
		"current_magic_evasion" : 5,
		"current_draw_points" : 4,
		"base_draw_points" : 4,
		"base_crit_damage" : 50,
		"current_crit_damage" : 50,
		"base_crit_chance" : 0,
		"current_crit_chance" : 0,
		"base_crit_evasion" : 0,
		"current_crit_evasion" : 0,
		"experience" : 0,
		"level" : 1,
		"block" : 0,
		"strength" : 0,
		"willpower" : 0,
		"traits" : [],
		"statuses" : [],
		"player_owned" : player_owned,
		"is_ai_controlled" : !player_owned,
		"ai_type" : 0,
		"deck" : [],
		"proficiencies" : []
	}
	return default_unit

#func data_to_unit(data:Dictionary) -> HexUnit:
##	unit_prefab.index = data.get("index")
#	unit_prefab.unit_name = data.get("unit_name")
#	unit_prefab.team = data.get("team")
#	unit_prefab.unit_class = data.get("unit_class")
#	unit_prefab.unit_class_name = data.get("unit_class_name")
#	unit_prefab.bio = data.get("bio")
#	unit_prefab.current_health = data.get("current_health")
#	unit_prefab.max_health = data.get("max_health")
#	unit_prefab.current_action_points = 0
#	unit_prefab.max_action_points = data.get("max_action_points")
#	unit_prefab.base_action_points_regen = data.get("base_action_points_regen")
#	unit_prefab.current_action_points_regen = data.get("current_action_points_regen")
#	unit_prefab.current_movement_points = data.get("current_movement_points")
#	unit_prefab.max_movement_points = data.get("max_movement_points")
#	unit_prefab.current_jump_points = data.get("current_jump_points")
#	unit_prefab.max_jump_points = data.get("max_jump_points")
#	unit_prefab.base_speed = data.get("base_speed")
#	unit_prefab.base_physical_accuracy = data.get("base_physical_accuracy")
#	unit_prefab.current_physical_accuracy = data.get("current_physical_accuracy")
#	unit_prefab.base_magic_accuracy = data.get("base_magic_accuracy")
#	unit_prefab.current_magic_accuracy = data.get("current_magic_accuracy")
#	unit_prefab.base_physical_evasion = data.get("base_physical_evasion")
#	unit_prefab.current_physical_evasion = data.get("base_physical_evasion")
#	unit_prefab.base_magic_evasion = data.get("base_magic_evasion")
#	unit_prefab.current_magic_evasion = data.get("base_magic_evasion")
#	unit_prefab.base_draw_points = data.get("base_draw_points")
#	unit_prefab.current_draw_points = data.get("current_draw_points")
#	unit_prefab.base_crit_damage = data.get("base_crit_damage")
#	unit_prefab.current_crit_damage = data.get("current_crit_damage")
#	unit_prefab.base_crit_chance = data.get("base_crit_chance")
#	unit_prefab.current_crit_chance = data.get("current_crit_chance")
#	unit_prefab.experience = data.get("experience")
#	unit_prefab.level = data.get("level")
#	unit_prefab.block = data.get("block")
#	unit_prefab.deflect = data.get("deflect")
#	unit_prefab.strength = data.get("strength")
#	unit_prefab.willpower = data.get("willpower")
#	unit_prefab.traits = data.get("traits")
#	unit_prefab.statuses = data.get("statuses")
#	unit_prefab.player_owned = data.get("player_owned")
#	unit_prefab.is_ai_controlled = data.get("is_ai_controlled")
#	unit_prefab.ai_type = data.get("ai_type")
#	unit_prefab.deck = data.get("deck")
#	unit_prefab.proficiencies = data.get("proficiencies")
#	return unit_prefab

func unit_to_data(unit:HexUnit) -> Dictionary:
	var save_dict = {
		"index" : unit.index,
		"unit_name" : unit.unit_name,
		"team" : unit.team,
		"unit_class" : unit.unit_class,
		"unit_class_name" : unit.unit_class_name,
		"bio" : unit.bio,
		"current_health" : unit.max_health,
		"max_health" : unit.max_health,
		"current_action_points" : 0,
		"max_action_points" : unit.max_action_points,
		"base_action_points_regen" : unit.base_action_points_regen,
		"current_action_points_regen" : unit.base_action_points_regen,
		"current_movement_points" : unit.max_movement_points,
		"max_movement_points" : unit.max_movement_points,
		"current_jump_points" : unit.max_jump_points,
		"max_jump_points" : unit.max_jump_points,
		"base_speed" : unit.base_speed,
		"base_physical_accuracy" : unit.base_physical_accuracy,
		"current_physical_accuracy" : unit.base_physical_accuracy,
		"base_magic_accuracy" : unit.base_magic_accuracy,
		"current_magic_accuracy" : unit.base_magic_accuracy,
		"base_physical_evasion" : unit.base_physical_evasion,
		"current_physical_evasion" : unit.base_physical_evasion,
		"base_magic_evasion" : unit.base_magic_evasion,
		"current_magic_evasion" : unit.base_magic_evasion,
		"current_draw_points" : unit.base_draw_points,
		"base_draw_points" : unit.base_draw_points,
		"base_crit_damage" : unit.base_crit_damage,
		"current_crit_damage" : unit.current_crit_damage,
		"base_crit_chance" : unit.base_crit_chance,
		"current_crit_chance" : unit.current_crit_chance,
		"base_crit_evasion" : unit.base_crit_evasion,
		"current_crit_evasion" : unit.current_crit_evasion,
		"experience" : unit.experience,
		"level" : unit.level,
		"block" : unit.block,
		#"deflect" : unit.deflect,
		"strength" : unit.strength,
		"willpower" : unit.willpower,
		"traits" : unit.traits,
		"statuses" : unit.statuses,
		"player_owned" : unit.player_owned,
		"is_ai_controlled" : unit.is_ai_controlled,
		"ai_type" : unit.ai_type,
		"deck" : unit.deck,
		"proficiencies" : unit.proficiencies
		}
	return save_dict


func _on_SaveUnit_pressed():
	stats_box.visible = true
	id = str(OS.get_system_time_msecs()).sha256_text()
	current_unit = defaultUnit(id)
	if list_dir == "ally":
		update_fields(defaultUnit(id),true)
	else:
		update_fields(defaultUnit(id),false)



func _on_DeleteUnit_pressed():
	var dialog = get_node("Stats/HBoxContainer/VBoxContainer/UpdateUnit/DeleteUnit/AcceptDialog")
	var delete_button = get_node("Stats/HBoxContainer/VBoxContainer/UpdateUnit/DeleteUnit")
	UI_Sounds.createSound(UI_Sounds.alert)
	dialog.dialog_text = "Are you sure you want to delete " + current_unit.unit_name + "?"
	dialog.popup(delete_button.get_global_rect())


func _on_AcceptDialog_confirmed(): # If you chose to delete the unit
	var dir = Directory.new()
	var removed:bool = false
	if list_dir == "ally":
		if dir.remove(PlayerVars.ALLY_UNIT_SAVE_DIR + current_unit.id + ".dat") == OK:
			removed = true
		if dir.remove(PlayerVars.ALLY_UNIT_LOAD_DIR + current_unit.id + ".dat") == OK:
			removed = true
	if list_dir == "enemy":
		if dir.remove(PlayerVars.ENEMY_UNIT_SAVE_DIR + current_unit.id + ".dat") == OK:
			removed = true
		if dir.remove(PlayerVars.ENEMY_UNIT_LOAD_DIR + current_unit.id + ".dat") == OK:
			removed = true
	if removed:
		UI_Sounds.createSound(UI_Sounds.unit_delete)
		makeVisible(false)
		intializeList()
	dir.call_deferred("queue_free")


func _on_Owned_toggled(button_pressed):
	clearList()
	clearUnitCardList()
	makeVisible(false)
	if button_pressed:
		list_dir = "ally"
		unit_list = UnitLoader.loadAllyUnitList(true)
		player_owned = true
		team = 0
		team_value.value = 0
		vbox.get_node("AIControlled/AIControlled").pressed = false
		vbox.get_node("AIControlled/AIControlled").disabled = false
	else:
		list_dir = "enemy"
		unit_list = UnitLoader.loadEnemyUnitList(true)
		player_owned = false
		team = 1
		team_value.value = 1
		vbox.get_node("AIControlled/AIControlled").pressed = true
		vbox.get_node("AIControlled/AIControlled").disabled = true
	intializeList()

func makeVisible(visibility:bool) -> void:
	if !visibility:
		last_button = null
		stats_box.visible = false
#		if get_node("../UI/HBox3") != null:
#			get_node("../UI/HBox3/AddUnit").visible = false
#			get_node("../UI/HBox3/DeleteUnit").visible = false
	else:
		stats_box.visible = true
#		if get_node("../UI/HBox3") != null:
#			get_node("../UI/HBox3/AddUnit").visible = true
#			get_node("../UI/HBox3/DeleteUnit").visible = true


func getDeckSpeed(unit_data:Dictionary) -> float:
	var deck_AP:float = 0 #Total of all cards AP in unit's deck
	var deck_speed:float = 0
	if unit_data.deck.size() > 0:
		for i in unit_data.deck:
			var action_costs:Array
			if !CardLoader.loadSingleCardFile(i,true).empty():
				action_costs = CardLoader.loadSingleCardFile(i,true).get("action_costs")
			else:
				action_costs = [0,0,0]
			if proficiencies.size() > 0:
				for j in proficiencies:
					if j[0] == i:
						var proficiency_value:float = j[1]
						deck_AP += max(action_costs[proficiency_value-1],1)
			else:
				deck_AP += max(action_costs[0],1)
		if deck_AP == 0:
			deck_AP = 1
		deck_speed = (max_action_points / (deck_AP / current_unit.deck.size())) / 2
	return deck_speed

func getUnitSpeed(speed, unit_data) -> float:
	return speed + getDeckSpeed(unit_data)


#--------CARD STUFF----------#
#
#

func loadCardList():
	var dir = Directory.new()
	if !dir.dir_exists(PlayerVars.CARD_LOAD_DIR):
		dir.make_dir_recursive(PlayerVars.CARD_LOAD_DIR)
	var file:File = File.new()
	var error = file.open(PlayerVars.CARD_LOAD_DIR + PlayerVars.CARD_LIST_FILE, File.READ)
	if error == OK:
		var list = file.get_var()
		file.close()
		file.call_deferred("queue_free")
		dir.call_deferred("queue_free")
		return list
	dir.call_deferred("queue_free")
	return []


func clearCardList():
	for buttons in get_node("WindowDialog/Cards/VBoxContainer").get_children():
		get_node("WindowDialog/Cards/VBoxContainer").remove_child(buttons)
		buttons.call_deferred("queue_free")
	for buttons in get_node("WindowDialog2/Proficiencies/VBoxContainer").get_children():
		get_node("WindowDialog2/Proficiencies/VBoxContainer").remove_child(buttons)
		buttons.call_deferred("queue_free")


func clearUnitCardList():
	for buttons in get_node("Stats/HBoxContainer/VBoxContainer2/Cards/Cards/VBoxContainer").get_children():
		get_node("Stats/HBoxContainer/VBoxContainer2/Cards/Cards/VBoxContainer").remove_child(buttons)
		buttons.call_deferred("queue_free")


func clearUnitProficienciesList():
	for buttons in get_node("Stats/HBoxContainer/VBoxContainer2/Proficiencies/Cards/VBoxContainer").get_children():
		get_node("Stats/HBoxContainer/VBoxContainer2/Proficiencies/Cards/VBoxContainer").remove_child(buttons)
		buttons.call_deferred("queue_free")


func data_to_card(card_name) -> Card:
	var card:Card = Card.new()
	card.loadSingleCardFile(card_name,true)
	return card

func card_to_data(card) -> Dictionary:
	var save_dict = card.save_card()
	return save_dict

func intializeUnitCardList(unit:Dictionary) -> void:
	clearUnitCardList()
	var unit_deck = unit.deck
	for i in range(unit_deck.size()-1,-1,-1):
		var card_data:Dictionary = CardLoader.loadSingleCardFile(unit_deck[i],true)
		if card_data.empty():
			unit_deck.remove(i)
	unit.deck = unit_deck
	if unit_deck.size() > 0:
		for i in unit_deck.size():
			var card_data:Dictionary = CardLoader.loadSingleCardFile(unit_deck[i],true)
			if !card_data.empty():
				var new_button = Button.new()
				new_button.text = card_data.get("card_name")
				new_button.hint_tooltip = "Remove " + card_data.get("card_name") + " from " + unit.unit_name
				new_button.size_flags_horizontal = SIZE_EXPAND_FILL
				new_button.align = new_button.ALIGN_LEFT
				new_button.clip_text = true
				new_button.set_meta("idx",i)
				get_node("Stats/HBoxContainer/VBoxContainer2/Cards/Cards/VBoxContainer").add_child(new_button)
				new_button.connect("pressed",self,"removeCard",[i])
#				new_button.call_deferred("queue_free")


func intializeUnitProficienciesList(unit:Dictionary) -> void:
	clearUnitProficienciesList()
	var unit_profiencies:Array = unit.proficiencies
	for i in range(proficiencies.size()-1,-1,-1):
		var card_data:Dictionary = CardLoader.loadSingleCardFile(proficiencies[i][0],true)
		if card_data.empty():
			unit_profiencies.remove(i)
	unit.proficiencies = unit_profiencies
	if unit_profiencies.size() > 0:
		for i in unit_profiencies.size():
			var new_button = Button.new()
			new_button.text = unit_profiencies[i][0] + " " + str(unit_profiencies[i][1])
			new_button.hint_tooltip = "Remove " + unit_profiencies[i][0] + " proficiency from " + unit.unit_name
			new_button.size_flags_horizontal = SIZE_EXPAND_FILL
			new_button.align = new_button.ALIGN_LEFT
			new_button.clip_text = true
			new_button.set_meta("idx",i)
			get_node("Stats/HBoxContainer/VBoxContainer2/Proficiencies/Cards/VBoxContainer").add_child(new_button)
			new_button.connect("pressed", self, "removeProficiency",[i])
#			new_button.call_deferred("queue_free")


func intializeCardList() -> void:
	clearCardList()
	var card_list = CardLoader.loadCardList(true)
	if card_list != null and card_list.size() > 0:
		for i in card_list.size():
#			var card:Card = Card.new()
			var card = CardLoader.loadSingleCardFile(card_list[i],true)
			var new_HBox = HBoxContainer.new()
			var new_HBox2 = HBoxContainer.new()
			get_node("WindowDialog/Cards/VBoxContainer").add_child(new_HBox)
			get_node("WindowDialog2/Proficiencies/VBoxContainer").add_child(new_HBox2)
			var new_spin = SpinBox.new()
			new_spin.value = 2
			new_spin.min_value = 2
			new_spin.max_value = card.get("upgrade_costs").size() + 1
			new_spin.hint_tooltip = "Card Proficiency"
			var new_button = Button.new()
			new_button.text = "[" + str(i) + "] " + card.get("card_name")
			new_button.hint_tooltip = "Add " + card.get("card_name")
			new_button.size_flags_horizontal = SIZE_EXPAND_FILL
			new_button.align = new_button.ALIGN_LEFT
			new_button.clip_text = true
			var new_button2 = Button.new()
			new_button2.text = "[" + str(i) + "] " + card.get("card_name")
			new_button2.hint_tooltip = "Add " + card.get("card_name") + " proficiency"
			new_button2.size_flags_horizontal = SIZE_EXPAND_FILL
			new_button2.align = new_button.ALIGN_LEFT
			new_button2.clip_text = true
			new_HBox.add_child(new_button)
			new_HBox2.add_child(new_button2)
			if card.get("upgrade_costs").size() > 0:
				new_HBox2.add_child(new_spin)
				new_button2.connect("pressed",self,"addProficiency",[card, new_spin])
			else:
				new_button2.disabled = true
			new_button.connect("pressed",self,"addCard",[card])
#			new_HBox.call_deferred("queue_free")
#			new_HBox2.call_deferred("queue_free")

func addCard(card:Dictionary) -> void:
	current_unit.deck.append(card.get("card_name"))
	var new_button = Button.new()
	new_button.text = card.get("card_name")
	new_button.hint_tooltip = "Remove " + card.get("card_name") + " from " + current_unit.unit_name
	new_button.size_flags_horizontal = SIZE_EXPAND_FILL
	new_button.align = new_button.ALIGN_LEFT
	new_button.clip_text = true
	get_node("Stats/HBoxContainer/VBoxContainer2/Cards/Cards/VBoxContainer").add_child(new_button)
	new_button.connect("pressed", self, "removeCard",[current_unit.deck.size()-1])
#	_on_UpdateUnit_pressed()

func addProficiency(card:Dictionary, plevel) -> void:
	if proficiencies != null:
		for proficiency in proficiencies:
			if proficiency[0] == card.get("card_name") and proficiency[1] == plevel.value:
				return #already has this proficiency card and level, no need for duplicates
			elif proficiency[0] == card.get("card_name"):
				proficiency[1] = plevel.value
#				_on_UpdateUnit_pressed()
				return
	current_unit.proficiencies.append([card.get("card_name"), plevel.value])
	var new_button = Button.new()
	new_button.text = card.get("card_name") + " " + str(plevel.value)
	new_button.hint_tooltip = "Remove " + card.get("card_name") + " proficiency from " + current_unit.unit_name
	new_button.size_flags_horizontal = SIZE_EXPAND_FILL
	new_button.align = new_button.ALIGN_LEFT
	new_button.clip_text = true
	get_node("Stats/HBoxContainer/VBoxContainer2/Proficiencies/Cards/VBoxContainer").add_child(new_button)
	new_button.connect("pressed", self, "removeProficiency",[current_unit.proficiencies.size()-1])
#	_on_UpdateUnit_pressed()

func removeCard(idx) -> void:
	current_unit.deck.remove(idx)
#	for i in range(idx, unit_prefab.deck.size() - 1):
#		get_node("Stats/HBoxContainer/VBoxContainer2/Cards/Cards/VBoxContainer").get_child(idx).set_meta("idx",idx-1)
	var button = get_node("Stats/HBoxContainer/VBoxContainer2/Cards/Cards/VBoxContainer").get_child(idx)
	get_node("Stats/HBoxContainer/VBoxContainer2/Cards/Cards/VBoxContainer").remove_child(button)
	button.call_deferred("queue_free")
	update_fields(current_unit)


func removeProficiency(idx) -> void:
	current_unit.proficiencies.remove(idx)
#	for i in range(unit_prefab.proficiencies.size() - 1, idx, -1):
#		deck[i-1] = deck[i]	
	var button = get_node("Stats/HBoxContainer/VBoxContainer2/Proficiencies/Cards/VBoxContainer").get_child(idx)
	remove_child(button)
	button.call_deferred("queue_free")
	update_fields(current_unit)


func _on_AddCard_pressed():
	UI_Sounds.createSound(UI_Sounds.popup)
	get_node("WindowDialog").popup()


func _on_AddProficiency_pressed():
	UI_Sounds.createSound(UI_Sounds.popup)
	get_node("WindowDialog2").popup()






func _on_Menu_pressed():
	clear()
	visible = false
	get_parent().menu.visible = true


func _on_CardEditor_pressed():
	clear()
	visible = false
	get_parent().card_maker.visible = true


func _on_TestMap_pressed():
	var permanent_cards:int = 0
	for i in current_unit.deck.size():
		var card = CardLoader.loadSingleCardFile(current_unit.deck[i],true)
		var can_attack:bool
		for d in card.can_attack:
			if d == false:
				can_attack = false
		var self_eliminating:bool
		for e in card.self_eliminating:
			if e == true:
				self_eliminating = true
		var is_consumable:bool
		for c in card.is_consumable:
			if c == true:
				is_consumable = true
		if self_eliminating or is_consumable:
			pass
		else:
			permanent_cards += 1
	if permanent_cards < current_unit.current_draw_points:
		$MenuControl/TestMap/AcceptDialog.dialog_text = "Deck must have more permanent cards\nthan draw points!"
		$MenuControl/TestMap/AcceptDialog.popup_centered()
	else:
		visible = false
#		updateUnit()
		saveUserUnitList()
		clear()
#		get_parent().playMap("TestMap")
		get_parent().playMap("EmptyHexTest")

func clear():
	current_unit.clear()
	clearList()
	clearCardList()
	clearUnitCardList()
	clearUnitProficienciesList()
