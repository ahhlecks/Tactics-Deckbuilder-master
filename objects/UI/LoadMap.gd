extends Button


onready var fileWindow = get_node("../LoadMapFileDialog")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(_delta):
	if  is_pressed():
		if fileWindow.visible:
			fileWindow.hide()
		else:
			fileWindow.popup()
