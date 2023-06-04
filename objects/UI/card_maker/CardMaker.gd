extends Control

class_name CardMaker

var card_tab_prefab = preload("res://objects/UI/card_maker/CardTab.tscn")
var card_item_type_option = preload("res://objects/UI/card_maker/CardItemTypeOption.tscn")
const CARD_ART_DIR:String = "res://assets/images/card_art/"
const CARD_SAVE_DIR:String = "user://cards/"
var card_list:Array

enum CARD_CLASS {WARRIOR,RANGER,MAGE,WARRIORRANGER,RANGERMAGE,MAGEWARRIOR,ALL}
enum CARD_TYPE {OFFENSE,DEFENSE,UTILITY}

onready var cardPanel = get_node("CardPanel")
onready var cardList = get_node("CardListContainer/CardList/VBoxContainer")
onready var tab_container = get_node("CardPanel/TabContainer")
onready var add_item = get_node("BehaviorTree/AddItem")
onready var tree = get_node("Tree")
onready var current_tree

onready var card_class_node = get_node("CardPanel/ScrollContainer/HBoxContainer/CardClass")
onready var card_type_node = get_node("CardPanel/ScrollContainer/HBoxContainer/CardType")
onready var item_type_node = get_node("CardPanel/ScrollContainer/HBoxContainer/HBoxContainer/ItemType")
onready var bt_node_list = get_node("BTNodeList")
onready var bt_node_list_contents = get_node("BTNodeList/ScrollContainer/VBoxContainer")
onready var bt_node = get_node("BTNode")
onready var bt_node_contents = get_node("BTNode/ScrollContainer/VBoxContainer")
onready var bt_node_dialog:BTNodeDialog = get_node("BTNodeDialog")
onready var test_card_dialog = get_node("CardPanel/TestCard/TestCardAcceptDialog")
onready var menu_dialog = get_node("MenuControl/Menu/MenuAcceptDialog")

var card_info

# -------------------------------- #

func _ready():
	test_card_dialog.add_cancel("Cancel")
	var menu_cancel = menu_dialog.add_cancel("Don't Save")
	menu_cancel.connect("pressed",self,"menuAcceptNoSave")
	populateCards()
	populateBTNodes()
	for i in CARD_CLASS:
		card_class_node.add_item(i)
	for i in CARD_TYPE:
		card_type_node.add_item(i)
	for i in BattleDictionary.item_type:
		item_type_node.add_item(i)
	current_tree = tab_container.get_tab_control(0).tree
	setupDefaultTree()
	get_tree().get_root().connect("size_changed", self, "update_position")
	update_position()

func update_position():
	rect_size = get_viewport().size
	$BG.rect_size = rect_size
	$MenuControl.rect_position = Vector2(rect_size.x - $MenuControl.rect_size.x, 0)

func openCardMaker() -> void:
	pass
#	populateCards()
#	populateBTNodes()
#	for i in CARD_CLASS:
#		card_class_node.add_item(i)
#	for i in CARD_TYPE:
#		card_type_node.add_item(i)
#	current_tree = tab_container.get_tab_control(0).tree
#	setupDefaultTree()

func populateCards() -> void:
	for button in cardList.get_children():
		cardList.remove_child(button)
		button.queue_free()
	card_list = CardLoader.loadCardList(false)
	if card_list != null and card_list.size() > 0:
		for i in card_list.size():
			var new_button = Button.new()
			new_button.text = card_list[i]
			new_button.hint_tooltip = card_list[i]
			cardList.add_child(new_button)
			new_button.set_meta("index", i)
			new_button.connect("pressed",self,"loadCardInfo",[card_list[i]])

func populateBTNodes() -> void:
	var composites:Array = BattleDictionary.valid_bt_composites
	var decorators:Array = BattleDictionary.valid_bt_decorators
	var leaves:Array = BattleDictionary.valid_bt_leaves
	var label:Label = Label.new()
	label.text = "Composites"
	label.hint_tooltip = "Requires a child BTLeaf"
	bt_node_list_contents.add_child(label)
	for i in composites.size():
		var new_button = Button.new()
		new_button.text = composites[i][0]
		new_button.hint_tooltip = composites[i][1]
		bt_node_list_contents.add_child(new_button)
		if composites[i].size() > 2:
			new_button.connect("pressed",self,"popupBTNode",[composites[i][0],composites[i][1],composites[i][2],[],false])
		else:
			new_button.connect("pressed",self,"addBTNode",[composites[i][0],composites[i][1]])
	var label2:Label = Label.new()
	label2.text = "Decorators"
	label2.hint_tooltip = "Requires a child BTLeaf"
	bt_node_list_contents.add_child(label2)
	for i in decorators.size():
		var new_button = Button.new()
		new_button.text = decorators[i][0]
		new_button.hint_tooltip = decorators[i][1]
		bt_node_list_contents.add_child(new_button)
		if decorators[i].size() > 2:
			new_button.connect("pressed",self,"popupBTNode",[decorators[i][0],decorators[i][1],decorators[i][2],[],false])
		else:
			new_button.connect("pressed",self,"addBTNode",[decorators[i][0],decorators[i][1]])
	var label3:Label = Label.new()
	label3.text = "Leaves"
	label3.hint_tooltip = "Used for various card mechanics."
	bt_node_list_contents.add_child(label3)
	for i in leaves.size():
		var new_button = Button.new()
		new_button.text = str(leaves[i][0])
		new_button.hint_tooltip = str(leaves[i][1])
		bt_node_list_contents.add_child(new_button)
		if leaves[i].size() > 2:
			new_button.connect("pressed",self,"popupBTNode",[leaves[i][0],leaves[i][1],leaves[i][2],[],false])
		else:
			new_button.connect("pressed",self,"addBTNode",[leaves[i][0],leaves[i][1]])

