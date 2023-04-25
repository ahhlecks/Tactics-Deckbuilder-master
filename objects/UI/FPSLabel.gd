# MIT License
# Copyright (c) 2019 Lupo Dharkael

class_name FpsLabel

extends CanvasLayer


enum Position {TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT, NONE}

export (Position) var position = Position.TOP_RIGHT
export(int) var margin : int = 10

var label : Label
var color_rect:ColorRect


func _ready() -> void:
	color_rect = ColorRect.new()
	add_child(color_rect)
	color_rect.modulate = Color(0,0,0,.2)
	label = Label.new()
	add_child(label)
	label.text = "FPS: " + str(Engine.get_frames_per_second())
	get_tree().get_root().connect("size_changed", self, "update_position")
	yield(label,"minimum_size_changed")
	yield(get_tree().create_timer(3),"timeout")
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


func _process(_delta : float) -> void:
	label.text = "FPS: " + str(Engine.get_frames_per_second())
