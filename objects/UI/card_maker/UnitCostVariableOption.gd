extends OptionButton


class_name UnitCostVariableOption

# Called when the node enters the scene tree for the first time.
func _ready():
	hint_tooltip = BattleDictionary.valid_parameters[BattleDictionary.PARAMETER.UNIT_COST_VARIABLE][1]
	for i in BattleDictionary.valid_unit_cost_stats:
		add_item(i)

func loadValues(values:Array):
	var index = BattleDictionary.valid_unit_cost_stats.find(values[1])
	select(index)

func saveValues() -> String:
	return get_item_text(selected)

func get_class() -> String:
	return "UnitCostVariableOption"