func _on_Button_pressed():
	reset()

func _on_CardArt_pressed():
	pass # Replace with function body.

func _on_AddLevel_pressed():
	var prev_tab = tab_container.get_child(tab_container.current_tab)
	var new_tab = prev_tab.duplicate()
	new_tab.makeDupe()
	new_tab.name = "Level " + str(tab_container.get_child_count() + 1)
	tab_container.add_child(new_tab)
	new_tab.loadTreeItem(new_tab.tree.get_root(), prev_tab.convertTreeToArray(prev_tab.tree))
	prev_tab.card_upgrade.visible = true
	new_tab.card_upgrade.visible = false
	tab_container.get_child(tab_container.get_child_count()-2).card_upgrade.visible = true


func _on_RemoveLevel_pressed():
	if tab_container.get_child_count() > 1:
		var index = tab_container.current_tab
		tab_container.get_child(index).queue_free()
		yield(get_tree().create_timer(.01),"timeout")
		yield(get_tree(),"idle_frame")
#		tab_container.get_child(0).card_upgrade.visible = false
		var new_index = tab_container.current_tab + 1
		tab_container.get_child(tab_container.current_tab).name = "Level " + str(new_index)
		while new_index < tab_container.get_child_count():
			tab_container.get_child(new_index).name = "Level " + str(new_index + 1)
			new_index += 1
	#tab_container.get_child(tab_container.get_child_count()-1).card_upgrade.visible = false

func setupDefaultTree() -> void:
	var root = current_tree.create_item(null)
	root.set_text(0,"BTSequence")
	root.set_meta("description", "Ticks its children as long as ALL of them are successful.\nFails if ANY of the children fails.")
	root.set_meta("parameter_values", ["BTSequence"])

#func _on_AddItem_pressed():
#	bt_node_list.popup_centered()
#
#
#func _on_Tree_nothing_selected():
#	if tree.get_selected() != null:
#		tree.get_selected().deselect(0)
#
#
#func _on_RemoveItem_pressed():
#	if tree.get_selected() != null and tree.get_selected() != tree.get_root():
#		tree.get_selected().free()
#	tree.grab_focus()
#
#
#func _on_Tree_item_activated():
#	var selected = tree.get_selected()
#	if selected != tree.get_root():
#		var node_name:String = selected.get_text(0)
#		popupBTNode(node_name,selected.get_meta("description"), selected.get_meta("parameters"), selected.get_meta("parameter_values"), true)

func popupBTNode(btnode, description, params, values, is_edit = false) -> void:
	bt_node_dialog.newBTContainer(btnode,description,values,is_edit)
	bt_node_dialog.popup_centered()

func addBTNode(btnode, description, params = null, param_values = null):
	if current_tree.get_root() == null:
		var root = current_tree.create_item(null)
		root.set_text(0,btnode)
		root.select(0)
	elif current_tree.get_selected() != null:
		var item = current_tree.create_item(current_tree.get_selected())
		item.set_text(0,btnode)
		item.set_meta("description", description)
		item.set_meta("parameters", params)
		item.set_meta("parameter_values", [btnode])
	elif current_tree.get_selected() == null:
		var item = current_tree.create_item(current_tree.get_root())
		item.set_text(0,btnode)
		item.set_meta("description", description)
		item.set_meta("parameters", params)
		item.set_meta("parameter_values", [btnode])

