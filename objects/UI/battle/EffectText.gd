extends Label

onready var animation:AnimationPlayer = $AnimationPlayer
export var screen_pos:Vector2
var text_target:Spatial
onready var animation_name:String = "EffectTextPlay"
signal end_text

func _ready():
	visible = false

func _process(delta):
	if text_target != null:
		rect_position = get_viewport().get_camera().unproject_position(text_target.translation) + screen_pos - (Vector2(rect_size.x/2,64) * rect_scale.x)

func addText(message:String, target:Spatial) -> void:
	text = message
	if text.begins_with("Critical"):
#		text = text.substr(10)
		animation_name = "EffectTextPlayCrit"
	if text.begins_with("+"):
#		text = text.substr(5)
		animation_name = "EffectTextPlayHeal"
	text_target = target

func playText() -> void:
	if text != "" and text_target != null:
		visible = not get_viewport().get_camera().is_position_behind(text_target.translation)
		animation.play(animation_name)
		yield(animation,"animation_finished")
		animation.call_deferred("queue_free")
		get_parent().remove_child(self)
		queue_free()


func _on_EffectText_tree_exited():
	emit_signal("end_text")

func _init():
	GameUtils.connect("freeing_orphans", self, "_free_if_orphaned")

func _free_if_orphaned():
	if not is_inside_tree(): # Optional check - don't free if in the scene tree
		queue_free()
