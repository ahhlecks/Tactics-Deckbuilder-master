extends OptionButton

class_name TargetCalculationOption

# Declare member variables here. Examples:
# "sum_of_targets", "highest_target_value", "lowest_target_value"


# Called when the node enters the scene tree for the first time.
func _ready():
	add_item("sum_of_targets")
	add_item("highest_target_value")
	add_item("lowest_target_value")
	hint_tooltip = BattleDictionary.valid_parameters[BattleDictionary.PARAMETER.TARGET_CALCULATION][1]


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
