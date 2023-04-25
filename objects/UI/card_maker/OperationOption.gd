extends OptionButton


class_name OperationOption

# Declare member variables here. Examples:
# var a = 2
# export(int, "add", "subtract", "multiply", "divide") var operation


# Called when the node enters the scene tree for the first time.
func _ready():
	add_item("assign")
	add_item("add")
	add_item("subtract")
	add_item("multiply")
	add_item("divide")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
