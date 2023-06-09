class_name Blackboard, "icons/blackboard.svg" 
extends Node

# This is the database where all your variables go. Here you keep track of 
# whether the player is nearby, your health is low, there is a cover available,
# or whatever.
#
# You just store the data here and use it for condition checks in BTCondition scripts, 
# or as arguments for your function calls in BTAction.
#
# This is a good way to separate data from behavior, which is essential 
# to avoid nasty bugs.

export(Dictionary) var _data: Dictionary

var data: Dictionary



func _enter_tree():
	data = _data.duplicate()


func _ready():
	for key in data.keys():
		assert(key is String)


func set_data(key: String, value):
	data[key] = value


func get_data(key: String):
	if data.has(key):
		var value = data[key]
		if value is NodePath:
			if value.is_empty() or not get_tree().get_root().has_node(value):
				data[key] = null
				return null
			else:
				return get_node(value) # If you store NodePaths, will return the Node.
		else:
			return value


func has_data(key: String):
	return data.has(key)

func remove_data(key: String) -> void:
	if data.has(key):
		data.erase(key)

func clear_all_data () -> void:
	data.clear()
