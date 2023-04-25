extends Spatial

class_name WorldScene

export var map_name:String

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().get_root().connect("size_changed", self, "update_position")
	update_position()

func update_position():
	$MenuControl.rect_position = Vector2(get_viewport().size.x - $MenuControl.rect_size.x, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if Input.is_action_just_pressed("tilde"):
		print_stray_nodes()
#		$ConsoleControl.visible = !$ConsoleControl.visible

func playMap(map:String = map_name):
	$HexGrid.load_map(map)
	$HexGrid._on_PlayButton_pressed()
#	$BattleController/BattleGUI/UnitGUI.visible = true

func editMap(map:String = map_name):
	$HexGrid.load_map(map)

func _on_Menu_pressed():
	$CameraRig.current_target = null
	$HexGrid.clear_map()
	$BattleController.clearAll()
	get_parent().menu.visible = true
	get_parent().bgm.stop()
	get_parent().bg.visible = true