#func addBTNode(btnode, description, params = null, param_values = null):
#	if tree.get_root() == null:
#		var root = tree.create_item(null)
#		root.set_text(0,btnode)
#		root.select(0)
#	elif tree.get_selected() != null:
#		var item = tree.create_item(tree.get_selected())
#		item.set_text(0,btnode)
#		item.set_meta("description", description)
#		item.set_meta("parameters", params)
#		item.set_meta("parameter_values", [btnode])
#	elif tree.get_selected() == null:
#		var item = tree.create_item(tree.get_root())
#		item.set_text(0,btnode)
#		item.set_meta("description", description)
#		item.set_meta("parameters", params)
#		item.set_meta("parameter_values", [btnode])
#
#func editBTNode(btnode, description, params = null, param_values = null) -> void:
#	if tree.get_selected() != null and tree.get_selected().is_selected(0):
#		var item = tree.get_selected()
#		item.set_text(0,btnode)
#		item.set_meta("description", description)
#		item.set_meta("parameters", params)
#		if param_values != null:
#			item.set_meta("parameter_values",extractParamValuesToArray(param_values))
#		else:
#			item.set_meta("parameter_values",extractParamValuesToArray([btnode]))
#
#func extractParamValuesToArray(params) -> Array:
#	var parameter_values:Array = []
#	var output:String
#	if params is Array:
#		for i in params.size():
#			if params[i] is String:
#				parameter_values.append(params[i])
#			if params[i] is SpinBox:
#				parameter_values.append(int(params[i].value))
#			if params[i] is CardVariableOption:
#				parameter_values.append(params[i].get_item_text(params[i].selected))
#				if params[i].selected == 0:
#					parameter_values.append(0)
#				continue
#			if params[i] is UnitDeckOption:
#				parameter_values.append(params[i].get_item_text(params[i].selected))
#				continue
#			if params[i] is UnitVariableOption:
#				parameter_values.append(params[i].get_item_text(params[i].selected))
#				continue
#			if params[i] is OptionButton:
#				parameter_values.append(int(params[i].selected))
#			if params[i] is HBoxContainer:
#				for vis in params[i].get_children():
#					if vis.visible == true:
#						if vis is SpinBox:
#							parameter_values.append(int(vis.value))
#						elif vis is CardNameOption:
#							parameter_values.append(vis.get_item_text(vis.selected))
#						else:
#							parameter_values.append(int(vis.selected))
#	return parameter_values

func moveItemUp() -> void:
	var item:TreeItem = tree.get_selected()
	var item_list:Array = tree_item_get_list(item)
	if tree_item_get_index(item) == 0:
		if item.get_parent() == tree.get_root():
			return
		else:
			var new_item = tree.create_item(item.get_parent().get_parent())
			new_item.set_text(0,item.get_text(0))
			new_item.set_meta("description", item.get_meta("description"))
			new_item.set_meta("parameters", item.get_meta("parameters"))
			new_item.set_meta("parameter_values", item.get_meta("parameter_values"))
			item.free()
			return
	if tree_item_get_index(item) == tree_item_get_list(item).size()-1:
		item.get_prev().move_to_bottom()
	elif tree_item_get_index(item) != 0:
		for i in range(tree_item_get_index(item.get_prev()),item_list.size()):
			if item_list[i] != item:
				item_list[i].move_to_bottom()

func moveItemDown() -> void:
	var item:TreeItem = tree.get_selected()
	var item_list:Array = tree_item_get_list(item)
	if tree_item_get_index(item) == item_list.size() -1:
		return
	if tree_item_get_index(item) == 0:
		item.get_next().move_to_top()
	elif tree_item_get_index(item) != tree_item_get_list(item).size()-1:
		for i in range(tree_item_get_index(item.get_next()),-1,-1):
			if item_list[i] != item:
				item_list[i].move_to_top()

func tree_item_get_count(item:TreeItem) -> int:
	var count:int = 1
	var down:TreeItem = item
	var up:TreeItem = item
	while down.get_next() != null:
		count += 1
		down = down.get_next()
	while up.get_prev() != null:
		count += 1
		up = up.get_prev()
	return count

func tree_item_get_list(item:TreeItem) -> Array:
	var item_list:Array = []
	var current:TreeItem = item
	if current != null:
		while current.get_prev() != null:
			current = current.get_prev()
		while current.get_next() != null:
			item_list.append(current)
			current = current.get_next()
		item_list.append(current)
	return item_list

func tree_item_get_index(item:TreeItem) -> int:
	var count:int = 0
	var up:TreeItem = item
	if up != null:
		while up.get_prev() != null:
			count += 1
			up = up.get_prev()
	return count


#func _on_PrintTree_pressed():
#	print(convertTreeToArray(tree))

func print_items(tree_item:TreeItem) -> String:
	var output:String = "[" + str(tree_item.get_text(0))
	if tree_item.get_children() != null:
		tree_item = tree_item.get_children()
		output += ", " + print_items(tree_item)
	while tree_item.get_next() != null:
		tree_item = tree_item.get_next()
		output += ", " + str(tree_item.get_text(0))
		var last_item = tree_item
		if tree_item.get_children() != null:
			tree_item = tree_item.get_children()
			output += ", " + print_items(tree_item)
			tree_item = last_item
	if tree_item.get_next() == null:
		output += "]"
	return output

