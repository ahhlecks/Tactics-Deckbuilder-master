extends ScrollContainer

class_name BTNodeContainer

var parameter_values:Array
onready var vBox:VBoxContainer = $VBoxContainer
onready var description:Label = $VBoxContainer/Description


# Called when the node enters the scene tree for the first time.
func _ready():
	description.autowrap = true

func addNodes(node):
	var bt_nodes:Array = []
	bt_nodes.append_array(BattleDictionary.valid_bt_composites)
	bt_nodes.append_array(BattleDictionary.valid_bt_decorators)
	bt_nodes.append_array(BattleDictionary.valid_bt_leaves)
	for bt_leaf in bt_nodes:
		if node == bt_leaf[0]:
			if bt_leaf.size() > 2:
				var vBox_index = 1
				for param in bt_leaf[2]:
					match param:
						BattleDictionary.PARAMETER.INT:
							var spin_box:SpinBox = SpinBox.new()
							spin_box.set_meta("index",vBox_index)
							vBox_index += 1
							vBox.add_child(spin_box)
						BattleDictionary.PARAMETER.UINT:
							var spin_box:SpinBox = SpinBox.new()
							spin_box.set_meta("index",vBox_index)
							vBox_index += 1
							vBox.add_child(spin_box)
							spin_box.min_value = 0
						BattleDictionary.PARAMETER.ARRAY_CHECK:
							var option:ArrayCheckOption = ArrayCheckOption.new()
							option.set_meta("index",vBox_index)
							vBox_index += 1
							vBox.add_child(option)
						BattleDictionary.PARAMETER.CARD_NAME:
							var option:CardNameOption = CardNameOption.new()
							option.set_meta("index",vBox_index)
							vBox_index += 1
							vBox.add_child(option)
						BattleDictionary.PARAMETER.CARD_SOURCE:
							var option:CardSourceOption = CardSourceOption.new()
							option.set_meta("index",vBox_index)
							vBox_index += 1
							vBox.add_child(option)
						BattleDictionary.PARAMETER.CARD_VARIABLE:
							var option:CardVariableOption = CardVariableOption.new()
							option.set_meta("index",vBox_index)
							vBox_index += 2
							vBox.add_child(option)
							for _i in range(9):
								vBox.add_spacer(false)
						BattleDictionary.PARAMETER.COMPARISON:
							var option:ComparisonOption = ComparisonOption.new()
							option.set_meta("index",vBox_index)
							vBox_index += 1
							vBox.add_child(option)
						BattleDictionary.PARAMETER.FALLBACK:
							var option:FallbackButton = FallbackButton.new()
							option.set_meta("index",vBox_index)
							vBox_index += 1
							vBox.add_child(option)
						BattleDictionary.PARAMETER.INT_ARG:
							var option:IntArgOption = IntArgOption.new()
							option.set_meta("index",vBox_index)
							vBox_index += 1
							vBox.add_child(option)
						BattleDictionary.PARAMETER.INT_SOURCE:
							var option:IntSourceOption = IntSourceOption.new()
							option.set_meta("index",vBox_index)
							vBox_index += 1
							vBox.add_child(option)
							for _i in range(9):
								vBox.add_spacer(false)
						BattleDictionary.PARAMETER.OPERATION:
							var option:OperationOption = OperationOption.new()
							option.set_meta("index",vBox_index)
							vBox_index += 1
							vBox.add_child(option)
						BattleDictionary.PARAMETER.TARGET_CALCULATION:
							var option:TargetCalculationOption = TargetCalculationOption.new()
							option.set_meta("index",vBox_index)
							vBox_index += 1
							vBox.add_child(option)
						BattleDictionary.PARAMETER.TARGET_CONDITION:
							var option:TargetConditionOption = TargetConditionOption.new()
							option.set_meta("index",vBox_index)
							vBox_index += 1
							vBox.add_child(option)
						BattleDictionary.PARAMETER.TARGET_SOURCE:
							var option:TargetSourceOption = TargetSourceOption.new()
							option.set_meta("index",vBox_index)
							vBox_index += 1
							vBox.add_child(option)
						BattleDictionary.PARAMETER.UNIT_DECK:
							var option:UnitDeckOption = UnitDeckOption.new()
							option.set_meta("index",vBox_index)
							vBox_index += 1
							vBox.add_child(option)
						BattleDictionary.PARAMETER.UNIT_COST_VARIABLE:
							var option:UnitCostVariableOption = UnitCostVariableOption.new()
							option.set_meta("index",vBox_index)
							vBox_index += 1
							vBox.add_child(option)
						BattleDictionary.PARAMETER.UNIT_INT_MODIFIABLE:
							var option:UnitIntModifiableOption = UnitIntModifiableOption.new()
							option.set_meta("index",vBox_index)
							vBox_index += 1
							vBox.add_child(option)
						BattleDictionary.PARAMETER.UNIT_INT_VARIABLE:
							var option:UnitIntVariableOption = UnitIntVariableOption.new()
							option.set_meta("index",vBox_index)
							vBox_index += 1
							vBox.add_child(option)
						BattleDictionary.PARAMETER.UNIT_VARIABLE:
							var option:UnitVariableOption = UnitVariableOption.new()
							option.set_meta("index",vBox_index)
							vBox_index += 1
							vBox.add_child(option)
						BattleDictionary.PARAMETER.VALID_TARGETS:
							var option:ValidTargetsOption = ValidTargetsOption.new()
							option.set_meta("index",vBox_index)
							vBox_index += 1
							vBox.add_child(option)
						BattleDictionary.PARAMETER.STATUS:
							var option:CardStatusOption = CardStatusOption.new()
							option.set_meta("index",vBox_index)
							vBox_index += 1
							vBox.add_child(option)
						BattleDictionary.PARAMETER.FLOAT:
							var spin_box:SpinBox = SpinBox.new()
							spin_box.set_meta("index",vBox_index)
							vBox_index += 1
							vBox.add_child(spin_box)
							spin_box.step = 0.01

