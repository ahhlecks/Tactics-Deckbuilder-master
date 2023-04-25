extends OptionButton

class_name CardStatusDurationOption

onready var spin_box:SpinBox = $SpinBox

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in BattleDictionary.valid_statuses:
		add_item(i[0])
	connect("resized",self,"updateHint")
	connect("item_selected",self,"updateItem")
#	spin_box.rect_position.y = 24


func updateHint():
	hint_tooltip = BattleDictionary.valid_statuses[selected][1]


func updateItem(item:int):
	if item == 0:
		get_parent().remove_child(self)
		queue_free()
