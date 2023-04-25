extends OptionButton


class_name UnitDeckOption
# Declare member variables here. Examples:
# export(String, "active_deck", "hand_deck", "discard_deck", "consumed_deck") var deck:String


# Called when the node enters the scene tree for the first time.
func _ready():
	hint_tooltip = BattleDictionary.valid_parameters[BattleDictionary.PARAMETER.UNIT_DECK][1]
	add_item("active_deck")
	add_item("hand_deck")
	add_item("discard_deck")
	add_item("consumed_deck")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
