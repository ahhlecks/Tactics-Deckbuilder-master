extends CompoundOptionButton

class_name IntSourceOption

onready var int_option:SpinBox = SpinBox.new()
onready var unit_variable_option:UnitIntVariableOption = UnitIntVariableOption.new()
onready var card_variable_option:CardIntVariableOption = CardIntVariableOption.new()
onready var target_calculation_option:TargetCalculationOption = TargetCalculationOption.new()
onready var option_array:Array = [int_option,unit_variable_option,card_variable_option,target_calculation_option]

#Node layout
#[int_source_option, variable value]

#"integer",
#"card_caster",
#"card_target",
#"card_variable,

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in BattleDictionary.int_source:
		add_item(i)
	int_option.visible = true
	unit_variable_option.visible = false
	card_variable_option.visible = false
	target_calculation_option.visible = false
	add_child(VBox)
	VBox.rect_position.y += 28
	VBox.add_child(int_option)
	VBox.add_child(unit_variable_option)
	VBox.add_child(card_variable_option)
	VBox.add_child(target_calculation_option)


func loadValues(values:Array):
	var index = 1
	var variable_index = 2
	match values[0]:
		"ModifyAttack":
			index = 2
			variable_index = 3
		"SetIntArg":
			index = 2
			if values[2] == "integer":
				variable_index = 3
			elif values[4] != "none":
				variable_index = 4
			elif values[5] != "none":
				variable_index = 5
	var index_value = BattleDictionary.int_source.find(values[index])
	select(index_value)
	match index_value:
		0:
			int_option.visible = true
			unit_variable_option.visible = false
			card_variable_option.visible = false
			target_calculation_option.visible = false
			int_option.value = values[variable_index]
		1:
			int_option.visible = false
			unit_variable_option.visible = true
			card_variable_option.visible = false
			target_calculation_option.visible = false
			unit_variable_option.select(BattleDictionary.unit_int_vars.find(values[variable_index]))
		2:
			int_option.visible = false
			unit_variable_option.visible = true
			card_variable_option.visible = false
			target_calculation_option.visible = true
			unit_variable_option.select(BattleDictionary.unit_int_vars.find(values[variable_index]))
			target_calculation_option.select(values.back())
		3:
			int_option.visible = false
			unit_variable_option.visible = false
			card_variable_option.visible = true
			target_calculation_option.visible = false
			card_variable_option.select(BattleDictionary.card_int_vars.find(values[variable_index]))

func _on_item_selected(index):
	match index:
		0:
			int_option.visible = true
			unit_variable_option.visible = false
			card_variable_option.visible = false
			target_calculation_option.visible = false
		1:
			int_option.visible = false
			unit_variable_option.visible = true
			card_variable_option.visible = false
			target_calculation_option.visible = false
		2:
			int_option.visible = false
			unit_variable_option.visible = true
			card_variable_option.visible = false
			target_calculation_option.visible = true
		3:
			int_option.visible = false
			unit_variable_option.visible = false
			card_variable_option.visible = true
			target_calculation_option.visible = false

func saveValues() -> Array:
	var saved_values:Array
	saved_values.append(get_item_text(selected))
	var option_saved:bool = false
	for option in option_array:
		if option.visible and !option_saved:
			if option.get_class() == "SpinBox":
				saved_values.append(option.value)
				saved_values.append("none")
				saved_values.append("none")
				option_saved = true
				continue
			if option.get_class() == "CardIntVariableOption":
				saved_values.append(0)
				saved_values.append("none")
				saved_values.append(option.get_item_text(option.selected))
				option_saved = true
				continue
			if option.get_class() == "UnitIntVariableOption":
				saved_values.append(0)
				saved_values.append(option.saveValues())
				saved_values.append("none")
				option_saved = true
				continue
			if option.get_class() == "OptionButton":
				saved_values.append(option.selected)
				option_saved = true
				continue
			if option.get_class() == "CheckButton":
				saved_values.append(option.pressed)
				option_saved = true
				continue
	if !option_saved:
		saved_values.append_array([0,"none","none"])
	if target_calculation_option.visible:
		saved_values.append(target_calculation_option.selected)
	else:
		saved_values.append(0)
	return saved_values

func get_class() -> String:
	return "IntSourceOption"
