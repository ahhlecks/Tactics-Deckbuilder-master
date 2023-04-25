extends OptionButton


class_name CardIntVariableOption

#Node layout
#[variable, variable value]

# Extra card variables
#card_name
#card_class
#card_type
#self_statuses
#target_statuses

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in BattleDictionary.card_int_vars:
		add_item(i)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func get_class() -> String:
	return "CardIntVariableOption"
