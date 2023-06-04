extends Panel

var dupe:bool = false
onready var card_upgrade = get_node("ScrollContainer/VBoxContainer/HBoxContainer5")
onready var card_status = get_node("ScrollContainer/VBoxContainer/HBoxContainer6")
var card_status_option = preload("res://objects/UI/card_maker/CardStatusDurationOption.tscn")
var card_prerequisite_option = preload("res://objects/UI/card_maker/CardPrerequisiteOption.tscn")

onready var card_maker:Node = $'../../..'
onready var card_upgrade_value = $ScrollContainer/VBoxContainer/HBoxContainer5/CardUpgradeCost
onready var card_action_cost = $ScrollContainer/VBoxContainer/ActionCost/ActionCost
onready var card_action_cost_label = $ScrollContainer/VBoxContainer/ActionCost/Label
onready var card_damage = $ScrollContainer/VBoxContainer/Damage/Damage
onready var card_damage_label = $ScrollContainer/VBoxContainer/Damage/Label
onready var card_delay = $ScrollContainer/VBoxContainer/Delay/Delay
onready var card_min_range = $ScrollContainer/VBoxContainer/Range/MinRange
onready var card_max_range = $ScrollContainer/VBoxContainer/Range/MaxRange
onready var card_up_range = $ScrollContainer/VBoxContainer/VerticalRange/UpVertRange
onready var card_down_range = $ScrollContainer/VBoxContainer/VerticalRange/DownVertRange
onready var card_added_accuracy = $ScrollContainer/VBoxContainer/CardAddedAccuracy/AddedAccuracy
onready var card_added_crit_accuracy = $ScrollContainer/VBoxContainer/CardAddedAccuracy/AddedCritAccuracy
onready var card_element = $ScrollContainer/VBoxContainer/HBoxContainer4/CardElement
onready var card_element2 = $ScrollContainer/VBoxContainer/HBoxContainer4/CardElement2
onready var card_element3 = $ScrollContainer/VBoxContainer/HBoxContainer4/CardElement3
onready var self_statuses = $ScrollContainer/VBoxContainer/HBoxContainer6
onready var target_statuses = $ScrollContainer/VBoxContainer/HBoxContainer7
onready var prerequisites = $ScrollContainer/VBoxContainer/GridContainer2
onready var card_action = $ScrollContainer/VBoxContainer/GridContainer/Action
onready var card_reaction = $ScrollContainer/VBoxContainer/GridContainer/Reaction
onready var card_need_los = $ScrollContainer/VBoxContainer/GridContainer/NeedLOS
onready var card_piercing = $ScrollContainer/VBoxContainer/GridContainer/Piercing
onready var card_shattering = $ScrollContainer/VBoxContainer/GridContainer/Shattering
onready var card_consumable = $ScrollContainer/VBoxContainer/GridContainer/Consume
onready var card_homing = $ScrollContainer/VBoxContainer/GridContainer/Homing
onready var card_combo = $ScrollContainer/VBoxContainer/GridContainer/Combo
onready var card_counter = $ScrollContainer/VBoxContainer/GridContainer/Counter
onready var card_reflex = $ScrollContainer/VBoxContainer/GridContainer/Reflex
onready var card_self_eliminating = $ScrollContainer/VBoxContainer/GridContainer/SelfEliminating
onready var card_hexagonal_targeting = $ScrollContainer/VBoxContainer/GridContainer/HexagonalTargeting
onready var card_animation_left_weapon = $ScrollContainer/VBoxContainer/HBoxContainer3/Weapon
onready var card_animation_right_weapon = $ScrollContainer/VBoxContainer/HBoxContainer3/Weapon2
onready var card_animation = $ScrollContainer/VBoxContainer/HBoxContainer/CardAnimation
onready var card_animation2 = $ScrollContainer/VBoxContainer/HBoxContainer/CardAnimation2
onready var card_counter_anim_tandem = $ScrollContainer/VBoxContainer/HBoxContainer/CounterAnimTandem
onready var card_description = $ScrollContainer/VBoxContainer/Description
onready var tree = $ScrollContainer/VBoxContainer/Tree


