extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var text_batch:Array
signal completed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func playText() -> void:
	if get_child_count() > 0:
		var first_text = get_child(0)
		text_batch.append(first_text)
		for i in get_children().size():
			if i != 0:
				var can_add:bool = true
				for text in text_batch:
					if get_child(i).text_target == text.text_target:
						can_add = false
				if can_add: text_batch.append(get_child(i))
		for i in text_batch.size():
			text_batch[i].playText()
			if i == text_batch.size() - 1:
				yield(text_batch[i],"end_text")
		text_batch = []
		playText()
	else:
		emit_signal("completed")

func hasText() -> bool:
	return get_child_count() > 0
