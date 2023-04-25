extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().get_parent().connect("damaged",self,"executeTrait")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func executeTrait(card, amount) -> void:
	if get_parent().get_parent().current_health > 0:
		if card.action_costs[card.card_level] > 1:
			get_parent().get_parent().current_health += 4
			get_parent().get_parent().unit_owner.get_parent().battle_gui.addEffectText(name + " + 4" + " HP", get_parent().get_parent())
			get_parent().get_parent().get_node("Character_Mesh").get_node("AnimationPlayer").play("Cast5Sec")
