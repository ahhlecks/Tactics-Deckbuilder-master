extends OptionButton

class_name ComparisonOption

# Called when the node enters the scene tree for the first time.
func _ready():
	add_item("equal")
	add_item("greater_than")
	add_item("lesser_than")
	add_item("not_equal")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
