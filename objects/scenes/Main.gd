extends Node

# The very first scene to be loaded when opening the game
onready var bg = $BG
onready var bgm = $BGM
onready var sfx = $SFX
onready var world_scene = $WorldScene
onready var unit_maker = $UnitMaker
onready var card_maker = $CardMaker
onready var menu = $MenuScene

var card_draw = preload("res://assets/sounds/ui/cards/Card_Draw.wav")
var deck_shuffle = preload("res://assets/sounds/ui/cards/Deck_Shuffle.wav")

var music_paths = {
	0 : "res://assets/music/battle/",
	1 : "res://assets/music/boss_battle/",
	2 : "res://assets/music/menu/",
	}

# Called when the node enters the scene tree for the first time.
func _ready():
# warning-ignore:return_value_discarded
	get_tree().get_root().connect("size_changed", self, "update_position")
	update_position()
	
	UnitLoader.copyRecursively(PlayerVars.ALLY_UNIT_LOAD_DIR_, PlayerVars.ALLY_UNIT_SAVE_DIR_)
	UnitLoader.copyRecursively(PlayerVars.ENEMY_UNIT_LOAD_DIR_, PlayerVars.ENEMY_UNIT_SAVE_DIR_)
	CardLoader.copyRecursively(PlayerVars.CARD_LOAD_DIR_, PlayerVars.CARD_SAVE_DIR_)
	MapLoader.copyRecursively(PlayerVars.MAP_LOAD_DIR_, PlayerVars.MAP_SAVE_DIR_)

func update_position() -> void:
	bg.rect_size = get_viewport().size

#Menu Key
#func _input(event):
#	if Input.is_action_just_pressed("print"):
#		print_stray_nodes()

func playMap(map:String) -> void:
	world_scene.visible = true
	world_scene.playMap(map)
	bg.visible = false
#	$BGM.stream = load(music_paths.get(0) + "battle_music1.mp3")
#	$BGM.play()

func playUserMap(map:String) -> void:
	world_scene.visible = true
	world_scene.playMap(map)
	bg.visible = false
#	$BGM.stream = load(music_paths.get(0) + "battle_music1.mp3")
#	$BGM.play()

func _on_Card_Editor_pressed():
	menu.visible = false
	card_maker.openCardMaker()
	card_maker.visible = true


func _on_Unit_Editor_pressed():
	menu.visible = false
	unit_maker._ready()
	unit_maker.menuReady()
	unit_maker.visible = true


func _on_Map_Editor_pressed():
	menu.visible = false
	world_scene.visible = true
	bg.visible = false
