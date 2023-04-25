extends OptionButton

class_name TargetSourceOption

# Called when the node enters the scene tree for the first time.
func _ready():
	add_item("Card Caster")
	add_item("Card Target")
	hint_tooltip = BattleDictionary.valid_parameters[BattleDictionary.PARAMETER.TARGET_SOURCE][1]
