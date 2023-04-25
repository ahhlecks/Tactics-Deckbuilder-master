#extends Label
#
#
## Declare member variables here. Examples:
## var a = 2
## var b = "text"
#
#
## Called when the node enters the scene tree for the first time.
#func _ready():
#	get_tree().get_root().connect("size_changed", self, "updatePosition")
#	var dir = Directory.new()
#	var file:File = File.new()
#	if file.open("res://changelog.md", File.READ) == OK:
#		for i in range(10):
#			if file.get_line().begins_with("##"):
#				text = file.get_line()
#
#
#func updatePosition():
#	rect_global_position = Vector2(get_viewport().size.x,get_viewport().size.y) - Vector2(rect_size.x,rect_size.y)

class_name VersionLabel

extends CanvasLayer


enum Position {TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT, NONE}

export (Position) var position = Position.TOP_RIGHT
export(int) var margin : int = 12

var label : Label
var color_rect:ColorRect


func _ready() -> void:
	color_rect = ColorRect.new()
	add_child(color_rect)
	color_rect.modulate = Color(0,0,0,.2)
	label = Label.new()
	add_child(label)
	get_tree().get_root().connect("size_changed", self, "update_position")
	var file:File = File.new()
	if file.open("res://CHANGELOG.md", File.READ) == OK:
		var content:String = file.get_as_text()
		label.text = "Pre-Alpha v " + content.substr(content.find("##") + 4,5)
		label.modulate = Color( 1, 1, 1, 1 )
	file.call_deferred("queue_free")
	yield(label,"minimum_size_changed")
	update_position()

# pos should be of type Position
func set_position(pos : Position2D):
	position = pos
	update_position()


func update_position():
	var viewport_size : Vector2 = get_viewport().size
	var label_size : Vector2 = label.rect_size
	color_rect.rect_size = label.rect_size
	color_rect.rect_position = label.rect_position
	
	match position:
		Position.TOP_LEFT:
			offset = Vector2(margin, margin)
		Position.BOTTOM_LEFT:
			offset = Vector2(margin, viewport_size.y - margin - label_size.y)
		Position.TOP_RIGHT:
			offset = Vector2(viewport_size.x - margin - label_size.x, margin)
		Position.BOTTOM_RIGHT:
			offset = Vector2(viewport_size.x - margin - label_size.x, viewport_size.y - margin - label_size.y)
