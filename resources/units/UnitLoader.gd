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
	directory.call_deferred("queue_free")

func loadAllyUnitList(save_dir:bool) -> Array: # loadAllCards
	var unit_list:Array = []
	var dir = Directory.new()
	var file:File = File.new()
	if !save_dir:
		if !dir.dir_exists(PlayerVars.ALLY_UNIT_LOAD_DIR):
			dir.make_dir_recursive(PlayerVars.ALLY_UNIT_LOAD_DIR)
		if dir.open(PlayerVars.ALLY_UNIT_LOAD_DIR) == OK:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if dir.current_is_dir():
					pass
	#				print("Found directory: " + file_name)
				if !dir.current_is_dir():
	#				print("Found file: " + file_name)
					var error = file.open(PlayerVars.ALLY_UNIT_LOAD_DIR + file_name, File.READ)
					if error == OK:
#						var unit_data:Dictionary = file.get_var()
						unit_list.append(file_name.replace(".dat",""))
					else:
						print("Invalid unit file.")
					file.close()
				file_name = dir.get_next()
	else:
		if !dir.dir_exists(PlayerVars.ALLY_UNIT_SAVE_DIR):
			dir.make_dir_recursive(PlayerVars.ALLY_UNIT_SAVE_DIR)
		if dir.open(PlayerVars.ALLY_UNIT_SAVE_DIR) == OK:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if dir.current_is_dir():
					pass
	#				print("Found directory: " + file_name)
				if !dir.current_is_dir():
	#				print("Found file: " + file_name)
					var error = file.open(PlayerVars.ALLY_UNIT_SAVE_DIR + file_name, File.READ)
					if error == OK:
#						var unit_data:Dictionary = file.get_var()
						unit_list.append(file_name.replace(".dat",""))
					else:
						print("Invalid unit file.")
					file.close()
				file_name = dir.get_next()
		if unit_list.empty():
			dir.open(PlayerVars.ALLY_UNIT_LOAD_DIR)
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if dir.current_is_dir():
					pass
	#				print("Found directory: " + file_name)
				if !dir.current_is_dir():
	#				print("Found file: " + file_name)
					var error = file.open(PlayerVars.ALLY_UNIT_LOAD_DIR + file_name, File.READ)
					if error == OK:
#						var unit_data:Dictionary = file.get_var()
						unit_list.append(file_name.replace(".dat",""))
					else:
						print("Invalid unit file.")
					file.close()
				file_name = dir.get_next()
	return unit_list

func loadEnemyUnitList(save_dir:bool) -> Array: # loadAllCards
	var unit_list:Array = []
	var dir = Directory.new()
	var file:File = File.new()
	if !save_dir:
		if !dir.dir_exists(PlayerVars.ENEMY_UNIT_LOAD_DIR):
			dir.make_dir_recursive(PlayerVars.ENEMY_UNIT_LOAD_DIR)
		if dir.open(PlayerVars.ENEMY_UNIT_LOAD_DIR) == OK:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if dir.current_is_dir():
					pass
	#				print("Found directory: " + file_name)
				if !dir.current_is_dir():
	#				print("Found file: " + file_name)
					var error = file.open(PlayerVars.ENEMY_UNIT_LOAD_DIR + file_name, File.READ)
					if error == OK:
#						var unit_data:Dictionary = file.get_var()
						unit_list.append(file_name.replace(".dat",""))
					else:
						print("Invalid unit file.")
					file.close()
				file_name = dir.get_next()
	else:
		if !dir.dir_exists(PlayerVars.ENEMY_UNIT_SAVE_DIR):
			dir.make_dir_recursive(PlayerVars.ENEMY_UNIT_SAVE_DIR)
		if dir.open(PlayerVars.ENEMY_UNIT_SAVE_DIR) == OK:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if dir.current_is_dir():
					pass
	#				print("Found directory: " + file_name)
				if !dir.current_is_dir():
	#				print("Found file: " + file_name)
					var error = file.open(PlayerVars.ENEMY_UNIT_SAVE_DIR + file_name, File.READ)
					if error == OK:
#						var unit_data:Dictionary = file.get_var()
						unit_list.append(file_name.replace(".dat",""))
					else:
						print("Invalid unit file.")
					file.close()
				file_name = dir.get_next()
		if unit_list.empty():
			dir.open(PlayerVars.ENEMY_UNIT_LOAD_DIR)
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if dir.current_is_dir():
					pass
	#				print("Found directory: " + file_name)
				if !dir.current_is_dir():
	#				print("Found file: " + file_name)
					var error = file.open(PlayerVars.ENEMY_UNIT_LOAD_DIR + file_name, File.READ)
					if error == OK:
