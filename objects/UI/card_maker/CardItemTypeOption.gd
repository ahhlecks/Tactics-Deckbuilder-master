extends OptionButton

class_name CardItemTypeOption

onready var spin_box:SpinBox = $SpinBox

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in BattleDictionary.item_type:
		add_item(i)
	connect("item_selected",self,"updateItem")
#	spin_box.rect_position.y = 24

func updateItem(item:int):
	if item == 0:
		get_parent().remove_child(self)
		queue_free()
	else:
		get_parent().get_parent().get_parent().get_parent().get_parent().addCardItemTypeOption()
