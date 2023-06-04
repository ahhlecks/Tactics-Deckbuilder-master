extends Control

class_name UnitGUI

func get_class() -> String: return "UnitGUI"

onready var battle_gui = $'../..'
onready var AP = $AP

var selected:bool = false
var locked:bool = false
var player_owned:bool

var unit_id
var axialCoordinates:Vector2
var cubeCoordinates:Vector3
var oddRCoordinates:Vector2
var elevation:int
var unit_name:String
var team:int
var unit_class:int
var unit_class_name:String
var current_health:int
var max_health:int
var current_action_points:int
var max_action_points:int
var base_action_points_regen:int
var current_action_points_regen:int
var current_movement_points:int
var max_movement_points:int
var current_jump_points:int
var max_jump_points:int
var base_speed:float
var current_speed:float
var base_physical_accuracy:float
var current_physical_accuracy:float
var base_magic_accuracy:float
var current_magic_accuracy:float
var base_physical_evasion:float
var current_physical_evasion:float
var base_magic_evasion:float
var current_magic_evasion:float
var base_draw_points:int
var current_draw_points:int
var experience:int
var level:int
var block:int
var strength:int
var willpower:int
var traits:Array
var statuses:Array
var proficiencies:Array
var deck:Array = []

var unit_AP_paths = {
	0 : "res://assets/images/ui/unit/AP_Warrior.png",
	1 : "res://assets/images/ui/unit/AP_Ranger.png", 
	2 : "res://assets/images/ui/unit/AP_Mage.png",
	}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func loadUnit(unit:HexUnit):
	unit_id = unit
	axialCoordinates = unit.axialCoordinates
	cubeCoordinates = HexUtils.axialToCube(axialCoordinates)
	oddRCoordinates = HexUtils.cubeToOddR(cubeCoordinates)
	unit_name = unit.unit_name
	team = unit.team
	unit_class = unit.unit_class
	unit_class_name = unit.unit_class_name
	cubeCoordinates = unit.cubeCoordinates
	elevation = unit.elevation
	current_health = unit.current_health
	max_health = unit.max_health
	current_action_points = unit.current_action_points
	max_action_points = unit.max_action_points
	base_action_points_regen = unit.base_action_points_regen
	current_action_points_regen = unit.current_action_points_regen
	current_movement_points = unit.current_movement_points
	max_movement_points = unit.max_movement_points
	current_jump_points = unit.current_jump_points
	max_jump_points = unit.max_jump_points
	current_physical_evasion = unit.current_physical_evasion
	current_magic_evasion = unit.current_magic_evasion
	current_draw_points = unit.current_draw_points
	base_draw_points = unit.base_draw_points
	experience = unit.experience
	level = unit.level
	block = unit.block
	strength = unit.strength
	willpower = unit.willpower
	traits = unit.traits
	statuses = unit.statuses
	player_owned = unit.player_owned
	deck = unit.deck
	base_speed = unit.base_speed
	current_speed = unit.getUnitSpeed()
	AP.texture = load(unit_AP_paths.get(unit_class))
	setClassColor()

func updateGUI(unit:HexUnit) -> void:
	loadUnit(unit)
	$UnitName.text = unit_name
	$Level.text = "Lv. " + str(level)
	$AP/AP_Label.text = str(current_action_points) + "/" + str(max_action_points)
	if current_action_points != 0:
		$AP/AP_Label.modulate = Color( 1, 1, 1, 1 )
	else:
		$AP/AP_Label.modulate = Color.crimson
	$AP/AP_Label.hint_tooltip = str(current_action_points) + " Action Points (AP)" 
	$Block.hint_tooltip = str(block) + " Block"
	$Block/Label.text = str(block)
	$HP_Bar.max_value = max_health
	$HP_Bar.value = current_health
	if current_health > 0:
		$HP_Bar/HP_Label.modulate = Color( 1, 1, 1, 1 )
	else:
		$HP_Bar/HP_Label.modulate = Color.crimson
	$HP_Bar.hint_tooltip = str(current_health) + " Health Points (HP)"
	$HP_Bar/HP_Label.text = str(max(0,current_health)) + "/" + str(max_health)
	$Move.text = "Move: " + str(current_movement_points)
	$Jump.text = "Jump: " + str(current_jump_points)
	$Speed.hint_tooltip = "Actual Speed: " + str(current_speed)
	$Speed.text = "Speed: " + str(round(current_speed))
	$PhysEvade.text = "Phys Evade %: " + str(current_physical_evasion)
	$MagEvade.text = "Mag Evade %: " + str(current_magic_evasion)

func setClassColor() -> void:
	if unit_class == 0:
		pass
#		gui_class_color.modulate = Color("C04040")
	if unit_class == 1:
		pass
#		gui_class_color.modulate = Color("40C040")
	if unit_class == 2:
		pass
#		gui_class_color.modulate = Color("4040C0")


func _on_Deck_Icon_pressed():
	pass