#						var unit_data:Dictionary = file.get_var()
						unit_list.append(file_name.replace(".dat",""))
					else:
						print("Invalid unit file.")
					file.close()
				file_name = dir.get_next()
	return unit_list

func loadSingleAllyUnitFile(file_name:String,save_dir:bool = false) -> Dictionary:
	var dir = Directory.new()
	var unit_data:Dictionary = {}
	if !save_dir:
		if dir.file_exists(PlayerVars.ALLY_UNIT_LOAD_DIR + file_name + ".dat"):
			var file:File = File.new()
			var error = file.open(PlayerVars.ALLY_UNIT_LOAD_DIR + file_name + ".dat", File.READ)
			if error == OK:
				unit_data = file.get_var()
				file.close()
			else:
				file.close()
			file.call_deferred("queue_free")
	else:
		if dir.file_exists(PlayerVars.ALLY_UNIT_SAVE_DIR + file_name + ".dat"):
			var file:File = File.new()
			var error = file.open(PlayerVars.ALLY_UNIT_SAVE_DIR + file_name + ".dat", File.READ)
			if error == OK:
				unit_data = file.get_var()
				file.close()
			else:
				file.close()
			file.call_deferred("queue_free")
		else:
			var file:File = File.new()
			var error = file.open(PlayerVars.ALLY_UNIT_LOAD_DIR + file_name + ".dat", File.READ)
			if error == OK:
				unit_data = file.get_var()
				file.close()
			else:
				file.close()
			file.call_deferred("queue_free")
	dir.call_deferred("queue_free")
	return unit_data

func loadSingleEnemyUnitFile(file_name:String,save_dir:bool = false) -> Dictionary:
	var dir = Directory.new()
	var unit_data:Dictionary = {}
	if !save_dir:
		if dir.file_exists(PlayerVars.ENEMY_UNIT_LOAD_DIR + file_name + ".dat"):
			var file:File = File.new()
			var error = file.open(PlayerVars.ENEMY_UNIT_LOAD_DIR + file_name + ".dat", File.READ)
			if error == OK:
				unit_data = file.get_var()
				file.close()
			else:
				file.close()
			file.call_deferred("queue_free")
	else:
		if dir.file_exists(PlayerVars.ENEMY_UNIT_SAVE_DIR + file_name + ".dat"):
			var file:File = File.new()
			var error = file.open(PlayerVars.ENEMY_UNIT_SAVE_DIR + file_name + ".dat", File.READ)
			if error == OK:
				unit_data = file.get_var()
				file.close()
			else:
				file.close()
			file.call_deferred("queue_free")
		else:
			var file:File = File.new()
			var error = file.open(PlayerVars.ENEMY_UNIT_LOAD_DIR + file_name + ".dat", File.READ)
			if error == OK:
				unit_data = file.get_var()
				file.close()
			else:
				file.close()
			file.call_deferred("queue_free")
	dir.call_deferred("queue_free")
	return unit_data

func getUnitFileDirectory(file_name:String) -> String:
	var dir = Directory.new()
	if dir.file_exists(PlayerVars.ALLY_UNIT_LOAD_DIR + file_name + ".crd"):
		var file:File = File.new()
		var error = file.open(PlayerVars.ALLY_UNIT_LOAD_DIR + file_name + ".crd", File.READ)
		if error == OK:
			file.close()
			return PlayerVars.ALLY_UNIT_LOAD_DIR
	if dir.file_exists(PlayerVars.ALLY_UNIT_SAVE_DIR + file_name + ".crd"):
		var file:File = File.new()
		var error = file.open(PlayerVars.ALLY_UNIT_SAVE_DIR + file_name + ".crd", File.READ)
		if error == OK:
			file.close()
			return PlayerVars.ALLY_UNIT_SAVE_DIR
	if dir.file_exists(PlayerVars.ENEMY_UNIT_LOAD_DIR + file_name + ".crd"):
		var file:File = File.new()
		var error = file.open(PlayerVars.ENEMY_UNIT_LOAD_DIR + file_name + ".crd", File.READ)
		if error == OK:
			file.close()
			return PlayerVars.ENEMY_UNIT_LOAD_DIR
	if dir.file_exists(PlayerVars.ENEMY_UNIT_SAVE_DIR + file_name + ".crd"):
		var file:File = File.new()
		var error = file.open(PlayerVars.ENEMY_UNIT_SAVE_DIR + file_name + ".crd", File.READ)
		if error == OK:
			file.close()
			return PlayerVars.ENEMY_UNIT_SAVE_DIR
		else:
			file.close()
	return ""
