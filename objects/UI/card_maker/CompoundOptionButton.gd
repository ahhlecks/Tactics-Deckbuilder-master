extends OptionButton

class_name CompoundOptionButton

var bt_node_length:int
onready var VBox:VBoxContainer = VBoxContainer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("item_selected",self,"_on_item_selected")


func _on_item_selected(index):
	pass

func _loadValues():
	pass

func _saveValues():
	pass

func get_class() -> String:
	return "CompoundOptionButton"
