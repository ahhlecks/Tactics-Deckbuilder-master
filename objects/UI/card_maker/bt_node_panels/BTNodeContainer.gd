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
				for param in bt_leaf[2]:
					match param:
						BattleDictionary.PARAMETER.INT:
							var spin_box:SpinBox = SpinBox.new()
							vBox.add_child(spin_box)
						BattleDictionary.PARAMETER.UINT:
							var spin_box:SpinBox = SpinBox.new()
							vBox.add_child(spin_box)
							spin_box.min_value = 0
						BattleDictionary.PARAMETER.ARRAY_CHECK:
							var option:ArrayCheckOption = ArrayCheckOption.new()
							vBox.add_child(option)
						BattleDictionary.PARAMETER.CARD_NAME:
							var option:CardNameOption = CardNameOption.new()
							vBox.add_child(option)
						BattleDictionary.PARAMETER.CARD_SOURCE:
							var option:CardSourceOption = CardSourceOption.new()
							vBox.add_child(option)
						BattleDictionary.PARAMETER.CARD_VARIABLE:
							var option:CardVariableOption = CardVariableOption.new()
							vBox.add_child(option)
							for _i in range(9):
								vBox.add_spacer(false)
						BattleDictionary.PARAMETER.COMPARISON:
							var option:ComparisonOption = ComparisonOption.new()
							vBox.add_child(option)
						BattleDictionary.PARAMETER.FALLBACK:
							var option:FallbackButton = FallbackButton.new()
							vBox.add_child(option)
						BattleDictionary.PARAMETER.INT_ARG:
							var option:IntArgOption = IntArgOption.new()
							vBox.add_child(option)
						BattleDictionary.PARAMETER.INT_SOURCE:
							var option:IntSourceOption = IntSourceOption.new()
							vBox.add_child(option)
							for _i in range(9):
								vBox.add_spacer(false)
						BattleDictionary.PARAMETER.OPERATION:
							var option:OperationOption = OperationOption.new()
							vBox.add_child(option)
						BattleDictionary.PARAMETER.TARGET_CALCULATION:
							var option:TargetCalculationOption = TargetCalculationOption.new()
							vBox.add_child(option)
						BattleDictionary.PARAMETER.TARGET_CONDITION:
							var option:TargetConditionOption = TargetConditionOption.new()
							vBox.add_child(option)
						BattleDictionary.PARAMETER.TARGET_SOURCE:
							var option:TargetSourceOption = TargetSourceOption.new()
							vBox.add_child(option)
						BattleDictionary.PARAMETER.UNIT_DECK:
							var option:UnitDeckOption = UnitDeckOption.new()
							vBox.add_child(option)
						BattleDictionary.PARAMETER.UNIT_COST_VARIABLE:
							var option:UnitCostVariableOption = UnitCostVariableOption.new()
							vBox.add_child(option)
						BattleDictionary.PARAMETER.UNIT_INT_MODIFIABLE:
							var option:UnitIntModifiableOption = UnitIntModifiableOption.new()
							vBox.add_child(option)
						BattleDictionary.PARAMETER.UNIT_INT_VARIABLE:
							var option:UnitIntVariableOption = UnitIntVariableOption.new()
							vBox.add_child(option)
						BattleDictionary.PARAMETER.UNIT_VARIABLE:
							var option:UnitVariableOption = UnitVariableOption.new()
							vBox.add_child(option)
						BattleDictionary.PARAMETER.VALID_TARGETS:
							var option:ValidTargetsOption = ValidTargetsOption.new()
							vBox.add_child(option)
						BattleDictionary.PARAMETER.STATUS:
							var option:CardStatusOption = CardStatusOption.new()
							vBox.add_child(option)

func clearNodes():
	for node in vBox.get_children():
		if node.get_class() != "Label":
			node.call_deferred("queue_free")
			vBox.remove_child(node)

func loadValues(values):
#	print(values)
	if values.size() >= vBox.get_child_count() - 1:
		for i in vBox.get_child_count(): #Load saved values if editing a node
			match vBox.get_child(i).get_class():
				"UnitNameOption":
					vBox.get_child(i).select(CardLoader.loadCardList(true).find(values[i]))
				"UnitCostVariableOption", "UnitVariableOption", "IntSourceOption", "UnitIntVariableOption", "UnitIntModifiableOption", "IntArgOption":
					vBox.get_child(i).loadValues(values)
				"CardVariableOption":
					vBox.get_child(i).loadValues(values,i)
				"FallbackButton":
					vBox.get_child(i).select(values[i])
				"OptionButton":
					vBox.get_child(i).select(values[i])
				"SpinBox":
					vBox.get_child(i).value = values[i]

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
#	print(parameter_values)

func clearAll():
	clearNodes()
	vBox.call_deferred("queue_free")
