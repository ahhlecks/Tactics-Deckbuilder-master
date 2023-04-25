extends NinePatchRect

class_name CustomNinePatch

export var message:String
onready var vBox = $VBoxContainer
onready var options = $VBoxContainer/Options
onready var message_node = $VBoxContainer/Label
var close_time:float = 0
var pulsing_time:float = 0
var timer = 0
var fade:bool
var centered:bool
var pos:Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
# warning-ignore:return_value_discarded
	get_tree().get_root().connect("size_changed", self, "update_position")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if close_time != 0:
		if timer <= 1:
			if fade:
				modulate.a = (1 + (0 - 1) * timer)
			timer += delta / close_time
		else:
			free()
	if pulsing_time != 0:
		if timer <= .5:
			modulate.a = (1 + (0 - 1) * timer)
			timer += delta / pulsing_time
		if timer > .5:
			modulate.a = (0 + (1 - 0) * timer)
			timer += delta / pulsing_time
		if timer > 1:
			timer = 0


func update_position() -> void:
	if centered:
		rect_global_position = Vector2(get_viewport().size.x*.5 -(rect_size.x/2), 0)
		if pos != null:
			rect_global_position += pos
	elif pos != null:
		rect_global_position = pos


func setup(new_message:String, new_pos:Vector2 = Vector2(0,0)) -> void:
	pos = new_pos
	message_node.text = new_message
	update_position()


func _on_Label_minimum_size_changed():
	rect_size = message_node.rect_size + Vector2(12,12)
	vBox.rect_size = rect_size
	update_position()


func setupOptions(option1:String = "", option2:String = "", option1_signal_node:Node = null, option2_signal_node:Node = null, option1_signal = null, option2_signal = null, option1_params = [], option2_params = []) -> void:
	if option1 != "" or option2 != "":
		pause_mode = PAUSE_MODE_PROCESS
		get_tree().paused = true
	if option1 != "":
		options.visible = true
		options.get_child(0).visible = true
		options.get_child(0).text = option1
		if option1_signal != null and option1_signal_node != null:
			options.get_child(0).set_meta("node", option1_signal_node)
			options.get_child(0).set_meta("signal", option1_signal)
			options.get_child(0).set_meta("params", option1_params)
			options.get_child(0).grab_focus()
	if option2 != "":
		options.visible = true
		options.get_child(2).visible = true
		options.get_child(2).text = option2
		if option2_signal != null and option2_signal_node != null:
			options.get_child(2).set_meta("node", option2_signal_node)
			options.get_child(2).set_meta("signal", option2_signal)
			options.get_child(2).set_meta("params", option2_params)


func _on_Option1_pressed():
	get_tree().paused = false
	var signal_node = options.get_child(0).get_meta("node")
	var signal_string = options.get_child(0).get_meta("signal")
	var signal_params = options.get_child(0).get_meta("params")
	if signal_node != null and signal_string != null and signal_params != []:
		signal_node.emit_signal(signal_string,signal_params)
	elif signal_node != null and signal_string != null:
		signal_node.emit_signal(signal_string)
	queue_free()


func _on_Option2_pressed():
	get_tree().paused = false
	var signal_node = options.get_child(2).get_meta("node")
	var signal_string = options.get_child(2).get_meta("signal")
	var signal_params = options.get_child(2).get_meta("params")
	if signal_node != null and signal_string != null and signal_params != []:
		signal_node.emit_signal(signal_string,signal_params)
	elif signal_node != null and signal_string != null:
		signal_node.emit_signal(signal_string)
	queue_free()


func _on_Options_minimum_size_changed():
	rect_size = Vector2(max(message_node.rect_size.x, options.rect_size.x), message_node.rect_size.y + options.rect_size.y) + Vector2(12,12)
	vBox.rect_size = rect_size
	update_position()