# Called when the node enters the scene tree for the first time.
func _ready():
	if !dupe:
		for i in BattleDictionary.ELEMENT:
			card_element.add_item(i)
			card_element2.add_item(i)
			card_element3.add_item(i)

func _init():
	pass

func makeDupe() -> void:
	dupe = true
	_ready()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func addSelfStatusOption():
	var new_option = card_status_option.instance()
	get_node("ScrollContainer/VBoxContainer/HBoxContainer6").add_child(new_option)

func addTargetStatusOption():
	var new_option = card_status_option.instance()
	get_node("ScrollContainer/VBoxContainer/HBoxContainer7").add_child(new_option)

func _on_AddSelfStatus_pressed():
	addSelfStatusOption()


func _on_AddTargetStatus_pressed():
	addTargetStatusOption()


func _on_Reaction_toggled(button_pressed):
	if button_pressed:
		get_node("ScrollContainer/VBoxContainer/GridContainer/Counter").disabled = false
		get_node("ScrollContainer/VBoxContainer/GridContainer/Reflex").disabled = false
	else:
		get_node("ScrollContainer/VBoxContainer/GridContainer/Counter").disabled = true
		get_node("ScrollContainer/VBoxContainer/GridContainer/Reflex").disabled = true
		get_node("ScrollContainer/VBoxContainer/GridContainer/Counter").pressed = false
		get_node("ScrollContainer/VBoxContainer/GridContainer/Reflex").pressed = false

func _on_Counter_toggled(button_pressed):
	if button_pressed:
		get_node("ScrollContainer/VBoxContainer/HBoxContainer/CounterAnimTandem").disabled = false
	else:
		get_node("ScrollContainer/VBoxContainer/HBoxContainer/CounterAnimTandem").disabled = true
		get_node("ScrollContainer/VBoxContainer/HBoxContainer/CounterAnimTandem").pressed = false


func _on_AddPrerequisite_pressed():
	var new_option = card_prerequisite_option.instance()
	get_node("ScrollContainer/VBoxContainer/GridContainer2").add_child(new_option)

func _on_Tree_item_activated():
	var selected = tree.get_selected()
	if selected != tree.get_root():
		var node_name:String = selected.get_text(0)
		popupBTNode(node_name,selected.get_meta("description"), selected.get_meta("parameters"), selected.get_meta("parameter_values"), true)

# warning-ignore:unused_argument
func popupBTNode(btnode, description, params, values, is_edit = false) -> void:
	card_maker.bt_node_dialog.newBTContainer(btnode,description,values,is_edit)
	card_maker.bt_node_dialog.popup_centered()


func _on_Tree_nothing_selected():
	if tree.get_selected() != null:
		tree.get_selected().deselect(0)


func _on_AddItem_pressed():
	card_maker.bt_node_list.popup_centered()


func _on_RemoveItem_pressed():
	if tree.get_selected() != null and tree.get_selected() != tree.get_root():
		tree.get_selected().free()
	tree.grab_focus()


func _on_PrintTree_pressed():
	print(convertTreeToArray(tree))

func convertTreeToArray(behavior_tree:Tree) -> Array:
	if behavior_tree != null:
		if behavior_tree.get_root().has_meta("parameter_values"):
			var saved_behavior:Array = getTreeItems(behavior_tree.get_root())
			return saved_behavior
	return []

func getTreeItems(tree_item:TreeItem) -> Array:
	var tree_items:Array = []
	if tree_item.has_meta("parameter_values"):
		for i in tree_item.get_meta("parameter_values"):
			tree_items.append(i)
	if tree_item.get_children() != null:
		tree_item = tree_item.get_children()
		tree_items.append(getTreeItems(tree_item))
	else:
		while tree_item.get_next() != null:
			tree_item = tree_item.get_next()
			if tree_item.has_meta("parameter_values"):
				for i in tree_item.get_meta("parameter_values"):
					tree_items.append(i)
			var last_item = tree_item
			if tree_item.get_children() != null:
				tree_item = tree_item.get_children()
				tree_items.append(getTreeItems(tree_item))
				tree_item = last_item
	return tree_items

