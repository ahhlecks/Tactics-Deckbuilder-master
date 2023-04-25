extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	intializeList("ally")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func clearList():
	for buttons in get_node("VBoxContainer/Units/VBoxContainer").get_children():
		remove_child(buttons)
		buttons.call_deferred("queue_free")
	
func intializeList(list_dir):
	clearList()
	var unit_list:Array
	if list_dir == "ally":
		unit_list = UnitLoader.loadAllyUnitList(true)
		if unit_list != null and unit_list.size() > 0:
			for unit in unit_list:
				var unit_data:Dictionary = UnitLoader.loadSingleAllyUnitFile(unit,true)
				var new_button = Button.new()
				new_button.text = unit_data.unit_name
				new_button.size_flags_horizontal = SIZE_EXPAND_FILL
				new_button.align = new_button.ALIGN_LEFT
				new_button.clip_text = true
				new_button.toggle_mode = false
				get_node("VBoxContainer/Units/VBoxContainer").add_child(new_button)
				new_button.connect("pressed",get_parent(),"setUnit",[unit_data.duplicate(true)])
	if list_dir == "enemy":
		unit_list = UnitLoader.loadEnemyUnitList(true)
		if unit_list != null and unit_list.size() > 0:
			for unit in unit_list:
				var unit_data:Dictionary = UnitLoader.loadSingleEnemyUnitFile(unit,true)
				var new_button = Button.new()
				new_button.text = unit_data.unit_name
				new_button.size_flags_horizontal = SIZE_EXPAND_FILL
				new_button.align = new_button.ALIGN_LEFT
				new_button.clip_text = true
				new_button.toggle_mode = false
				get_node("VBoxContainer/Units/VBoxContainer").add_child(new_button)
				new_button.connect("pressed",get_parent(),"setUnit",[unit_data.duplicate(true)])


func _on_Owned_toggled(button_pressed):
	if button_pressed:
		intializeList("ally")
	else:
		intializeList("enemy")
