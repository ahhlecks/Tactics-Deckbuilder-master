extends Sprite


var active:bool = false
var unlocked:bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	modulate.a = .25


func activate() -> void:
	active = true
	unlocked = true
	modulate.a = .5
