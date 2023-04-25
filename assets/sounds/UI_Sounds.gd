extends AudioStreamPlayer

func get_class() -> String: return "UI_Sounds"

var alert = preload("res://assets/sounds/ui/Alert.wav")
var popup = preload("res://assets/sounds/ui/Popup.wav")
var unit_create = preload("res://assets/sounds/ui/Unit_Create.wav")
var unit_delete = preload("res://assets/sounds/ui/Unit_Delete.wav")

var card_focus = preload("res://assets/sounds/ui/cards/Card_Focus.wav")
var card_draw = preload("res://assets/sounds/ui/cards/Card_Draw.wav")
var deck_shuffle = preload("res://assets/sounds/ui/cards/Deck_Shuffle.wav")

# UI_Sounds.createSound(UI_Sounds.unit_create)
func createSound(audio:AudioStream):
	var audio_instance = AudioStreamPlayer.new()
	add_child(audio_instance)
	audio_instance.pause_mode = Node.PAUSE_MODE_PROCESS
	audio_instance.stream = audio
	audio_instance.bus = "SFX"
	audio_instance.play()
	yield(audio_instance,"finished")
	remove_child(audio_instance)
	audio_instance.queue_free()
	
