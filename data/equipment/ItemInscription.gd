class_name ItemInscription
extends Resource

var data = {
		"card_id": card_data.card_id, #
		"unique_id": card_data.unique_id, #
		"card_name": card_data.card_name, #
		"item": item_data, #
		#"card_owner": card_data.card_owner, #
		"card_class": card_data.card_class, #
		"action_costs": card_data.action_costs,
		"card_level": card_data.card_level, #
		"upgrade_costs": card_data.upgrade_costs, #
		"card_art": card_data.card_art, #
		"card_icon": card_data.card_icon, #
		"card_type": card_data.card_type, #
		"item_type": card_data.item_type, #
		
		"can_attack",
		"can_defend",
		"need_los",
		"is_homing",
		"has_combo",
		"is_piercing",
		"is_shattering",
		"is_consumable",
		"has_counter",
		"has_reflex",
		"self_eliminating",
		"hexagonal_targeting",
		"self_statuses",
		"target_statuses",
		"prerequisites",
		"delay",
		"rarity",
		"description",
		"card_min_range",
		"card_max_range",
		"card_up_vertical_range",
		"card_down_vertical_range",
		#"card_attack",
		"card_added_accuracy",
		"card_added_crit_accuracy",
#		"card_caster": card_caster,
#		"source_cell": source_cell,
#		"target_unit": target_unit,
#		"target_cell": target_cell,
		"card_animation",
		"card_animation_left_weapon",
		"card_animation_right_weapon",
		"card_animation_projectile",
		"bypass_popup",
		"elements",
		"original_card_values"
	}
#var unit_int_modifiable:Array = [
#	"none",
#	"current_health","max_health","current_action_points","max_action_points","current_movement_points",
#	"max_movement_points","current_jump_points","max_jump_points","base_speed","current_speed",
#	"base_physical_evasion","current_physical_evasion","base_magic_evasion","current_magic_evasion",
#	"base_physical_accuracy","current_physical_accuracy","base_magic_accuracy","current_magic_accuracy",
#	"max_draw_points","current_draw_points","base_crit_damage","current_crit_damage","base_crit_chance","current_crit_chance",
#	"base_crit_evasion","current_crit_evasion","elevation","experience","level","block","strength","willpower"]

export(String,"none","card_name","card_class",#"action_costs",
	"card_level", "upgrade_costs","card_type","item_type","can_attack",
	"can_defend","need_los","is_homing","has_combo",
	"is_piercing","is_shattering","is_consumable","has_counter","has_reflex","self_eliminating",
	"hexagonal_targeting","self_statuses","target_statuses","delay","rarity",
	"card_min_range","card_max_range","card_up_vertical_range","card_down_vertical_range",#"card_attack",
	"card_added_accuracy","card_added_crit_accuracy","elements") var card_stat
export(int,-1000, 1000) var card_stat_difference

export(String,"none","current_health","max_health","current_action_points","max_action_points","current_movement_points",
	"max_movement_points","current_jump_points","max_jump_points","base_speed","current_speed",
	"base_physical_evasion","current_physical_evasion","base_magic_evasion","current_magic_evasion",
	"base_physical_accuracy","current_physical_accuracy","base_magic_accuracy","current_magic_accuracy",
	"max_draw_points","current_draw_points","base_crit_damage","current_crit_damage","base_crit_chance","current_crit_chance",
	"base_crit_evasion","current_crit_evasion","elevation","experience","level","block","strength","willpower") var unit_stat
export(int,-1000, 1000) var unit_stat_difference
