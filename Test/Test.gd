extends Node


var node_name:String


# Called when the node enters the scene tree for the first time.
func _ready():
	for iterator in range(3):
		var time_before = OS.get_ticks_msec()
		for i in range(100000):
			node_name = get_node("Node").name
			#node_name = $Node.name
		var total_time = OS.get_ticks_msec() - time_before
		print("Time taken (get_node): " + str(total_time))
		time_before = OS.get_ticks_msec()
		for i in range(100000):
			#node_name = get_node("Node").name
			node_name = $Node.name
		total_time = OS.get_ticks_msec() - time_before
		print("Time taken $Node: " + str(total_time))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