func loadCardInfo(card:String) -> void:
	card_info = CardLoader.loadSingleCardFile(card,false)
	$CardPanel/CardName.text = card_info.card_name
	$CardPanel/ScrollContainer/HBoxContainer/CardClass.selected = card_info.card_class
	$CardPanel/ScrollContainer/HBoxContainer/CardType.selected = card_info.card_type
	#item_type_node.selected = card_info.item_type
	$CardPanel/ScrollContainer/HBoxContainer/IgnoreItemStats.pressed = card_info.ignore_item_stats
	$CardPanel/ScrollContainer/HBoxContainer/RarityValue.value = card_info.rarity
	$CardPanel/HBoxContainer2/CardArt.set_meta("file_name", card_info.card_art)
	$CardPanel/HBoxContainer2/CardIcon/TextureRect.texture = load(card_info.card_icon)
	$CardPanel/ScrollContainer/HBoxContainer/BypassPopup.pressed = card_info.bypass_popup
	resetTabs()
	yield(get_tree().create_timer(0.1),"timeout")
	yield(get_tree(),"idle_frame")
	populateTabs(card_info)
	current_tree = tab_container.get_tab_control(0).tree
#	tree.clear()
	for i in tab_container.get_child_count():
		var tab = tab_container.get_tab_control(i)
#		tab.loadTreeItem(tab.tree.get_root(), card_info.behavior_tree)
		if card_info.behavior_trees.size() == 0:
			tab.loadTreeItem(tab.tree.get_root(), card_info.behavior_tree)
		else:
			tab.loadTreeItem(tab.tree.get_root(), card_info.behavior_trees[i])
	for i in get_node("CardPanel/ScrollContainer/HBoxContainer/HBoxContainer").get_children():
		if i != get_node("CardPanel/ScrollContainer/HBoxContainer/HBoxContainer").get_child(0):
			i.call_deferred("queue_free")
		else:
			i.selected = 0
	for i in card_info.item_type.size():
		get_node("CardPanel/ScrollContainer/HBoxContainer/HBoxContainer").get_child(i).selected = card_info.item_type[i]
	if !card_info.item_type.empty():
		if card_info.item_type[max(0,card_info.item_type.size()-1)] != 0:
			addCardItemTypeOption()

func resetTabs() -> void:
	for old_tabs in tab_container.get_children():
		old_tabs.call_deferred("queue_free")

