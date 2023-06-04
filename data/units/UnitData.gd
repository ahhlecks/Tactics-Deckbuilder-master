class_name UnitData
extends Resource


var deck:Array = [] # Array containing card names only for data storage

var id:String
var player_owned:bool
var is_ai_controlled:bool
var ai_type:int = 0

var evasion_degradation:float = 0
var evasion_degradation_amount:float = 5.0

var unit_name:String
var team:int
var unit_class:int
var unit_class_name:String
var bio:String
var current_health:int
var max_health:int
var current_action_points:int
var max_action_points:int
var base_action_points_regen:int
var current_action_points_regen:int
var current_movement_points:int
var max_movement_points:int
var current_jump_points:int
var max_jump_points:int
var base_speed:float
var current_speed:float
var base_physical_accuracy:float
var current_physical_accuracy:float
var base_magic_accuracy:float
var current_magic_accuracy:float
var base_physical_evasion:float
var current_physical_evasion:float
var base_magic_evasion:float
var current_magic_evasion:float
var base_draw_points:int
var current_draw_points:int
var base_crit_damage:float
var current_crit_damage:float
var base_crit_chance:float
var current_crit_chance:float
var base_crit_evasion:float
var current_crit_evasion:float
var experience:int
var level:int
var block:int
var strength:int
var willpower:int
var aggro:int
var passives:Array
var skills:Array
var items:Array


func save() -> Dictionary:
	var save_dict = {
		"unit_name" : unit_name,
		"team" : team,
		"unit_class" : unit_class,
		"unit_class_name" : unit_class_name,
		"bio": bio,
		"max_health" : max_health,
		"max_action_points" : max_action_points,
		"base_action_points_regen" : base_action_points_regen,
		"max_movement_points" : max_movement_points,
		"max_jump_points" : max_jump_points,
		"base_speed" : base_speed,
		"base_physical_accuracy" : base_physical_accuracy,
		"base_magic_accuracy" : base_magic_accuracy,
		"base_physical_evasion" : base_physical_evasion,
		"base_magic_evasion" : base_magic_evasion,
		"base_draw_points" : base_draw_points,
		"base_crit_damage" : base_crit_damage,
		"base_crit_chance" : base_crit_chance,
		"base_crit_evasion" : base_crit_evasion,
		"experience" : experience,
		"level" : level,
		"block" : block,
		"strength" : strength,
		"willpower" : willpower,
		"aggro" : aggro,
		"passives" : passives,
		"skills" : skills,
		"player_owned" : player_owned,
		"is_ai_controlled" : is_ai_controlled,
		"id" : id,
		}
	return save_dict
