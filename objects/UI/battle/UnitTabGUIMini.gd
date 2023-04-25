extends Control

class_name UnitTabGUIMini

var unit_name:String
var current_health:int
var max_health:int
#  0    1   2       3                 4                  5         6            7
#[From, To, Attack, Attack Modifiers, List of Modifiers, Hit Rate, Crit Chance, Utility Score]
#[agent.card_caster, target.unit, attack_value, attack_multiplier + added_attack, multipliers, hit_rate, critical_hit]
func updateGUI(result) -> void:
	$UnitName.text = result[1].unit_name
	$HP.max_value = result[1].max_health
	$HP.value = result[1].current_health - result[2]
	$HP/HP_Label.text = str(max(0,result[1].current_health - result[2])) + "/" + str(result[1].max_health)
	$HP2.max_value = result[1].max_health
	$HP2.value = result[1].current_health
	$Damage.text = str(result[2]) + " Dmg"
	$HitRate.text = str(result[5]) + "% Hit"
	$HitRate.hint_tooltip = str(result[5]) + "% chance of successfully hitting target."
	$CritRate.text = str(result[6]) + "% Crit"
