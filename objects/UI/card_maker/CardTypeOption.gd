extends OptionButton

class_name CardTypeOption

# Declare member variables here. Examples:
# enum CARD_TYPE {SKILL,PHYSICALATTACK,MAGICATTACK,MAGICSPELL,ITEM}


# Called when the node enters the scene tree for the first time.
func _ready():
	add_item("SKILL")
	add_item("PHYSICALATTACK")
	add_item("MAGICATTACK")
	add_item("MAGICSPELL")
	add_item("ITEM")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
