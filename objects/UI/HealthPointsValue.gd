extends SpinBox

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_OptionButton_item_selected(index):
	if index == 0:
		value = 80
	elif index == 1:
		value = 70
	else:
		value = 60