func populateTabs(card_info:Dictionary) -> void:
	var num_levels:int = card_info.upgrade_costs.size()
	for i in range(num_levels):
		var new_tab = card_tab_prefab.instance()
		tab_container.add_child(new_tab)
		new_tab.name = "Level " + str(i+1)
		new_tab.card_upgrade_value.value = card_info.upgrade_costs[i]
		new_tab.card_action_cost.value = card_info.action_costs[i]
		new_tab.card_damage_label.text = "Damage" if card_info.ignore_item_stats else "Damage Multiplier"
		new_tab.card_damage.value = card_info.card_attack[i]
		new_tab.card_damage.hint_tooltip = "Base damage dealt to target. (Negative values will heal target)" if card_info.ignore_item_stats else "Damage Multiplier of the Item's Base Damage"
		new_tab.card_action_cost_label.text = "AP Cost" if card_info.ignore_item_stats else "Added AP Cost"
		new_tab.card_action_cost.hint_tooltip = "Base AP cost." if card_info.ignore_item_stats else "Added AP on top of Item's base AP cost."
		new_tab.card_delay.value = card_info.delay[i]
		new_tab.card_min_range.value = card_info.card_min_range[i]
		new_tab.card_max_range.value = card_info.card_max_range[i]
		new_tab.card_up_range.value = card_info.card_up_vertical_range[i]
		new_tab.card_down_range.value = card_info.card_down_vertical_range[i]
		new_tab.card_added_accuracy.value = card_info.card_added_accuracy[i]
		new_tab.card_added_crit_accuracy.value = card_info.card_added_crit_accuracy[i]
		new_tab.card_element.selected = card_info.elements[i][0]
		if card_info.elements[i].size() > 1:
			new_tab.card_element2.selected = card_info.elements[i][1]
		if card_info.elements[i].size() > 2:
			new_tab.card_element3.selected = card_info.elements[i][2]
		for j in card_info.self_statuses[i].size():
			if card_info.self_statuses[i][j][0] != null:
				new_tab.addSelfStatusOption()
				new_tab.self_statuses.get_child(j+1).selected = card_info.self_statuses[i][j][0]
			if card_info.self_statuses[i][j][1] != null:
				new_tab.self_statuses.get_child(j+1).spin_box.value = card_info.self_statuses[i][j][1]
		for j in card_info.target_statuses[i].size():
			if card_info.target_statuses[i][j][0] != null:
				new_tab.addTargetStatusOption()
				new_tab.target_statuses.get_child(j+1).selected = card_info.target_statuses[i][j][0]
			if card_info.target_statuses[i][j][1] != null:
				new_tab.target_statuses.get_child(j+1).spin_box.value = card_info.target_statuses[i][j][1]
		for j in card_info.prerequisites[i].size():
			if card_info.prerequisites[i][j][0] != null:
				new_tab._on_AddPrerequisite_pressed()
				new_tab.prerequisites.get_child(j+1).get_child(0).selected = BattleDictionary.unit_int_vars.find(card_info.prerequisites[i][j][0])
			if card_info.prerequisites[i][j][1] != null:
				new_tab.prerequisites.get_child(j+1).get_child(1).value = card_info.prerequisites[i][j][1]
			if card_info.prerequisites[i][j][2] != null:
				new_tab.prerequisites.get_child(j+1).get_child(2).pressed = card_info.prerequisites[i][j][2]
		new_tab.card_action.pressed = card_info.can_attack[i]
		new_tab.card_reaction.pressed = card_info.can_defend[i]
		new_tab.card_need_los.pressed = card_info.need_los[i]
		new_tab.card_piercing.pressed = card_info.is_piercing[i]
		new_tab.card_consumable.pressed = card_info.is_consumable[i]
		new_tab.card_homing.pressed = card_info.is_homing[i]
		new_tab.card_combo.pressed = card_info.has_combo[i]
		new_tab.card_counter.pressed = card_info.has_counter[i]
		new_tab.card_reflex.pressed = card_info.has_reflex[i]
		new_tab.card_self_eliminating.pressed = card_info.self_eliminating[i]
		new_tab.card_hexagonal_targeting.pressed = card_info.hexagonal_targeting[i]
		if typeof(card_info.card_animation[i][0]) == TYPE_INT:
			new_tab.card_animation.selected = card_info.card_animation[i][0]
		if typeof(card_info.card_animation[i][1]) == TYPE_INT:
			new_tab.card_animation2.selected = card_info.card_animation[i][1]
		if card_info.has("card_animation_left_weapon"):
			if typeof(card_info.card_animation_left_weapon[i]) == TYPE_INT:
				new_tab.card_animation_left_weapon.selected = int(card_info.card_animation_left_weapon[i])
			if typeof(card_info.card_animation_right_weapon[i]) == TYPE_INT:
				new_tab.card_animation_right_weapon.selected = int(card_info.card_animation_right_weapon[i])
		new_tab.card_counter_anim_tandem.pressed = card_info.card_counter_anim_tandem[i]
		new_tab.card_description.text = card_info.description[i]

func _on_SaveCard_pressed() -> void:
	var card_name:String = $CardPanel/CardName.text
	var card_class = $CardPanel/ScrollContainer/HBoxContainer/CardClass.selected
	var card_level:int = 0
	var rarity:int = $CardPanel/ScrollContainer/HBoxContainer/RarityValue.value
