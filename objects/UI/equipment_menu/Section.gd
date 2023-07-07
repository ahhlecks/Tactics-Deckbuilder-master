extends Sprite


var active:bool = false
var unlocked:bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	modulate.a = .1
	modulate.b = 1
	modulate.g = 1


func activate() -> void:
	active = true
	unlocked = true
	modulate.a = .5
	modulate.b = 1
	modulate.g = 1

func lock() -> void:
	unlocked = false
	modulate.a = .1
	modulate.b = .5
	modulate.g = .5

func unlock() -> void:
	unlocked = true
	modulate.a = .25
	modulate.b = 1
	modulate.g = 1
