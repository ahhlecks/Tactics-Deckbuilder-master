extends OptionButton

class_name CardItemOption

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in BattleDictionary.item_type:
		add_item(i)
