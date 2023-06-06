class_name ItemInscription
extends Resource

export(String, "upgrade_costs", "can_attack", "can_defend","need_los","is_homing",
		"has_combo","is_piercing","is_shattering","is_consumable", "has_counter","has_reflex","self_eliminating",
		"hexagonal_targeting","self_statuses","target_statuses", "prerequisites","delay",
		"card_min_range","card_max_range","card_up_vertical_range","card_down_vertical_range",
		"card_added_accuracy","card_added_crit_accuracy","card_animation","card_animation_left_weapon","card_animation_right_weapon",
		"card_animation_projectile","bypass_popup","elements") var card_stat
#var unit_int_modifiable:Array = [
#	"none",
#	"current_health","max_health","current_action_points","max_action_points","current_movement_points",
#	"max_movement_points","current_jump_points","max_jump_points","base_speed","current_speed",
#	"base_physical_evasion","current_physical_evasion","base_magic_evasion","current_magic_evasion",
#	"base_physical_accuracy","current_physical_accuracy","base_magic_accuracy","current_magic_accuracy",
#	"max_draw_points","current_draw_points","base_crit_damage","current_crit_damage","base_crit_chance","current_crit_chance",
#	"base_crit_evasion","current_crit_evasion","elevation","experience","level","block","strength","willpower"]


export(int,-1000, 1000) var card_stat_difference

export(String,"current_health","max_health","current_action_points","max_action_points","current_movement_points",
	"max_movement_points","current_jump_points","max_jump_points","base_speed","current_speed",
	"base_physical_evasion","current_physical_evasion","base_magic_evasion","current_magic_evasion",
	"base_physical_accuracy","current_physical_accuracy","base_magic_accuracy","current_magic_accuracy",
	"max_draw_points","current_draw_points","base_crit_damage","current_crit_damage","base_crit_chance","current_crit_chance",
	"base_crit_evasion","current_crit_evasion","elevation","experience","level","block","strength","willpower") var unit_stat
export(int,-1000, 1000) var unit_stat_difference
