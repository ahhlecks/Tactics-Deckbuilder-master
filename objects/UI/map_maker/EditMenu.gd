extends Panel

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var current_unit: Dictionary
onready var hexGrid = get_node("../HexGrid")
#onready var unit_maker = get_node("UnitMaker")

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	var map_save_directory:String = PlayerVars.MAP_SAVE_DIR
	var map_load_directory:String = PlayerVars.MAP_LOAD_DIR
	var dir = Directory.new()
	if !dir.dir_exists(map_save_directory):
		dir.make_dir_recursive(map_save_directory)
	$UI/HBox4/SaveMapFileDialog.current_dir = map_save_directory
	$UI/HBox4/LoadMapFileDialog.current_dir = map_load_directory


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_LoadMapFileDialog_file_selected(path):
	$"../CameraRig".current_target = null
	hexGrid.load_map(path)


func _on_SaveMapFileDialog_file_selected(path:String):
	hexGrid.save_map(path)
	hexGrid.save_map(PlayerVars.MAP_LOAD_DIR + path.get_file())


func _on_EditButton_pressed():
	visible = !visible


func _on_CharacterStatsButton_pressed():
	$Units.visible = !$Units.visible
	$Units.intializeList("ally")

func playMode() -> void:
	get_node("../HexGrid").editMode = false
	get_node("../BattleController/BattleGUI").visible = true
	get_node("UI/HBox1").visible = false
	get_node("UI/HBox1/Height").pressed = false
	get_node("UI/HBox2").visible = false
	get_node("UI/HBox2/Add").pressed = false
	get_node("UI/HBox2/Delete").pressed = false
	get_node("UI/HBox3").visible = false
	get_node("UI/HBox3/AddUnit").pressed = false
	get_node("UI/HBox3/DeleteUnit").pressed = false
	get_node("UI/HBox4/SaveMap").visible = false

func editMode() -> void:
	get_node("../HexGrid").editMode = true
	get_node("../BattleController/BattleGUI").visible = false
	get_node("UI/HBox1").visible = true
	get_node("UI/HBox2").visible = true
	get_node("UI/HBox3").visible = true
	get_node("UI/HBox4/SaveMap").visible = true


func _on_NewMap_pressed():
	pass # Replace with function body.

func setUnit(unit:Dictionary):
	current_unit = unit
