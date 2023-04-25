extends OptionButton

class_name CardElementOption

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in BattleDictionary.ELEMENT:
		add_item(i)
