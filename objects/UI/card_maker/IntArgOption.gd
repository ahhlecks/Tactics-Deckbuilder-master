extends OptionButton

class_name IntArgOption

func get_class(): return "IntArgOption"

func _ready():
	hint_tooltip = BattleDictionary.valid_parameters[BattleDictionary.PARAMETER.INT_ARG][1]
	add_item("none")
	add_item("int_arg1")
	add_item("int_arg2")

func loadValues(values:Array):
	print(values)
	var index:int = 0
	match values[0]:
		"SetIntArg":
			index = 1
		"CardModifyStat", "CasterModifyStat", "TargetModifyStat", "CasterModifyStatDuration", "TargetModifyStatDuration":
			index = 4
		"HandModifyStat":
			index = 6
	var index_value = BattleDictionary.int_arg_vars.find(values[index])
	select(index_value)

func saveValues() -> String:
	return get_item_text(selected)
