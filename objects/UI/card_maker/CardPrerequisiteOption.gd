extends OptionButton

class_name CardPrerequisiteOption

onready var spin_box:SpinBox = $SpinBox

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in BattleDictionary.unit_int_vars:
		add_item(i)
	connect("resized",self,"updateHint")
	connect("item_selected",self,"updateItem")
#	spin_box.rect_position.y = 24


func updateHint():
	hint_tooltip = BattleDictionary.unit_int_vars[selected][1]


func updateItem(item:int):
	if item == 0:
		get_parent().get_parent().remove_child(get_parent())
		get_parent().queue_free()
