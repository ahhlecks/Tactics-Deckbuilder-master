extends OptionButton

class_name TargetConditionOption

# Declare member variables here. Examples:
# var a = 2
# export(int, "one target", "all targets") var target_condition


# Called when the node enters the scene tree for the first time.
func _ready():
	add_item("one_target")
	add_item("all_targets")
	hint_tooltip = BattleDictionary.valid_parameters[BattleDictionary.PARAMETER.TARGET_CONDITION][1]


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
