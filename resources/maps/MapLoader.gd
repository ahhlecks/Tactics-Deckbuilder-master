extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func copyRecursively(from, to) -> void:
	var directory = Directory.new()
	
	# If it doesn't exists, create target directory
	if not directory.dir_exists(to):
		directory.make_dir_recursive(to)
	
	# Open directory
	var error = directory.open(from)
	if error == OK:
		# List directory content
		directory.list_dir_begin(true)
		var file_name = directory.get_next()
		while file_name != "":
			if directory.current_is_dir():
				copyRecursively(from + "/" + file_name, to + "/" + file_name)
			else:
				directory.copy(from + "/" + file_name, to + "/" + file_name)
			file_name = directory.get_next()
	else:
		print("Error copying " + from + " to " + to)

func loadMapList(save_dir:bool) -> Array: # load all maps
	var map_data:Array = []
	var dir = Directory.new()
	var file:File = File.new()
	if !save_dir:
		if !dir.dir_exists(PlayerVars.MAP_LOAD_DIR):
			dir.make_dir_recursive(PlayerVars.MAP_LOAD_DIR)
		if dir.open(PlayerVars.MAP_LOAD_DIR) == OK:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if dir.current_is_dir():
					pass
	#				print("Found directory: " + file_name)
				if !dir.current_is_dir():
	#				print("Found file: " + file_name)
					var error = file.open_encrypted_with_pass(PlayerVars.MAP_LOAD_DIR + file_name, File.READ, "09polkmn")
					if error == OK:
						map_data.append(file_name.replace(".map",""))
					else:
						print("Invalid map file.")
				file_name = dir.get_next()
		elif !dir.dir_exists(PlayerVars.MAP_SAVE_DIR):
			dir.make_dir_recursive(PlayerVars.MAP_SAVE_DIR)
		if dir.open(PlayerVars.MAP_SAVE_DIR) == OK:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if dir.current_is_dir():
					pass
	#				print("Found directory: " + file_name)
				if !dir.current_is_dir():
	#				print("Found file: " + file_name)
					var error = file.open_encrypted_with_pass(PlayerVars.MAP_SAVE_DIR + file_name, File.READ, "09polkmn")
					if error == OK:
						map_data.append(file_name.replace(".map",""))
					else:
						print("Invalid map file.")
				file_name = dir.get_next()
	else:
		if !dir.dir_exists(PlayerVars.MAP_SAVE_DIR):
			dir.make_dir_recursive(PlayerVars.MAP_SAVE_DIR)
		if dir.open(PlayerVars.MAP_SAVE_DIR) == OK:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if dir.current_is_dir():
					pass
	#				print("Found directory: " + file_name)
				if !dir.current_is_dir():
	#				print("Found file: " + file_name)
					var error = file.open_encrypted_with_pass(PlayerVars.MAP_SAVE_DIR + file_name, File.READ, "09polkmn")
					if error == OK:
						map_data.append(file_name.replace(".map",""))
					else:
						print("Invalid map file.")
				file_name = dir.get_next()
	return map_data

func loadSingleMapFile(file_name:String,save_dir:bool = false) -> Dictionary:
	var dir = Directory.new()
	var map_data:Dictionary = {}
	if !file_name.ends_with(".map"):
		var new_name = PlayerVars.MAP_LOAD_DIR + file_name + ".map"
		file_name = new_name
	if !save_dir:
		if dir.file_exists(file_name):
			var file:File = File.new()
			var error = file.open_encrypted_with_pass(file_name, File.READ, "09polkmn")
			if error == OK:
				map_data = file.get_var()
				file.close()
			else:
				file.close()
			file.call_deferred("queue_free")
		elif dir.file_exists(file_name):
			var file:File = File.new()
			var error = file.open_encrypted_with_pass(file_name, File.READ, "09polkmn")
			if error == OK:
				map_data = file.get_var()
				file.close()
			else:
				file.close()
			file.call_deferred("queue_free")
	else:
		if dir.file_exists(file_name):
			var file:File = File.new()
			var error = file.open_encrypted_with_pass(file_name, File.READ, "09polkmn")
			if error == OK:
				map_data = file.get_var()
				file.close()
			else:
				file.close()
			file.call_deferred("queue_free")
	dir.call_deferred("queue_free")
	return map_data


func getUnitFileDirectory(file_name:String) -> String:
	var dir = Directory.new()
	if dir.file_exists(PlayerVars.MAP_LOAD_DIR + file_name + ".map"):
		var file:File = File.new()
		var error = file.open_encrypted_with_pass(PlayerVars.MAP_LOAD_DIR + file_name + ".map", File.READ, "09polkmn")
		if error == OK:
			file.close()
			return PlayerVars.MAP_LOAD_DIR
	if dir.file_exists(PlayerVars.MAP_SAVE_DIR + file_name + ".map"):
		var file:File = File.new()
		var error = file.open_encrypted_with_pass(PlayerVars.MAP_SAVE_DIR + file_name + ".map", File.READ, "09polkmn")
		if error == OK:
			file.close()
			return PlayerVars.MAP_SAVE_DIR
	return ""
