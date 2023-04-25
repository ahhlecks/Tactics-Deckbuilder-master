class_name BTCostCheck
extends BTLeaf

func get_class() -> String: return "BTCostCheck"

export(String, "none",
	"current_health",
	"current_action_points",
	"current_movement_points",
	"current_jump_points",
	"current_physical_evasion",
	"current_magic_evasion",
	"current_physical_accuracy",
	"current_magic_accuracy",
	"current_draw_points",
	"block",
	"deflect",
	"strength",
	"willpower",
	"unit_hand_size") var unit_variable:String

export(int) var unit_variable_value: int = 0

func _tick(agent: Node, blackboard: Blackboard) -> bool:
	return succeed()

func isValid(agent:Node) -> bool:
	var result:bool = true
	if unit_variable != "none":
		return (agent.card_caster.get(unit_variable) >= unit_variable_value)
	return result