func clearNodes():
	for node in vBox.get_children():
		if node.get_class() != "Label":
			node.call_deferred("queue_free")
			vBox.remove_child(node)

func loadValues(values):
	for i in vBox.get_child_count(): #Load saved values if editing a node
		var index:int = 0
		if vBox.get_child(i).has_meta("index"):
			index = vBox.get_child(i).get_meta("index")
		match vBox.get_child(i).get_class():
			"UnitNameOption":
				vBox.get_child(i).select(CardLoader.loadCardList(true).find(values[i]))
			"UnitCostVariableOption", "UnitVariableOption", "IntSourceOption", "UnitIntVariableOption", "UnitIntModifiableOption", "IntArgOption":
				vBox.get_child(i).loadValues(values)
			"CardVariableOption":
				var value:Array = [values[index],values[index+1]]
				vBox.get_child(i).loadValues(value,index)
			"FallbackButton":
				vBox.get_child(i).set_pressed(values[index])
			"OptionButton":
				vBox.get_child(i).select(values[index])
			"SpinBox":
				vBox.get_child(i).value = values[index]
			_:
				pass

func saveValues():
	var parameter_name = parameter_values[0]
	parameter_values.clear()
	parameter_values = [parameter_name]
	for node in vBox.get_children():
		match node.get_class():
			"UnitVariableOption", "UnitIntVariableOption", "UnitNameOption", "UnitCostVariableOption", "UnitIntModifiableOption", "IntArgOption":
				parameter_values.append(node.get_item_text(node.selected))
			"CardVariableOption", "IntSourceOption":
				parameter_values.append_array(node.saveValues())
			"FallbackButton":
				parameter_values.append(node.pressed)
			"OptionButton":
				parameter_values.append(node.selected)
			"SpinBox":
				parameter_values.append(node.value)

func clearAll():
	clearNodes()
	vBox.call_deferred("queue_free")
