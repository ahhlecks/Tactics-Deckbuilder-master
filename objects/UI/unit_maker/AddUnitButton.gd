extends Button

#onready var popupCharacterWindow = get_node("../../../CharacterStats")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(_delta):
	pass
	#if  is_pressed():
	#	if popupCharacterWindow.visible:
	#		popupCharacterWindow.hide()
	#	else:
	#		popupCharacterWindow.popup()
	#		popupCharacterWindow.set_size(Vector2(460,500))
	#		popupCharacterWindow.set_global_position(Vector2(0,180))