func loadTreeItem(branch:TreeItem, bt_node_array:Array) -> void:
	var new_branch:TreeItem
	for bt_node in bt_node_array.size():
		if typeof(bt_node_array[bt_node]) == TYPE_ARRAY:
			loadTreeItem(new_branch, bt_node_array[bt_node])
		else:
			match bt_node_array[bt_node]:
				#Composites
				"BTSelector":
					if tree.get_root() == null:
						var item = tree.create_item()
						var bt_node_text:String = "BTSelector"
						item.set_text(0,bt_node_text)
						item.set_meta("parameter_values", [bt_node_text])
						item.set_meta("description", BattleDictionary.valid_bt_composites[0][1])
						new_branch = item
					else:
						var item = tree.create_item(branch)
						var bt_node_text:String = "BTSelector"
						item.set_text(0,bt_node_text)
						item.set_meta("parameter_values", [bt_node_text])
						item.set_meta("description", BattleDictionary.valid_bt_composites[0][1])
						new_branch = item
				"BTSequence":
					if tree.get_root() == null:
						var item = tree.create_item()
						var bt_node_text:String = "BTSequence"
						item.set_text(0,bt_node_text)
						item.set_meta("parameter_values", [bt_node_text])
						item.set_meta("description", BattleDictionary.valid_bt_composites[1][1])
						new_branch = item
					else:
						var item = tree.create_item(branch)
						var bt_node_text:String = "BTSequence"
						item.set_text(0,bt_node_text)
						item.set_meta("parameter_values", [bt_node_text])
						item.set_meta("description", BattleDictionary.valid_bt_composites[1][1])
						new_branch = item
				"BTRandomSelector":
					if tree.get_root() == null:
						var item = tree.create_item()
						var bt_node_text:String = "BTRandomSelector"
						item.set_text(0,bt_node_text)
						item.set_meta("parameter_values", [bt_node_text])
						item.set_meta("description", BattleDictionary.valid_bt_composites[2][1])
						new_branch = item
					else:
						var item = tree.create_item(branch)
						var bt_node_text:String = "BTRandomSelector"
						item.set_text(0,bt_node_text)
						item.set_meta("parameter_values", [bt_node_text])
						item.set_meta("description", BattleDictionary.valid_bt_composites[2][1])
						new_branch = item
				"BTRandomSequence":
					if tree.get_root() == null:
						var item = tree.create_item()
						var bt_node_text:String = "BTRandomSequence"
						item.set_text(0,bt_node_text)
						item.set_meta("parameter_values", [bt_node_text])
						item.set_meta("description", BattleDictionary.valid_bt_composites[3][1])
						new_branch = item
					else:
						var item = tree.create_item(branch)
						var bt_node_text:String = "BTRandomSequence"
						item.set_text(0,bt_node_text)
						item.set_meta("parameter_values", [bt_node_text])
						item.set_meta("description", BattleDictionary.valid_bt_composites[3][1])
						new_branch = item
				#Decorators
				"BTInvert":
					var item = tree.create_item(branch)
					var bt_node_text:String = "BTInvert"
					item.set_text(0,bt_node_text)
					item.set_meta("parameter_values", [bt_node_text])
					item.set_meta("description", BattleDictionary.valid_bt_decorators[0][1])
					new_branch = item
				"BTAlwaysSucceed":
					var item = tree.create_item(branch)
					var bt_node_text:String = "BTAlwaysSucceed"
					item.set_text(0,bt_node_text)
					item.set_meta("parameter_values", [bt_node_text])
					item.set_meta("description", BattleDictionary.valid_bt_decorators[1][1])
					new_branch = item
				"BTAlwaysFail":
					var item = tree.create_item(branch)
					var bt_node_text:String = "BTAlwaysFail"
					item.set_text(0,bt_node_text)
					item.set_meta("parameter_values", [bt_node_text])
					item.set_meta("description", BattleDictionary.valid_bt_decorators[2][1])
					new_branch = item
				"BTRepeat":
					var item = tree.create_item(branch)
					var bt_node_text:String = "BTRepeat"
					item.set_text(0,bt_node_text)
					item.set_meta("description", BattleDictionary.valid_bt_decorators[3][1])
					item.set_meta("parameters", BattleDictionary.valid_bt_decorators[3][2])
					item.set_meta("parameter_values", [bt_node_text,bt_node_array[bt_node+1]])
					new_branch = item
				"BTRepeatUntil":
					var item = tree.create_item(branch)
					var bt_node_text:String = "BTRepeatUntil"
					item.set_text(0,bt_node_text)
					item.set_meta("description", BattleDictionary.valid_bt_decorators[4][1])
					item.set_meta("parameters", BattleDictionary.valid_bt_decorators[4][2])
					item.set_meta("parameter_values", [bt_node_text,bt_node_array[bt_node+1]])
					new_branch = item
				"BTCheckLastCard":
					var item = tree.create_item(branch)
					var bt_node_text:String = "BTCheckLastCard"
					item.set_text(0,bt_node_text)
					item.set_meta("description", BattleDictionary.valid_bt_decorators[5][1])
					item.set_meta("parameters", BattleDictionary.valid_bt_decorators[5][2])
					item.set_meta("parameter_values", [bt_node_text,bt_node_array[bt_node+1],bt_node_array[bt_node+2],bt_node_array[bt_node+3]])
					new_branch = item
				"BTConditional":
					var item = tree.create_item(branch)
					var bt_node_text:String = "BTConditional"
					item.set_text(0,bt_node_text)
					item.set_meta("description", BattleDictionary.valid_bt_decorators[6][1])
					item.set_meta("parameters", BattleDictionary.valid_bt_decorators[6][2])
					item.set_meta("parameter_values", [bt_node_text,bt_node_array[bt_node+1],bt_node_array[bt_node+2]])
					new_branch = item
				"BTPercentSucceed":
					var item = tree.create_item(branch)
					var bt_node_text:String = "BTPercentSucceed"
					item.set_text(0,bt_node_text)
					item.set_meta("description", BattleDictionary.valid_bt_decorators[7][1])
					item.set_meta("parameters", BattleDictionary.valid_bt_decorators[7][2])
					item.set_meta("parameter_values", [bt_node_text,bt_node_array[bt_node+1],bt_node_array[bt_node+2]])
					new_branch = item
				#Leaves
				"Attack":
					var item = tree.create_item(branch)
					var bt_node_text:String = "Attack"
					item.set_text(0,bt_node_text)
					item.set_meta("description", BattleDictionary.valid_bt_leaves[0][1])
					item.set_meta("parameters", BattleDictionary.valid_bt_leaves[0][2])
					item.set_meta("parameter_values", [bt_node_text,bt_node_array[bt_node+1]])
				"SetSingleTarget":
					var item = tree.create_item(branch)
					var bt_node_text:String = "SetSingleTarget"
					item.set_text(0,bt_node_text)
					item.set_meta("description", BattleDictionary.valid_bt_leaves[1][1])
					item.set_meta("parameters", BattleDictionary.valid_bt_leaves[1][2])
					item.set_meta("parameter_values", [bt_node_text,bt_node_array[bt_node+1],bt_node_array[bt_node+2]])
				"SetSplashTargets":
					var item = tree.create_item(branch)
					var bt_node_text:String = "SetSplashTargets"
					item.set_text(0,bt_node_text)
					item.set_meta("description", BattleDictionary.valid_bt_leaves[2][1])
					item.set_meta("parameters", BattleDictionary.valid_bt_leaves[2][2])
					item.set_meta("parameter_values", [bt_node_text,bt_node_array[bt_node+1],bt_node_array[bt_node+2],bt_node_array[bt_node+3],bt_node_array[bt_node+4],bt_node_array[bt_node+5],bt_node_array[bt_node+6]])
				"SetInlineTargets":
					var item = tree.create_item(branch)
					var bt_node_text:String = "SetInlineTargets"
					item.set_text(0,bt_node_text)
					item.set_meta("description", BattleDictionary.valid_bt_leaves[3][1])
					item.set_meta("parameters", BattleDictionary.valid_bt_leaves[3][2])
					item.set_meta("parameter_values", [bt_node_text,bt_node_array[bt_node+1],bt_node_array[bt_node+2],bt_node_array[bt_node+3],bt_node_array[bt_node+4],bt_node_array[bt_node+5]])
				"SetLeftRightTargets":
					var item = tree.create_item(branch)
					var bt_node_text:String = "SetLeftRightTargets"
					item.set_text(0,bt_node_text)
					item.set_meta("description", BattleDictionary.valid_bt_leaves[4][1])
					item.set_meta("parameters", BattleDictionary.valid_bt_leaves[4][2])
					item.set_meta("parameter_values", [bt_node_text,bt_node_array[bt_node+1],bt_node_array[bt_node+2],bt_node_array[bt_node+3],bt_node_array[bt_node+4],bt_node_array[bt_node+5]])
				"ClearTargets":
					var item = tree.create_item(branch)
					var bt_node_text:String = "ClearTargets"
					item.set_text(0,bt_node_text)
					item.set_meta("description", BattleDictionary.valid_bt_leaves[5][1])
					item.set_meta("parameter_values", [bt_node_text])
				"SetIntArg":
					var item = tree.create_item(branch)
					var bt_node_text:String = "SetIntArg"
					item.set_text(0,bt_node_text)
					item.set_meta("description", BattleDictionary.valid_bt_leaves[6][1])
					item.set_meta("parameters", BattleDictionary.valid_bt_leaves[6][2])
					item.set_meta("parameter_values", [bt_node_text,bt_node_array[bt_node+1],bt_node_array[bt_node+2],bt_node_array[bt_node+3],bt_node_array[bt_node+4],bt_node_array[bt_node+5],bt_node_array[bt_node+6]])
