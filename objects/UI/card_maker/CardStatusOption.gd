extends OptionButton

class_name CardStatusOption

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in BattleDictionary.valid_statuses:
		add_item(i[0])
	connect("resized",self,"updateHint")


func updateHint():
	hint_tooltip = BattleDictionary.valid_statuses[selected][1]
