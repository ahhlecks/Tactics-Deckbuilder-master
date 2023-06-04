extends OptionButton

class_name CardTypeOption

# Declare member variables here. Examples:
# enum CARD_TYPE {SKILL,PHYSICALATTACK,MAGICATTACK,MAGICSPELL,ITEM}


# Called when the node enters the scene tree for the first time.
func _ready():
	add_item("OFFENSE")
	add_item("DEFENSE")
	add_item("UTILITY")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
