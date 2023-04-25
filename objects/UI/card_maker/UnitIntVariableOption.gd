extends OptionButton


class_name UnitIntVariableOption

# Called when the node enters the scene tree for the first time.
func _ready():
	hint_tooltip = BattleDictionary.valid_parameters[BattleDictionary.PARAMETER.UNIT_INT_VARIABLE][1]
	for i in BattleDictionary.unit_int_vars:
		add_item(i)

func loadValues(values:Array):
	var index = BattleDictionary.unit_int_vars.find(values[1])
	select(index)

func saveValues() -> String:
	return get_item_text(selected)

func get_class() -> String:
	return "UnitIntVariableOption"