#	var card_art:String = $CardPanel/ScrollContainer/HBoxContainer/CardArt.get_meta("file_name")
	var card_art:String = "empty.png"
	var card_icon:String = $CardPanel/HBoxContainer2/CardIcon/TextureRect.texture.resource_path
	var card_type:int = $CardPanel/ScrollContainer/HBoxContainer/CardType.selected
	var item_type:Array = []
	for item_option in $CardPanel/ScrollContainer/HBoxContainer/HBoxContainer.get_children():
		if item_option.selected != 0:
			item_type.append(item_option.selected)
	var bypass_popup:bool = $CardPanel/ScrollContainer/HBoxContainer/BypassPopup.pressed
	var ignore_item_stats:bool = $CardPanel/ScrollContainer/HBoxContainer/IgnoreItemStats.pressed
	#-------------------------
	var action_costs:Array = []
	var upgrade_costs:Array = []
	var can_attack:Array = []
	var can_defend:Array = []
	var need_los:Array = []
	var is_homing:Array = []
	var has_combo:Array = []
	var is_piercing:Array = []
	var is_shattering:Array = []
	var is_consumable:Array = []
	var has_counter:Array = []
	var has_reflex:Array = []
	var self_eliminating:Array = []
	var hexagonal_targeting:Array = []
	var self_statuses:Array = []
	var target_statuses:Array = []
	var prerequisites:Array = []
	var delay:Array = []
	var description:PoolStringArray = []
	var card_min_range:Array = []
	var card_max_range:Array = []
	var card_up_vertical_range:Array = []
	var card_down_vertical_range:Array = []
	var card_added_accuracy:Array = []
	var card_added_crit_accuracy:Array = []
	var card_attack:Array = []
	var card_animation:Array = []
	var card_animation_left_weapon:Array = []
	var card_animation_right_weapon:Array = []
	var card_animation_projectile:PoolStringArray = []
	var card_counter_anim_tandem:Array = []
	var elements:Array = []
	var behavior_trees:Array = []
	for tab in tab_container.get_children():
		action_costs.append(tab.card_action_cost.value)
		upgrade_costs.append(tab.card_upgrade_value.value)
		can_attack.append(tab.card_action.pressed)
		can_defend.append(tab.card_reaction.pressed)
		need_los.append(tab.card_need_los.pressed)
		is_homing.append(tab.card_homing.pressed)
		has_combo.append(tab.card_combo.pressed)
		is_piercing.append(tab.card_piercing.pressed)
		is_shattering.append(tab.card_shattering.pressed)
		is_consumable.append(tab.card_consumable.pressed)
		has_counter.append(tab.card_counter.pressed)
		has_reflex.append(tab.card_reflex.pressed)
		self_eliminating.append(tab.card_self_eliminating.pressed)
		hexagonal_targeting.append(tab.card_hexagonal_targeting.pressed)
		var self_status_list:Array = []
		for self_status in tab.self_statuses.get_children():
			if self_status is CardStatusDurationOption:
				var status = self_status.selected
				var status_duration = self_status.spin_box.value + int(tab.card_delay.value == 0)
				self_status_list.append([status,status_duration])
		self_statuses.append(self_status_list)
		var target_status_list:Array = []
		for target_status in tab.target_statuses.get_children():
			if target_status is CardStatusDurationOption:
				var status = target_status.selected
				var status_duration = target_status.spin_box.value
				target_status_list.append([status,status_duration])
		target_statuses.append(target_status_list)
		var prerequisites_list:Array = []
		for prerequisite in tab.prerequisites.get_children():
			if prerequisite is HBoxContainer:
				var prerequisite_var = BattleDictionary.unit_int_vars[prerequisite.get_child(0).selected]
				var prerequisite_value = prerequisite.get_child(1).value
				var prerequisite_is_cost = prerequisite.get_child(2).pressed
				prerequisites_list.append([prerequisite_var,prerequisite_value,prerequisite_is_cost])
		prerequisites.append(prerequisites_list)
		delay.append(tab.card_delay.value)
		description.append(tab.card_description.text)
		card_min_range.append(tab.card_min_range.value)
		card_max_range.append(tab.card_max_range.value)
		card_up_vertical_range.append(tab.card_up_range.value)
		card_down_vertical_range.append(tab.card_down_range.value)
		card_added_accuracy.append(tab.card_added_accuracy.value)
		card_added_crit_accuracy.append(tab.card_added_crit_accuracy.value)
		card_attack.append(tab.card_damage.value)
		card_animation.append([tab.card_animation.selected,tab.card_animation2.selected])
		card_animation_left_weapon.append(tab.card_animation_left_weapon.selected)
		card_animation_right_weapon.append(tab.card_animation_right_weapon.selected)
		card_animation_projectile.append("null")
		card_counter_anim_tandem.append(tab.card_counter_anim_tandem.pressed)
		elements.append([tab.card_element.selected,tab.card_element2.selected,tab.card_element3.selected])
		behavior_trees.append(tab.convertTreeToArray(tab.tree))
	var card_id:Card = Card.new()
	card_id.card_name = card_name
	card_id.card_class = card_class
	card_id.action_costs = action_costs
	card_id.card_level = card_level
	card_id.upgrade_costs = upgrade_costs
	card_id.card_art = card_art
	card_id.card_icon = card_icon
	card_id.card_type = card_type
	card_id.can_attack = can_attack
	card_id.can_defend = can_defend
	card_id.need_los = need_los
	card_id.is_homing = is_homing
	card_id.has_combo = has_combo
	card_id.is_piercing = is_piercing
	card_id.is_shattering = is_shattering
	card_id.is_consumable = is_consumable
	card_id.has_counter = has_counter
	card_id.has_reflex = has_reflex
	card_id.self_eliminating = self_eliminating
	card_id.hexagonal_targeting = hexagonal_targeting
	card_id.self_statuses = self_statuses
	card_id.target_statuses = target_statuses
	card_id.delay = delay
	card_id.rarity = rarity
	card_id.description = description
	card_id.card_min_range = card_min_range
	card_id.card_max_range = card_max_range
	card_id.card_up_vertical_range = card_up_vertical_range
	card_id.card_down_vertical_range = card_down_vertical_range
	card_id.card_added_accuracy = card_added_accuracy
	card_id.card_added_crit_accuracy = card_added_crit_accuracy
	card_id.card_attack = card_attack
	card_id.card_animation = card_animation
	card_id.card_animation_left_weapon = card_animation_left_weapon
	card_id.card_animation_right_weapon = card_animation_right_weapon
	card_id.card_animation_projectile = card_animation_projectile
	card_id.card_counter_anim_tandem = card_counter_anim_tandem
	card_id.bypass_popup = bypass_popup
	card_id.ignore_item_stats = ignore_item_stats
	card_id.elements = elements
	var data = {
		"card_id" : self,
		"unique_id" : card_name.to_lower(),
		"card_name": card_name,
		"card_class": card_class,
		"action_costs": action_costs,
		"card_level": card_level,
		"upgrade_costs": upgrade_costs,
		"card_art": card_art,
		"card_icon": card_icon,
		"card_type": card_type,
		"item_type": item_type,
		"can_attack": can_attack,
		"can_defend": can_defend,
		"need_los" : need_los,
		"is_homing" : is_homing,
		"has_combo" : has_combo,
		"is_piercing" : is_piercing,
		"is_shattering": is_shattering,
		"is_consumable" : is_consumable,
		"has_counter" : has_counter,
		"has_reflex": has_reflex,
		"self_eliminating": self_eliminating,
		"hexagonal_targeting": hexagonal_targeting,
		"self_statuses": self_statuses,
		"target_statuses": target_statuses,
		"prerequisites" : prerequisites,
		"delay" : delay,
		"rarity": rarity,
		"description": description,
		"card_min_range": card_min_range,
		"card_max_range": card_max_range,
		"card_up_vertical_range": card_up_vertical_range,
		"card_down_vertical_range": card_down_vertical_range,
		"card_added_accuracy": card_added_accuracy,
		"card_added_crit_accuracy": card_added_crit_accuracy,
		"card_attack": card_attack,
		"card_animation": card_animation,
		"card_animation_left_weapon": card_animation_left_weapon,
		"card_animation_right_weapon": card_animation_right_weapon,
		"card_animation_projectile": card_animation_projectile,
		"card_counter_anim_tandem" :card_counter_anim_tandem,
		"bypass_popup": bypass_popup,
		"ignore_item_stats": ignore_item_stats,
		"elements": elements,
#		"behavior_tree": convertTreeToArray(tree),
		"behavior_trees": behavior_trees,
		"original_card_values": []
	}
	saveCardDataToFile(data)
	populateCards()

