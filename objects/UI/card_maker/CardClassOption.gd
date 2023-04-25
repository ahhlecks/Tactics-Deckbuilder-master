extends OptionButton

class_name CardClassOption

# Declare member variables here. Examples:
# enum CARD_CLASS {WARRIOR,RANGER,MAGE,WARRIORRANGER,RANGERMAGE,MAGEWARRIOR,ALL}


# Called when the node enters the scene tree for the first time.
func _ready():
	add_item("WARRIOR")
	add_item("RANGER")
	add_item("MAGE")
	add_item("WARRIORRANGER")
	add_item("RANGERMAGE")
	add_item("MAGEWARRIOR")
	add_item("ALL")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
