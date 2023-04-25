extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().get_root().connect("size_changed", self, "update_position")
	update_position()

func update_position():
	rect_size = get_viewport().size
	$MenuControl.rect_global_position.x = (get_viewport().size.x / 2) - ($MenuControl.rect_size.x / 2)
	$MenuControl.rect_global_position.y = (get_viewport().size.y / 2) - ($MenuControl.rect_size.y / 2) - 60
