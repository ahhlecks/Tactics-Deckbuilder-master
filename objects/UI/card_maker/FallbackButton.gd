extends CheckButton

class_name FallbackButton

func get_class(): return "FallbackButton"

# Called when the node enters the scene tree for the first time.
func _ready():
	text = "Card Draw Fallback"
	hint_tooltip = BattleDictionary.valid_parameters[BattleDictionary.PARAMETER.FALLBACK][1]


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
