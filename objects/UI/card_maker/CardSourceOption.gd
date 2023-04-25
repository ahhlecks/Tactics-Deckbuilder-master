extends OptionButton

class_name CardSourceOption

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	add_item("card_caster")
	add_item("card_target")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