#				"SetStatus":
#					var item = tree.create_item(branch)
#					var bt_node_text:String = "SetStatus"
#					item.set_text(0,bt_node_text)
#					item.set_meta("description", BattleDictionary.valid_bt_leaves[7][1])
#					item.set_meta("parameter_values", [bt_node_text])
				"CasterAddStatus":
					var item = tree.create_item(branch)
					var bt_node_text:String = "CasterAddStatus"
					item.set_text(0,bt_node_text)
					item.set_meta("description", BattleDictionary.valid_bt_leaves[7][1])
					item.set_meta("parameters", BattleDictionary.valid_bt_leaves[7][2])
					item.set_meta("parameter_values", [bt_node_text,bt_node_array[bt_node+1],bt_node_array[bt_node+2]])
				"TargetAddStatus":
					var item = tree.create_item(branch)
					var bt_node_text:String = "TargetAddStatus"
					item.set_text(0,bt_node_text)
					item.set_meta("description", BattleDictionary.valid_bt_leaves[8][1])
					item.set_meta("parameters", BattleDictionary.valid_bt_leaves[8][2])
					item.set_meta("parameter_values", [bt_node_text,bt_node_array[bt_node+1],bt_node_array[bt_node+2],bt_node_array[bt_node+3]])
				"CasterDrawCard":
					var item = tree.create_item(branch)
					var bt_node_text:String = "CasterDrawCard"
					item.set_text(0,bt_node_text)
					item.set_meta("description", BattleDictionary.valid_bt_leaves[9][1])
					item.set_meta("parameters", BattleDictionary.valid_bt_leaves[9][2])
					item.set_meta("parameter_values", [bt_node_text,bt_node_array[bt_node+1],bt_node_array[bt_node+2],bt_node_array[bt_node+3],bt_node_array[bt_node+4],bt_node_array[bt_node+5],bt_node_array[bt_node+6]])
				"TargetDrawCard":
					var item = tree.create_item(branch)
					var bt_node_text:String = "TargetDrawCard"
					item.set_text(0,bt_node_text)
					item.set_meta("description", BattleDictionary.valid_bt_leaves[10][1])
					item.set_meta("parameters", BattleDictionary.valid_bt_leaves[10][2])
					item.set_meta("parameter_values", [bt_node_text,bt_node_array[bt_node+1],bt_node_array[bt_node+2],bt_node_array[bt_node+3],bt_node_array[bt_node+4],bt_node_array[bt_node+5],bt_node_array[bt_node+6],bt_node_array[bt_node+7]])
				"CasterModifyStat":
					var item = tree.create_item(branch)
					var bt_node_text:String = BattleDictionary.valid_bt_leaves[11][0]
					item.set_text(0,bt_node_text)
					item.set_meta("description", BattleDictionary.valid_bt_leaves[11][1])
					item.set_meta("parameters", BattleDictionary.valid_bt_leaves[11][2])
					item.set_meta("parameter_values", [bt_node_text,bt_node_array[bt_node+1],bt_node_array[bt_node+2],bt_node_array[bt_node+3],bt_node_array[bt_node+4]])
				"TargetModifyStat":
					var item = tree.create_item(branch)
					var bt_node_text:String = BattleDictionary.valid_bt_leaves[12][0]
					item.set_text(0,bt_node_text)
					item.set_meta("description", BattleDictionary.valid_bt_leaves[12][1])
					item.set_meta("parameters", BattleDictionary.valid_bt_leaves[12][2])
					item.set_meta("parameter_values", [bt_node_text,bt_node_array[bt_node+1],bt_node_array[bt_node+2],bt_node_array[bt_node+3],bt_node_array[bt_node+4],bt_node_array[bt_node+5]])
				"CasterModifyStatDuration":
					var item = tree.create_item(branch)
					var bt_node_text:String = BattleDictionary.valid_bt_leaves[13][0]
					item.set_text(0,bt_node_text)
					item.set_meta("description", BattleDictionary.valid_bt_leaves[13][1])
					item.set_meta("parameters", BattleDictionary.valid_bt_leaves[13][2])
					item.set_meta("parameter_values", [bt_node_text,bt_node_array[bt_node+1],bt_node_array[bt_node+2],bt_node_array[bt_node+3],bt_node_array[bt_node+4],bt_node_array[bt_node+5]])
				"TargetModifyStatDuration":
					var item = tree.create_item(branch)
					var bt_node_text:String = BattleDictionary.valid_bt_leaves[14][0]
					item.set_text(0,bt_node_text)
					item.set_meta("description", BattleDictionary.valid_bt_leaves[14][1])
					item.set_meta("parameters", BattleDictionary.valid_bt_leaves[14][2])
					item.set_meta("parameter_values", [bt_node_text,bt_node_array[bt_node+1],bt_node_array[bt_node+2],bt_node_array[bt_node+3],bt_node_array[bt_node+4],bt_node_array[bt_node+5],bt_node_array[bt_node+6]])
				"CasterAddCard":
					var item = tree.create_item(branch)
					var bt_node_text:String = BattleDictionary.valid_bt_leaves[15][0]
					item.set_text(0,bt_node_text)
					item.set_meta("description", BattleDictionary.valid_bt_leaves[15][1])
					item.set_meta("parameters", BattleDictionary.valid_bt_leaves[15][2])
					item.set_meta("parameter_values", [bt_node_text,bt_node_array[bt_node+1],bt_node_array[bt_node+2],bt_node_array[bt_node+3],bt_node_array[bt_node+4]])
				"TargetAddCard":
					var item = tree.create_item(branch)
					var bt_node_text:String = BattleDictionary.valid_bt_leaves[16][0]
					item.set_text(0,bt_node_text)
					item.set_meta("description", BattleDictionary.valid_bt_leaves[16][1])
					item.set_meta("parameters", BattleDictionary.valid_bt_leaves[16][2])
					item.set_meta("parameter_values", [bt_node_text,bt_node_array[bt_node+1],bt_node_array[bt_node+2],bt_node_array[bt_node+3],bt_node_array[bt_node+4],bt_node_array[bt_node+5]])
				"HandModifyStat":
					var item = tree.create_item(branch)
					var bt_node_text:String = BattleDictionary.valid_bt_leaves[17][0]
					item.set_text(0,bt_node_text)
					item.set_meta("description", BattleDictionary.valid_bt_leaves[17][1])
					item.set_meta("parameters", BattleDictionary.valid_bt_leaves[17][2])
					item.set_meta("parameter_values", [bt_node_text,bt_node_array[bt_node+1],bt_node_array[bt_node+2],bt_node_array[bt_node+3],bt_node_array[bt_node+4],bt_node_array[bt_node+5],bt_node_array[bt_node+6]])
				"CardModifyStat":
					var item = tree.create_item(branch)
					var bt_node_text:String = BattleDictionary.valid_bt_leaves[18][0]
					item.set_text(0,bt_node_text)
					item.set_meta("description", BattleDictionary.valid_bt_leaves[18][1])
					item.set_meta("parameters", BattleDictionary.valid_bt_leaves[18][2])
					item.set_meta("parameter_values", [bt_node_text,bt_node_array[bt_node+1],bt_node_array[bt_node+2],bt_node_array[bt_node+3],bt_node_array[bt_node+4]])
				"Pull":
					var item = tree.create_item(branch)
					var bt_node_text:String = BattleDictionary.valid_bt_leaves[19][0]
					item.set_text(0,bt_node_text)
					item.set_meta("description", BattleDictionary.valid_bt_leaves[19][1])
					item.set_meta("parameters", BattleDictionary.valid_bt_leaves[19][2])
					item.set_meta("parameter_values", [bt_node_text,bt_node_array[bt_node+1],bt_node_array[bt_node+2]])
				"Push":
					var item = tree.create_item(branch)
					var bt_node_text:String = BattleDictionary.valid_bt_leaves[20][0]
					item.set_text(0,bt_node_text)
					item.set_meta("description", BattleDictionary.valid_bt_leaves[20][1])
					item.set_meta("parameters", BattleDictionary.valid_bt_leaves[20][2])
					item.set_meta("parameter_values", [bt_node_text,bt_node_array[bt_node+1],bt_node_array[bt_node+2]])


func _on_ItemAP_toggled(button_pressed):
	get_node("ScrollContainer/VBoxContainer/ActionCost/DeltaAP").visible = button_pressed
	get_node("ScrollContainer/VBoxContainer/ActionCost/ActionCost").visible = !button_pressed
	if button_pressed:
		get_node("ScrollContainer/VBoxContainer/ActionCost/Label").text = "AP Cost Difference"
	else:
		get_node("ScrollContainer/VBoxContainer/ActionCost/Label").text = "AP Cost"
		get_node("ScrollContainer/VBoxContainer/ActionCost/DeltaAP").value = 0


func _on_ItemDamage_toggled(button_pressed):
	get_node("ScrollContainer/VBoxContainer/Damage/DeltaDamage").visible = button_pressed
	get_node("ScrollContainer/VBoxContainer/Damage/Damage").visible = !button_pressed
	if button_pressed:
		get_node("ScrollContainer/VBoxContainer/Damage/Label").text = "Damage Percentage Modifier"
	else:
		get_node("ScrollContainer/VBoxContainer/Damage/Label").text = "Damage"
		get_node("ScrollContainer/VBoxContainer/Damage/DeltaDamage").value = 0
