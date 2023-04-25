extends OptionButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	add_item("Normal AI") #ai_type = 0
	add_item("Aggressive AI")
	add_item("Coward AI")
