extends OptionButton

class_name CardAnimationOption

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if !get_parent().get_parent().get_parent().get_parent().dupe:
		for i in BattleDictionary.valid_animations:
			add_item(i)
			select(0)
