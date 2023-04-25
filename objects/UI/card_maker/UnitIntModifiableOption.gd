extends OptionButton


class_name UnitIntModifiableOption

# Called when the node enters the scene tree for the first time.
func _ready():
	hint_tooltip = BattleDictionary.valid_parameters[BattleDictionary.PARAMETER.UNIT_INT_MODIFIABLE][1]
	for i in BattleDictionary.unit_int_modifiable:
		add_item(i)

func loadValues(values:Array):
	var index = 1
	match values[0]:
		"CasterModifyStatDuration", "TargetModifyStatDuration", "CasterModifyStat", "TargetDrawCard":
			index = 2
	var index_value = BattleDictionary.unit_int_modifiable.find(values[index])
	select(index_value)

func saveValues() -> String:
	return get_item_text(selected)

func get_class() -> String:
	return "UnitIntModifiableOption"
