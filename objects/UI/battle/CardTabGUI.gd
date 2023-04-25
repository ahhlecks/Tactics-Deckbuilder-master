extends Control

class_name CardTabGUI

onready var battle_gui = $'../..'

var setup:bool = false
var shifting:bool = false
var start_pos:Vector2
var end_pos:Vector2
var time:float = 0
var move_time:float = .3

var card:Dictionary


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func updateGUI(c) -> void:
	card = c
	$UnitName.text = card.card_caster.unit_name
	$CardName.text = card.card_name + " " + BattleDictionary.toRoman(card.card_level + 1)
	if card.target_unit != null:
		$Target.text = card.target_unit.unit_name
		for result in card.results:
			if result[1].unit_name.find(card.target_unit.unit_name) != -1:
				$Damage.text = str(result[2]) + " Dmg"
				$Damage.hint_tooltip = str(result[2]) + "Damage."
	if !card.card_caster.player_owned:
		$Tab.modulate = "54ff7873"
	else:
		$Tab.modulate = "54ffbfa8"

func setup() -> void:
	start_pos = rect_position
	time = 0
	setup = false

func _process(delta):
	if shifting:
		if setup:
			setup()
		if time <= 1:
			rect_position.y = start_pos.y + (get_parent().smooth_step.interpolate(time) * (end_pos.y - start_pos.y))
			time += delta / move_time
		else:
			rect_position = end_pos
			shifting = false
