extends Control

class_name UnitTabGUI

onready var battle_gui = $'../..'

var setup:bool = false
var shifting:bool = false
var start_pos:Vector2
var end_pos:Vector2
var time:float = 0
var move_time:float = .3

var selected:bool = false
var locked:bool = false
var player_owned:bool

var unit:HexUnit
var unit_name:String
var team:int
var unit_class:int
var current_health:int
var max_health:int
var current_action_points:int
var max_action_points:int
var level:int
var block:int
var deflect:int

var unit_AP_paths = {
	0 : "res://assets/images/ui/unit/AP_Warrior.png",
	1 : "res://assets/images/ui/unit/AP_Ranger.png", 
	2 : "res://assets/images/ui/unit/AP_Mage.png",
	}

func loadUnit(u:HexUnit):
	unit = u
	unit_name = unit.unit_name
	team = unit.team
	unit_class = unit.unit_class
	current_health = unit.current_health
	max_health = unit.max_health
	current_action_points = unit.current_action_points
	max_action_points = unit.max_action_points
	block = unit.block
	deflect = unit.deflect
	player_owned = unit.player_owned
	$AP.texture = load(unit_AP_paths.get(unit_class))


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func updateGUI(unit) -> void:
	loadUnit(unit)
	$UnitName.text = unit_name
	$HP.max_value = max_health
	$HP.value = current_health
	$HP.hint_tooltip = str(current_health) + " Health Points (HP)"
	$HP/HP_Label.text = str(max(0,current_health)) + "/" + str(max_health)
	if current_health > 0:
		$HP/HP_Label.modulate = Color( 1, 1, 1, 1 )
	else:
		$HP/HP_Label.modulate = Color.crimson
	$AP/AP_Label.text = str(current_action_points) + "/" + str(max_action_points)
	if current_action_points != 0:
		$AP/AP_Label.modulate = Color( 1, 1, 1, 1 )
	else:
		$AP/AP_Label.modulate = Color.crimson
	$AP/AP_Label.hint_tooltip = str(current_action_points) + " Action Points (AP)" 
	$Block.hint_tooltip = str(block) + " Block"
	$Block/Label.text = str(block)
	$Deflect.hint_tooltip = str(deflect) + " Deflect"
	$Deflect/Label.text = str(deflect)
	if unit.current_react_card != null:
		$ReactButtonMini.visible = true
		$ReactButtonMini.hint_tooltip = unit.current_react_card.card_name
	else:
		$ReactButtonMini.visible = false
	if !player_owned:
		$Tab.modulate = "54ff7873"
	else:
		$Tab.modulate = "54ffbfa8"

func setup() -> void:
	start_pos = rect_position
	time = 0
	setup = false

func _physics_process(delta):
	if shifting:
		if setup:
			setup()
		if time <= 1:
			rect_position.y = start_pos.y + (get_parent().smooth_step.interpolate(time) * (end_pos.y - start_pos.y))
			time += delta / move_time
		else:
			rect_position = end_pos
			shifting = false