func saveCardDataToFile(card_data:Dictionary) -> void:
	var dir = Directory.new()
	if !dir.dir_exists(PlayerVars.CARD_SAVE_DIR):
		dir.make_dir_recursive(PlayerVars.CARD_SAVE_DIR)
#	var saved_cards:Array = CardLoader.loadCardList(true)
	var file:File = File.new()
	var error = file.open(PlayerVars.CARD_SAVE_DIR + card_data.get("card_name") + ".crd", File.WRITE)
	if error == OK:
		file.store_var(card_data)
	file.close()
	error = file.open(PlayerVars.CARD_LOAD_DIR + card_data.get("card_name") + ".crd", File.WRITE)
	if error == OK:
		file.store_var(card_data)
		UI_Sounds.createSound(UI_Sounds.unit_create)
	file.close()

func convertTreeToArray(behavior_tree:Tree) -> Array:
	var saved_behavior:Array = getTreeItems(behavior_tree.get_root())
	return saved_behavior

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

func reset():
	$CardPanel/CardName.text = "Card Name"
	$CardPanel/ScrollContainer/HBoxContainer/CardClass.select(0)
	var card_level:int = 0
	$CardPanel/ScrollContainer/HBoxContainer/RarityValue.value = 0
#	var card_art:String = $CardPanel/ScrollContainer/HBoxContainer/CardArt.get_meta("file_name")
	var card_art:String = "empty.png"
	$CardPanel/ScrollContainer/HBoxContainer/CardType.select(0)
	resetTabs()
	yield(get_tree().create_timer(0.1),"timeout")
	yield(get_tree(),"idle_frame")
	var new_tab = card_tab_prefab.instance()
	new_tab.name = "Level 1"
	tab_container.add_child(new_tab)
	current_tree = tab_container.get_tab_control(0).tree
	tab_container.get_tab_control(0).loadTreeItem(current_tree.get_root(), ["BTSequence"])

func _on_DeleteUnit_pressed():
	var dialog = get_node("CardPanel/DeleteUnit/AcceptDialog")
#	var delete_button = get_node("CardPanel/DeleteUnit")
	UI_Sounds.createSound(UI_Sounds.alert)
	dialog.dialog_text = "Are you sure you want to delete " + get_node("CardPanel/CardName").text + "?"
	dialog.popup_centered()


