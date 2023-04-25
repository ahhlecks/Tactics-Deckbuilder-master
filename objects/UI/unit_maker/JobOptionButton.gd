extends OptionButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	for job in BattleDictionary.job_list:
		add_item(job)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
