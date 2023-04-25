extends Spatial


signal trigger_animation_react()
onready var r_attachment = $metarig001/Skeleton/hand_r_attachment/attachment
onready var l_attachment = $metarig001/Skeleton/hand_l_attachment/attachment
onready var effekseer = $EffekseerEmitter
onready var animation_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func emitAnimationSignal():
	emit_signal("trigger_animation_react")

func loadRightEffect() -> void:
	effekseer.effect = load("res://assets/effects/Right_" + $AnimationPlayer.current_animation + ".efkefc")

func loadLeftEffect() -> void:
	effekseer.effect = load("res://assets/effects/Left_" + $AnimationPlayer.current_animation + ".efkefc")

func loadEffectName(anim_name:String) -> void:
	effekseer.effect = load("res://assets/effects/" + anim_name + ".efkefc")

func emitEffect() -> void:
	effekseer.play()

func clear():
	pass
