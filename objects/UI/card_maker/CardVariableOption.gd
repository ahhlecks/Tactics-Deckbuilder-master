extends CompoundOptionButton


class_name CardVariableOption

onready var int_option:SpinBox = SpinBox.new() # card_variable_value as int
onready var name_option:CardNameOption = CardNameOption.new()
onready var class_option:CardClassOption = CardClassOption.new()
onready var type_option:CardTypeOption = CardTypeOption.new()
onready var status_option:CardStatusOption = CardStatusOption.new()
onready var element_option:CardElementOption = CardElementOption.new()
onready var boolean_option:CheckButton = CheckButton.new()
onready var int_arg_option:IntArgOption = IntArgOption.new()
onready var option_array:Array = [int_option,name_option,class_option,type_option,status_option,element_option,boolean_option,int_arg_option]

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
	for i in BattleDictionary.valid_card_stats:
		add_item(i)
	int_option.min_value = -INF
	int_option.visible = false
	name_option.visible = false
	class_option.visible = false
	type_option.visible = false
	status_option.visible = false
	element_option.visible = false
	boolean_option.visible = false
	int_arg_option.visible = false
	add_child(VBox)
	VBox.rect_position.y += 28
	VBox.add_child(int_option)
	VBox.add_child(name_option)
	VBox.add_child(class_option)
	VBox.add_child(type_option)
	VBox.add_child(status_option)
	VBox.add_child(element_option)
	VBox.add_child(boolean_option)
	VBox.add_child(int_arg_option)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_item_selected(index):
	match index:
		0:
			int_option.visible = false
			name_option.visible = false
			class_option.visible = false
			type_option.visible = false
			status_option.visible = false
			element_option.visible = false
			boolean_option.visible = false
#			int_arg_option.visible = false
		1:
			int_option.visible = false
			name_option.visible = true
			class_option.visible = false
			type_option.visible = false
			status_option.visible = false
			element_option.visible = false
			boolean_option.visible = false
#			int_arg_option.visible = false
		2:
			int_option.visible = false
			name_option.visible = false
			class_option.visible = true
			type_option.visible = false
			status_option.visible = false
			element_option.visible = false
			boolean_option.visible = false
#			int_arg_option.visible = false
		6:
			int_option.visible = false
			name_option.visible = false
			class_option.visible = false
			type_option.visible = true
			status_option.visible = false
			element_option.visible = false
			boolean_option.visible = false
#			int_arg_option.visible = false
		7,8,9,10,11,12,13,14,15,16:
			int_option.visible = false
			name_option.visible = false
			class_option.visible = false
			type_option.visible = false
			status_option.visible = false
			element_option.visible = false
			boolean_option.visible = true
#			int_arg_option.visible = false
		17,18:
			int_option.visible = false
			name_option.visible = false
			class_option.visible = false
			type_option.visible = false
			status_option.visible = true
			element_option.visible = false
			boolean_option.visible = false
#			int_arg_option.visible = false
		26:
			int_option.visible = false
			name_option.visible = false
			class_option.visible = false
			type_option.visible = false
			status_option.visible = false
			element_option.visible = true
			boolean_option.visible = false
#			int_arg_option.visible = false
#		27,28:
#			int_option.visible = false
#			name_option.visible = false
#			class_option.visible = false
#			type_option.visible = false
#			status_option.visible = false
#			element_option.visible = false
#			boolean_option.visible = false
#			int_arg_option.visible = true
		_:
			int_option.visible = true
			name_option.visible = false
			class_option.visible = false
			type_option.visible = false
			status_option.visible = false
			element_option.visible = false
			boolean_option.visible = false
#			int_arg_option.visible = false

func loadValues(values:Array, index):
	var index_value = BattleDictionary.valid_card_stats.find(values[index])
	select(index_value)
	match index_value:
		0:
			int_option.visible = false
			name_option.visible = false
			class_option.visible = false
			type_option.visible = false
			status_option.visible = false
			element_option.visible = false
			boolean_option.visible = false
		1:
			int_option.visible = false
			name_option.visible = true
			class_option.visible = false
			type_option.visible = false
			status_option.visible = false
			element_option.visible = false
			boolean_option.visible = false
			name_option.select(values[index + 1])
		2:
			int_option.visible = false
			name_option.visible = false
			class_option.visible = true
			type_option.visible = false
			status_option.visible = false
			element_option.visible = false
			boolean_option.visible = false
			class_option.select(values[index + 1])
		6:
			int_option.visible = false
			name_option.visible = false
			class_option.visible = false
			type_option.visible = true
			status_option.visible = false
			element_option.visible = false
			boolean_option.visible = false
			type_option.select(values[index + 1])
		7,8,9,10,11,12,13,14,15,16:
			int_option.visible = false
			name_option.visible = false
			class_option.visible = false
			type_option.visible = false
			status_option.visible = false
			element_option.visible = false
			boolean_option.visible = true
			boolean_option.pressed = values[index + 1]
		17,18:
			int_option.visible = false
			name_option.visible = false
			class_option.visible = false
			type_option.visible = false
			status_option.visible = true
			element_option.visible = false
			boolean_option.visible = false
			status_option.select(values[index + 1])
		26:
			int_option.visible = false
			name_option.visible = false
			class_option.visible = false
			type_option.visible = false
			status_option.visible = false
			element_option.visible = true
			boolean_option.visible = false
			element_option.select(values[index + 1])
		_:
			int_option.visible = true
			name_option.visible = false
			class_option.visible = false
			type_option.visible = false
			status_option.visible = false
			element_option.visible = false
			boolean_option.visible = false
			int_option.value = values[index + 1]

func saveValues() -> Array:
	var saved_values:Array
	saved_values.append(get_item_text(selected))
	var option_saved:bool = false
	for option in option_array:
		if option.visible and !option_saved:
			if option.get_class() == "SpinBox":
				saved_values.append(option.value)
				option_saved = true
			if option.get_class() == "OptionButton":
				saved_values.append(option.selected)
				option_saved = true
			if option.get_class() == "CheckButton":
				saved_values.append(option.pressed)
				option_saved = true
	if !option_saved:
		saved_values.append(0)
	return saved_values

func get_class() -> String:
	return "CardVariableOption"