func _on_AcceptDialog_confirmed():
	var dir = Directory.new()
	dir.copy(PlayerVars.CARD_LOAD_DIR + card_info.card_name + ".crd", PlayerVars.DELETED_DIR + card_info.card_name + ".crd")
	if dir.remove(PlayerVars.CARD_LOAD_DIR + card_info.card_name + ".crd") == OK:
		pass
	if dir.remove(PlayerVars.CARD_SAVE_DIR + card_info.card_name + ".crd") == OK:
		UI_Sounds.createSound(UI_Sounds.unit_delete)
		populateCards()


func _on_TabContainer_tab_selected(tab):
	current_tree = tab_container.get_tab_control(tab).tree


func _on_TestCard_pressed():
	var dialog = get_node("CardPanel/TestCard/TestCardAcceptDialog")
#	var delete_button = get_node("CardPanel/DeleteUnit")
	var dir = Directory.new()
	var load_file:bool = dir.file_exists(PlayerVars.CARD_LOAD_DIR + $CardPanel/CardName.text + ".crd")
	var save_file:bool = dir.file_exists(PlayerVars.CARD_SAVE_DIR + $CardPanel/CardName.text + ".crd")
	if $CardPanel/CardName.text != "Card Name" and (!load_file and !save_file):
		UI_Sounds.createSound(UI_Sounds.alert)
		dialog.dialog_text = "\"" + $CardPanel/CardName.text + "\" must be saved before it can be tested. Save?"
		dialog.popup_centered()
	else:
		UI_Sounds.createSound(UI_Sounds.unit_create)
		get_parent().unit_maker.visible = true
		get_parent().unit_maker.testUnit()
		visible = false
		


func _on_TestCardAcceptDialog_confirmed():
	_on_SaveCard_pressed()
	UI_Sounds.createSound(UI_Sounds.unit_create)


func _on_Menu_pressed():
	var dialog = get_node("MenuControl/Menu/MenuAcceptDialog")
	var dir = Directory.new()
	var load_file:bool = dir.file_exists(PlayerVars.CARD_LOAD_DIR + $CardPanel/CardName.text + ".crd")
	var save_file:bool = dir.file_exists(PlayerVars.CARD_SAVE_DIR + $CardPanel/CardName.text + ".crd")
	if $CardPanel/CardName.text != "Card Name" and (!load_file and !save_file):
		UI_Sounds.createSound(UI_Sounds.alert)
		dialog.dialog_text = "\"" + $CardPanel/CardName.text + "\" has not been saved. Save?"
		dialog.popup_centered()
	else:
		get_parent().menu.visible = true
		visible = false


func _on_MenuAcceptDialog_confirmed():
	_on_SaveCard_pressed()
	get_parent().menu.visible = true
	visible = false


func menuAcceptNoSave():
	get_parent().menu.visible = true
	visible = false


func _on_ItemType_item_selected(index):
	if index != 0:
		if get_node("CardPanel/ScrollContainer/HBoxContainer/HBoxContainer").get_child_count() == 1:
			addCardItemTypeOption()
	else:
		if get_node("CardPanel/ScrollContainer/HBoxContainer/HBoxContainer").get_child_count() == 2:
			remove_child(get_node("CardPanel/ScrollContainer/HBoxContainer/HBoxContainer").get_child(1))

func addCardItemTypeOption():
	var new_option = card_item_type_option.instance()
	get_node("CardPanel/ScrollContainer/HBoxContainer/HBoxContainer").add_child(new_option)


func _on_CardIcon_pressed():
	get_node("FileDialog").window_title = "Load Card Icon"
	get_node("FileDialog").mode = 0
	get_node("FileDialog").set_current_dir("res://assets/images/ui/icons/") 
	get_node("FileDialog").add_filter("*.png ; Image")
	get_node("FileDialog").visible = true


func _on_FileDialog_file_selected(path):
	get_node("CardPanel/HBoxContainer2/CardIcon/TextureRect").texture = load(path)


func _on_IgnoreItemStats_toggled(button_pressed):
	for tab in tab_container.get_children():
		if button_pressed:
			tab.card_damage_label.text = "Damage"
			tab.card_damage.hint_tooltip = "Base damage dealt to target. (Negative values will heal target)"
			tab.card_action_cost_label.text = "AP Cost"
			tab.card_action_cost.hint_tooltip = "Base AP cost."
		else:
			tab.card_damage_label.text = "Damage Multiplier"
			tab.card_damage.hint_tooltip = "Damage Multiplier of the Item's Base Damage"
			tab.card_action_cost_label.text = "Added AP Cost"
			tab.card_action_cost.hint_tooltip = "Added AP on top of Item's base AP cost."
			
