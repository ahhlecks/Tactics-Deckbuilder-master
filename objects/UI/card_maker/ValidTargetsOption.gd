extends OptionButton

class_name ValidTargetsOption

# Declare member variables here. Examples:
# var a = 2
# export(int, "all", "self_only", "ally_only", "enemy_only", "self_ally", "self_enemy", "ally_enemy") var valid_targets


# Called when the node enters the scene tree for the first time.
func _ready():
	hint_tooltip = BattleDictionary.valid_parameters[BattleDictionary.PARAMETER.VALID_TARGETS][1]
	add_item("all")
	add_item("self_only")
	add_item("ally_only")
	add_item("enemy_only")
	add_item("self_ally")
	add_item("self_enemy")
	add_item("ally_enemy")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
