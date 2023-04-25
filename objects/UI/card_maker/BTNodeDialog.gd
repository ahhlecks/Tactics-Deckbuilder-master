extends WindowDialog

class_name BTNodeDialog

onready var card_maker = $'..'
onready var add_node_button = $'AddNodeButton'
onready var edit_node_button = $'EditNodeButton'
onready var move_up_button = $'MoveUp'
onready var move_down_button = $'MoveDown'
var btnode:String
var container:BTNodeContainer



# Called when the node enters the scenecard_maker.tree for the first time.
func _ready():
	pass # Replace with function body.

func clearContainer() -> void:
	window_title = ""
	if container != null:
		remove_child(container)

func newBTContainer(node,desc,values,is_edit) -> void:
	clearContainer()
	window_title = node
	btnode = node
	add_node_button.visible = !is_edit
	edit_node_button.visible = is_edit
	container = load("res://objects/UI/card_maker/bt_node_panels/BTNodeContainer.tscn").instance()
	add_child(container)
	container.description.text = desc
	container.addNodes(node)
	container.parameter_values.append(node)
	if is_edit:
		container.loadValues(values)
		move_up_button.visible = true
		move_down_button.visible = true
		if !is_connected("hide",self,"editBTNode"):
			connect("hide",self,"editBTNode")
	else:
		move_up_button.visible = false
		move_down_button.visible = false
		

#func addBTNode():
#	container.saveValues()
#	if card_maker.tree.get_root() == null:
#		var root = card_maker.tree.create_item(null)
#		root.set_text(0,btnode)
#		root.select(0)
#	elif card_maker.tree.get_selected() != null:
#		var item = card_maker.tree.create_item(card_maker.tree.get_selected())
#		item.set_text(0,btnode)
#		item.set_meta("description", container.description.text)
#		item.set_meta("parameter_values", container.parameter_values)
#	elif card_maker.tree.get_selected() == null:
#		var item =card_maker.tree.create_item(card_maker.tree.get_root())
#		item.set_text(0,btnode)
#		item.set_meta("description", container.description.text)
#		item.set_meta("parameter_values", container.parameter_values)
#
#func editBTNode() -> void:
#	container.saveValues()
#	if card_maker.tree.get_selected() != null and card_maker.tree.get_selected().is_selected(0):
#		var item:TreeItem = card_maker.tree.get_selected()
#		item.set_text(0,btnode)
#		item.set_meta("description", container.description.text)
#		item.set_meta("parameter_values", container.parameter_values)

func addBTNode():
	container.saveValues()
	if card_maker.current_tree.get_root() == null:
		var root = card_maker.current_tree.create_item(null)
		root.set_text(0,btnode)
		root.select(0)
	elif card_maker.current_tree.get_selected() != null:
		var item = card_maker.current_tree.create_item(card_maker.current_tree.get_selected())
		item.set_text(0,btnode)
		item.set_meta("description", container.description.text)
		item.set_meta("parameter_values", container.parameter_values)
	elif card_maker.current_tree.get_selected() == null:
		var item =card_maker.current_tree.create_item(card_maker.current_tree.get_root())
		item.set_text(0,btnode)
		item.set_meta("description", container.description.text)
		item.set_meta("parameter_values", container.parameter_values)
	hide()

func editBTNode() -> void:
	container.saveValues()
	if card_maker.current_tree.get_selected() != null and card_maker.current_tree.get_selected().is_selected(0):
		var item:TreeItem = card_maker.current_tree.get_selected()
		item.set_text(0,btnode)
		item.set_meta("description", container.description.text)
		item.set_meta("parameter_values", container.parameter_values)
	if is_connected("hide",self,"closeEditBTNode"):
		disconnect("hide",self,'closeEditBTNode')
	hide()


#func _on_MoveUp_pressed():
#	var tree = get_parent().tree
#	var item:TreeItem = tree.get_selected()
#	var item_list:Array = get_parent().tree_item_get_list(item)
#	if get_parent().tree_item_get_index(item) == 0:
#		if item.get_parent() == tree.get_root():
#			return
#		else:
#			var new_item = tree.create_item(item.get_parent().get_parent())
#			new_item.set_text(0,item.get_text(0))
#			new_item.set_meta("description", item.get_meta("description"))
#			new_item.set_meta("parameters", item.get_meta("parameters"))
#			new_item.set_meta("parameter_values", item.get_meta("parameter_values"))
#			item.free()
#			return
#	if get_parent().tree_item_get_index(item) == get_parent().tree_item_get_list(item).size()-1:
#		item.get_prev().move_to_bottom()
#	elif get_parent().tree_item_get_index(item) != 0:
#		for i in range(get_parent().tree_item_get_index(item.get_prev()),item_list.size()):
#			if item_list[i] != item:
#				item_list[i].move_to_bottom()
#
#func _on_MoveDown_pressed():
#	var tree = get_parent().tree
#	var item:TreeItem = tree.get_selected()
#	var item_list:Array = get_parent().tree_item_get_list(item)
#	if get_parent().tree_item_get_index(item) == item_list.size() -1:
#		return
#	if get_parent().tree_item_get_index(item) == 0:
#		item.get_next().move_to_top()
#	elif get_parent().tree_item_get_index(item) != get_parent().tree_item_get_list(item).size()-1:
#		for i in range(get_parent().tree_item_get_index(item.get_next()),-1,-1):
#			if item_list[i] != item:
#				item_list[i].move_to_top()

func _on_MoveUp_pressed():
	var tree = card_maker.current_tree
	var item:TreeItem = tree.get_selected()
	var item_list:Array = get_parent().tree_item_get_list(item)
	if get_parent().tree_item_get_index(item) == 0:
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
	if get_parent().tree_item_get_index(item) == get_parent().tree_item_get_list(item).size()-1:
		item.get_prev().move_to_bottom()
	elif get_parent().tree_item_get_index(item) != 0:
		for i in range(get_parent().tree_item_get_index(item.get_prev()),item_list.size()):
			if item_list[i] != item:
				item_list[i].move_to_bottom()

func _on_MoveDown_pressed():
	var tree = card_maker.current_tree
	var item:TreeItem = tree.get_selected()
	var item_list:Array = get_parent().tree_item_get_list(item)
	if get_parent().tree_item_get_index(item) == item_list.size() -1:
		return
	if get_parent().tree_item_get_index(item) == 0:
		item.get_next().move_to_top()
	elif get_parent().tree_item_get_index(item) != get_parent().tree_item_get_list(item).size()-1:
		for i in range(get_parent().tree_item_get_index(item.get_next()),-1,-1):
			if item_list[i] != item:
				item_list[i].move_to_top()
