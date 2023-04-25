extends HBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	rect_pivot_offset = Vector2(rect_size.x / 2.0,rect_size.y)


func rescale():
	var new_scale = min(1, 6.0/get_child_count())
	set_scale(Vector2(new_scale,new_scale))
	rect_position = Vector2((get_viewport().size.x / 2) - (rect_size.x/2), get_viewport().size.y - rect_size.y)
