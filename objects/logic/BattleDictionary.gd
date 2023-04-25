extends Node

const CARD_SAVE_DIR:String = "user://cards/"
var card_list_file:String = "card_list.dat"

var card_list:Array = []

var job_list:Array = ["Knight","Vanguard","Barbarian","Fencer","Archer","Thief","Assassin","Druid","Sorcerer","Illusionist","Healer","Battlemage"]

enum {ARG_INT, ARG_BOOL, ARG_FLOAT, ARG_STRING, ARG_ARRAY, ARG_CARD, ARG_CELL, ARG_UNIT, ARG_PLAYER, ARG_STATUS,
		ARG_CONDITION, ARG_EFFECT, ARG_TRIGGER, ARG_STAT}

var path:String = "res://resources/cards/BattleDictionary.json"

var unitChoices:Array = ["Self Unit", "Target Unit", "Effected Targets", "All Targets"]
var cellChoices:Array = ["Self Cell", "Target Cell", "Effected Cells", "All Cells"]

enum PLAYER {SELF, ALLY, ENEMY}

enum CARD_CLASS {WARRIOR,RANGER,MAGE,WARRIORRANGER,RANGERMAGE,MAGEWARRIOR,ALL}

enum CARD_TYPE {SKILL,PHYSICALATTACK,MAGICATTACK,MAGICSPELL,ITEM}

enum TRIGGER {UNIT_MOVED, UNIT_ACTED, UNIT_DIED, TURN_ENDED, SELF_TURN_ENDED, ENEMY_TURN_ENDED,
		TURN_STARTED, SELF_TURN_STARTED, ENEMY_TURN_STARTED}

enum UNIT_STAT {NONE, TEAM, UNIT_CLASS, CURRENT_HEALTH, MAX_HEALTH, CURRENT_ACTION_POINTS, MAX_ACTION_POINTS, ACTION_POINTS_REGEN,
CURRENT_MOVEMENT_POINTS, MAX_MOVEMENT_POINTS, CURRENT_JUMP_POINTS, MAX_JUMP_POINTS, 
BASE_SPEED, CURRENT_SPEED, BASE_PHYSICAL_EVASION, CURRENT_PHYSICAL_EVASION, BASE_MAGIC_EVASION, CURRENT_MAGIC_EVASION,
MAX_DRAW_POINTS, CURRENT_DRAW_POINTS, ELEVATION, EXPERIENCE, LEVEL, BLOCK, DEFLECT, STRENGTH, WILLPOWER,
UNIT_DECK_SIZE, UNIT_HAND_SIZE, UNIT_DISCARD_SIZE}

enum CARD_STAT {NONE, CARD_NAME, CARD_CLASS, ACTION_COSTS, CARD_LEVEL, UPGRADE_COSTS, CARD_TYPE, CAN_ATTACK, CAN_DEFEND,
NEED_LOS, IS_HOMING, IS_UNBLOCKABLE, IS_UNDEFLECTABLE, IS_CONSUMABLE, HAS_COUNTER, HAS_REFLEX, SELF_STATUSES, TARGET_STATUSES, 
DELAY, RARITY, CARD_MIN_RANGE, CARD_MAX_RANGE, CARD_UP_VERTICAL_RANGE, CARD_DOWN_VERTICAL_RANGE, CARD_ATTACK, ELEMENTS}

enum DIRECTION {EAST, SOUTHEAST, SOUTHWEST, WEST, NORTHWEST, NORTHEAST}

enum STATUS {NONE,PHYSICALATTACKUP,PHYSICALATTACKUP2,PHYSICALATTACKDOWN,PHYSICALATTACKDOWN2,PHYSICALDEFENSEUP,PHYSICALDEFENSEUP2,PHYSICALDEFENSEDOWN,PHYSICALDEFENSEDOWN2,
		MAGICATTACKUP,MAGICATTACKUP2,MAGICATTACKDOWN,MAGICATTACKDOWN2,MAGICDEFENSEUP,MAGICDEFENSEUP2,MAGICDEFENSEDOWN,MAGICDEFENSEDOWN2,
		FIREATTACKUP,FIREATTACKUP2,FIREATTACKDOWN,FIREATTACKDOWN2,FIREDEFENSEUP,FIREDEFENSEUP2,FIREDEFENSEDOWN,FIREDEFENSEDOWN2,
		ICEATTACKUP,ICEATTACKUP2,ICEATTACKDOWN,ICEATTACKDOWN2,ICEDEFENSEUP,ICEDEFENSEUP2,ICEDEFENSEDOWN,ICEDEFENSEDOWN2,
		ELECTRICATTACKUP,ELECTRICATTACKUP2,ELECTRICATTACKDOWN,ELECTRICATTACKDOWN2,ELECTRICDEFENSEUP,ELECTRICDEFENSEUP2,ELECTRICDEFENSEDOWN,ELECTRICDEFENSEDOWN2,
		STATCHANGE}

enum ELEMENT {NONE,FIRE,ICE,ELECTRIC,LIGHT,DARK}

enum WIN_CONDITION {KILLALLENEMIES,KILLNUMENEMIES,REACHLOCATION,REACHLOCATIONNUMTURNS,KILLUNIT,REVIVEUNIT}

enum PARAMETER {INT, UINT, CARD_NAME, CARD_SOURCE, FALLBACK, INT_SOURCE, TARGET_SOURCE, TARGET_CALCULATION, TARGET_CONDITION, OPERATION, COMPARISON, ARRAY_CHECK, INT_ARG,
		UNIT_VARIABLE, UNIT_DECK, VALID_TARGETS, CARD_VARIABLE, UNIT_COST_VARIABLE, PLAYER_VARIABLE, UNIT_INT_VARIABLE, UNIT_INT_MODIFIABLE, STATUS}

# [Parameter ID, Parameter Description, Parameter Size]

var valid_parameters:Array = [
	[PARAMETER.INT, "Integer"],
	[PARAMETER.UINT, "Positive integer"],
	[PARAMETER.CARD_NAME, "Cards"],
	[PARAMETER.CARD_SOURCE, "Card Source"],
	[PARAMETER.FALLBACK, "Draw Cards even if requirements are not satisfied."],
	[PARAMETER.INT_SOURCE, "Integer Source"],
	[PARAMETER.TARGET_SOURCE, "Target Source"],
	[PARAMETER.TARGET_CALCULATION, "Target Calculation"],
	[PARAMETER.TARGET_CONDITION, "Target Condition"],
	[PARAMETER.OPERATION, "Operation"],
	[PARAMETER.COMPARISON, "Comparison"],
	[PARAMETER.ARRAY_CHECK, "Array check"],
	[PARAMETER.INT_ARG, "Integer argument"],
	[PARAMETER.UNIT_VARIABLE, "Unit Variable"],
	[PARAMETER.UNIT_DECK, "Unit Deck"],
	[PARAMETER.VALID_TARGETS, "Valid Targets"],
	[PARAMETER.CARD_VARIABLE, "Card Variable"],
	[PARAMETER.UNIT_COST_VARIABLE, "Unit Cost Variable"],
	[PARAMETER.PLAYER_VARIABLE, "Player Variable"],
	[PARAMETER.UNIT_INT_VARIABLE, "Player Integer Variable"],
	[PARAMETER.UNIT_INT_MODIFIABLE, "Player Integer Variable"],
	[PARAMETER.STATUS, "Status"]
]

var valid_bt_composites:Array = [
	["BTSelector", "Ticks its children until ANY of them succeeds, thus succeeding."],
	["BTSequence", "Ticks its children as long as ALL of them are successful.Fails if ANY of the children fails."],
	["BTRandomSelector", "Ticks its children in random order until ANY of them succeeds, thus succeeding."],
	["BTRandomSequence", "Ticks its children in random order as long as ALL of them are successful."],
]

var valid_bt_decorators:Array = [
	["BTInvert", "Succeeds if the child fails and viceversa."],
	["BTAlwaysSucceed", "Executes the child and always succeeds."],
	["BTAlwaysFail", "Executes the child and always fails."],
	["BTRepeat", "Executes the child x times.", [PARAMETER.UINT]],
	["BTRepeatUntil", "Repeats until specified state is returned, then sets state to child state.", [PARAMETER.UINT]],
	["BTCheckLastCard", "Executes the child bt_node if unit's last played card is designated card.", [PARAMETER.TARGET_SOURCE, PARAMETER.TARGET_CONDITION, PARAMETER.CARD_NAME]],
	["BTConditional", "Succeed or fail based on a conditional check between int_arg1 and int_arg2 that are set with BTSetIntArg", [PARAMETER.COMPARISON,PARAMETER.ARRAY_CHECK]],
]

var valid_bt_leaves:Array = [
	["Attack", "This will execute an attack or heal (heal with negative values)", [PARAMETER.VALID_TARGETS]],
	["SetSingleTarget", "Sets the target as the designated single target space.", [PARAMETER.TARGET_SOURCE, PARAMETER.VALID_TARGETS]],
	["SetSplashTargets", "Sets the splash area. (min range, max range, up range, down range, valid targets)", [PARAMETER.TARGET_SOURCE,PARAMETER.UINT,PARAMETER.UINT,PARAMETER.UINT,PARAMETER.UINT,PARAMETER.VALID_TARGETS]],
	["SetInlineTargets", "Sets a line of targets.\nCard must use Hexagonal Targeting or have 1 min and max range to work.\n(inner range, outer range, up range, down range, valid targets)", [PARAMETER.UINT,PARAMETER.UINT,PARAMETER.UINT,PARAMETER.UINT,PARAMETER.VALID_TARGETS]],
	["SetLeftRightTargets", "Sets left and right of target.\nCard must use Hexagonal Targeting or have 1 min and max range to work.\n(width, depth, up range, down range, valid targets)", [PARAMETER.UINT,PARAMETER.UINT,PARAMETER.UINT,PARAMETER.UINT,PARAMETER.VALID_TARGETS]],
	["ClearTargets", "Clear blackboard of any targets."],
	["SetIntArg", "Set an integer value for int_arg1 or int_arg2", [PARAMETER.INT_ARG,PARAMETER.INT_SOURCE]],
	#["SetStatus", "Apply status effects from this card to valid targets."],
	["CasterAddStatus", "Add a new status effect with duration to caster of this card.", [PARAMETER.STATUS, PARAMETER.UINT]],
	["TargetAddStatus", "Add a new status effect with duration to target of this card.", [PARAMETER.STATUS, PARAMETER.UINT, PARAMETER.VALID_TARGETS]],
	["CasterDrawCard", "Caster draws x amount of cards from designated deck.", [PARAMETER.UINT, PARAMETER.UNIT_DECK, PARAMETER.CARD_VARIABLE, PARAMETER.COMPARISON, PARAMETER.FALLBACK]],
	["TargetDrawCard", "Target draws x amount of cards from designated deck.", [PARAMETER.UINT, PARAMETER.UNIT_DECK, PARAMETER.CARD_VARIABLE, PARAMETER.VALID_TARGETS, PARAMETER.COMPARISON, PARAMETER.FALLBACK]],
	["CasterModifyStat", "Modify a stat for the caster of this card.", [PARAMETER.OPERATION, PARAMETER.UNIT_INT_MODIFIABLE, PARAMETER.INT, PARAMETER.INT_ARG]],
	["TargetModifyStat", "Modify a stat for the target of this card.", [PARAMETER.OPERATION, PARAMETER.UNIT_INT_MODIFIABLE, PARAMETER.INT, PARAMETER.INT_ARG, PARAMETER.VALID_TARGETS]],
	["CasterModifyStatDuration", "Modify a stat for the caster of this card with duration. (Operation, Stat, Stat Value, Set Stat Value to Int_Arg (Optional), Duration)", [PARAMETER.OPERATION, PARAMETER.UNIT_INT_MODIFIABLE, PARAMETER.INT, PARAMETER.INT_ARG, PARAMETER.UINT]],
	["TargetModifyStatDuration", "Modify a stat for the target of this card with duration. (Operation, Stat, Stat Value, Set Stat Value to Int_Arg (Optional), Duration, Valid Targets)", [PARAMETER.OPERATION, PARAMETER.UNIT_INT_MODIFIABLE, PARAMETER.INT, PARAMETER.INT_ARG, PARAMETER.UINT, PARAMETER.VALID_TARGETS]],
	["CasterAddCard", "Caster adds a new card to a designated deck. (Number of cards, card name, card level, to_deck)", [PARAMETER.UINT, PARAMETER.CARD_NAME, PARAMETER.UINT, PARAMETER.UNIT_DECK]],
	["TargetAddCard", "Target adds a new card to a designated deck. (Number of cards, card name, card level, to_deck, valid targets)", [PARAMETER.UINT, PARAMETER.CARD_NAME, PARAMETER.UINT, PARAMETER.UNIT_DECK, PARAMETER.VALID_TARGETS]],
	["HandModifyStat", "Modify a stat for the cards in hand until end of turn. (Operation, Stat, Stat Value, Card Requirement, Card Requirement Value, Int Arg)", [PARAMETER.OPERATION, PARAMETER.CARD_VARIABLE, PARAMETER.CARD_VARIABLE, PARAMETER.INT_ARG]],
	["CardModifyStat", "Modify a stat for this card until end of turn. (Operation, Stat, Stat Value, Int Arg (Optional))", [PARAMETER.OPERATION, PARAMETER.CARD_VARIABLE, PARAMETER.INT_ARG]],
	["Pull", "Pull target towards caster of this card. (Strength of Pull)", [PARAMETER.VALID_TARGETS, PARAMETER.UINT]],
	["Push", "Push target towards caster of this card. (Strength of Push)", [PARAMETER.VALID_TARGETS, PARAMETER.UINT]]
]

var int_source:Array = [
	"integer",
	"card_caster",
	"card_target",
	"card_variable"
]
var valid_card_stats:Array = [
	"none",
	"card_name",
	"card_class",
	"action_costs",
	"card_level",
	"upgrade_costs",
	"card_type",
	"can_attack", #7
	"can_defend", #8
	"need_los", #9
	"is_homing", #10
	"has_combo", #11
	"is_unblockable", #12
	"is_undeflectable", #13
	"is_consumable", #14
	"has_counter", #15
	"has_reflex", #16
	"self_statuses",
	"target_statuses",
	"delay",
	"rarity",
	"card_min_range",
	"card_max_range",
	"card_up_vertical_range",
	"card_down_vertical_range",
	"card_attack",
	"elements",
]

var valid_unit_stats:Array = [
	"none",
	"team",
	"unit_class",
	"current_health",
	"max_health",
	"current_action_points",
	"max_action_points",
	"current_movement_points",
	"max_movement_points",
	"current_jump_points",
	"max_jump_points",
	"base_speed",
	"current_speed",
	"base_physical_evasion",
	"current_physical_evasion",
	"base_magic_evasion",
	"current_magic_evasion",
	"base_physical_accuracy",
	"current_physical_accuracy",
	"base_magic_accuracy",
	"current_magic_accuracy",
	"max_draw_points",
	"current_draw_points",
	"base_crit_damage",
	"current_crit_damage",
	"elevation",
	"experience",
	"level",
	"block",
	"deflect",
	"strength",
	"willpower",
	"unit_deck_size",
	"unit_hand_size",
	"unit_discard_size",
	"unit_consumed_size",
]

# Anything you can deduct from the unit
var valid_unit_cost_stats:Array = [
	"none",
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
	"unit_hand_size",
]

var valid_unit_decks:Array = [
	"active_deck",
	"hand_deck",
	"discard_deck",
	"consumed_deck"
]

var unit_int_vars:Array = [
	"none",
	"current_health",
	"max_health",
	"current_action_points",
	"max_action_points",
	"current_movement_points",
	"max_movement_points",
	"current_jump_points",
	"max_jump_points",
	"base_speed",
	"current_speed",
	"base_physical_evasion",
	"current_physical_evasion",
	"base_magic_evasion",
	"current_magic_evasion",
	"base_physical_accuracy",
	"current_physical_accuracy",
	"base_magic_accuracy",
	"current_magic_accuracy",
	"max_draw_points",
	"current_draw_points",
	"base_crit_damage",
	"current_crit_damage",
	"elevation",
	"experience",
	"level",
	"block",
	"deflect",
	"strength",
	"willpower",
	"unit_deck_size",
	"unit_hand_size",
	"unit_discard_size",
	"unit_consumed_size"
]

var unit_int_modifiable:Array = [
	"none",
	"current_health",
	"max_health",
	"current_action_points",
	"max_action_points",
	"current_movement_points",
	"max_movement_points",
	"current_jump_points",
	"max_jump_points",
	"base_speed",
	"current_speed",
	"base_physical_evasion",
	"current_physical_evasion",
	"base_magic_evasion",
	"current_magic_evasion",
	"base_physical_accuracy",
	"current_physical_accuracy",
	"base_magic_accuracy",
	"current_magic_accuracy",
	"max_draw_points",
	"current_draw_points",
	"base_crit_damage",
	"current_crit_damage",
	"base_crit_chance",
	"current_crit_chance",
	"elevation",
	"experience",
	"level",
	"block",
	"deflect",
	"strength",
	"willpower"
]

var card_int_vars:Array = [
	"none",
	"action_cost",
	"card_level",
	"upgrade_cost",
	"delay",
	"rarity",
	"card_min_range",
	"card_max_range",
	"card_up_vertical_range",
	"card_down_vertical_range",
	"card_attack"
]

var int_arg_vars:Array = [
	"none",
	"int_arg1",
	"int_arg2"
]

var valid_statuses:Array = [
	["None", "None"],
	["Physical Attack UP", "Physical attacks deal 25% more damage.", "Buff"],
	["Physical Attack UP 2", "Physical attacks deal 50% more damage.", "Buff"],
	["Physical Attack DOWN", "Physical attacks deal 25% less damage.", "Debuff"],
	["Physical Attack DOWN 2", "Physical attacks deal 50% less damage.", "Debuff"],
	["Physical Defense UP", "Take 25% less damage when damaged by physical attack.", "Buff"],
	["Physical Defense UP 2", "Take 50% less damage when damaged by physical attack.", "Buff"],
	["Physical Defense DOWN", "Take 25% more damage when damaged by physical attack.", "Debuff"],
	["Physical Defense DOWN 2", "Take 50% more damage when damaged by physical attack.", "Debuff"],
	["Magic Attack UP", "Magic attacks deal 25% more damage.", "Buff"],
	["Magic Attack UP 2", "Magic attacks deal 50% more damage.", "Buff"],
	["Magic Attack DOWN", "Magic attacks deal 25% less damage.", "Debuff"],
	["Magic Attack DOWN 2", "Magic attacks deal 50% less damage.", "Debuff"],
	["Magic Defense UP", "Take 25% less damage when damaged by magic attack.", "Buff"],
	["Magic Defense UP 2", "Take 50% less damage when damaged by magic attack.", "Buff"],
	["Magic Defense DOWN", "Take 25% more damage when damaged by magic attack.", "Debuff"],
	["Magic Defense DOWN 2", "Take 50% more damage when damaged by magic attack.", "Debuff"],
	["Fire Attack UP", "Fire elemental attacks deal 25% more damage.", "Buff"],
	["Fire Attack UP 2", "Fire elemental attacks deal 50% more damage.", "Buff"],
	["Fire Attack DOWN", "Fire elemental attacks deal 25% less damage.", "Debuff"],
	["Fire Attack DOWN 2", "Fire elemental attacks deal 50% less damage.", "Debuff"],
	["Fire Defense UP", "Take 25% less damage when damaged by fire attack.", "Buff"],
	["Fire Defense UP 2", "Take 50% less damage when damaged by fire attack.", "Buff"],
	["Fire Defense DOWN", "Take 25% more damage when damaged by fire attack.", "Debuff"],
	["Fire Defense DOWN 2", "Take 50% more damage when damaged by fire attack.", "Debuff"],
	["Ice Attack UP", "Ice elemental attacks deal 25% more damage.", "Buff"],
	["Ice Attack UP 2", "Ice elemental attacks deal 50% more damage.", "Buff"],
	["Ice Attack DOWN", "Ice elemental attacks deal 25% less damage.", "Debuff"],
	["Ice Attack DOWN 2", "Ice elemental attacks deal 50% less damage.", "Debuff"],
	["Ice Defense UP", "Take 25% less damage when damaged by ice attack.", "Buff"],
	["Ice Defense UP 2", "Take 50% less damage when damaged by ice attack.", "Buff"],
	["Ice Defense DOWN", "Take 25% more damage when damaged by ice attack.", "Debuff"],
	["Ice Defense DOWN 2", "Take 50% more damage when damaged by ice attack.", "Debuff"],
	["Electric Attack UP", "Electric elemental attacks deal 25% more damage.", "Buff"],
	["Electric Attack UP 2", "Electric elemental attacks deal 50% more damage.", "Buff"],
	["Electric Attack DOWN", "Electric elemental attacks deal 25% less damage.", "Debuff"],
	["Electric Attack DOWN 2", "Electric elemental attacks deal 50% less damage.", "Debuff"],
	["Electric Defense UP", "Take 25% less damage when damaged by electric attack.", "Buff"],
	["Electric Defense UP 2", "Take 50% less damage when damaged by electric attack.", "Buff"],
	["Electric Defense DOWN", "Take 25% more damage when damaged by electric attack.", "Debuff"],
	["Electric Defense DOWN 2", "Take 50% more damage when damaged by electric attack.", "Debuff"],
	["StatChange", "Description", "Buff or Debuff", "Stat", "Value", "Operation"]
]

var valid_animations:Array = [
	"None", "Beckon", "Block", "Cast", "Cast1Sec", "Cast2", "Cast2Long", "Cast5Sec", "Cast15Sec", "CastDischarge3Sec_1Sec", "CastDischarge3Sec_2Sec",
	"CastLoop", "ChargeLoop", "ChargeUp", "ChargeUp2", "Die", "Dodge", "Hurt", "Hurt2", "HurtLoop", "Idle", "Jump", "JumpKick", "JumpQuick", "Kick",
	"LegSweep", "LowGuard", "Mordhau", "No", "Parry", "Point", "PolearmAttack", "PolearmAttack2", "PolearmAttack3", "Punch", "ShieldBash", 
	"Shoot", "ShootHigh", "SpinAttack", "Stab", "SwordAttack", "SwordAttack2", "SwordShieldTaunt", "ThrustAttack", "Walk", "Yes"
]

var valid_weapons:Array = [
	"None", "Axe", "BattleStaff", "Bow", "Dagger", "DoubleAxe", "GiantAxe", "LongSword", "Mace", "Rapier", "Shield", "Spear", "Sword", "SwordStaff",
	"WarHammer", "WarScythe", "Zweihander"
]

"""
A modifier has these three things.
When this happens (Trigger), If this happens (Condition), Then this happens (Effect)
"""
var valid_conditions:Array = [
	["unit_has_status", "Check if unit has a status.", [["Target unit: ", ARG_UNIT], ["Select status: ", ARG_STATUS]]],
	["unit_was_targeted", "Check if unit was targeted.", [["Target unit: ", ARG_UNIT]]],
	["unit_was_damaged", "Check if unit was damaged.", [["Target unit: ", ARG_UNIT]]],
	["unit_played_card", "Check if unit has played a certain card.", [["Target unit: ", ARG_UNIT], ["Select card: ", ARG_CARD]]],
	["unit_accumulated_stat", "Check if unit has accumulated a stat.", [["Target unit: ", ARG_UNIT], ["Select stat: ", ARG_STAT]]],
	["unit_is_level", "Check if unit is at a level.", [["Target unit: ", ARG_UNIT], ["Level: ", ARG_INT]]],
	["unit_is_class", "Check if unit is a certain class.", [["Target unit: ", ARG_UNIT], ["Class (0 = Warrior, 1 = Ranger, 2 = Mage, 3 = WARRIORRANGER, 4 = RANGERMAGE, 5 = MAGEWARRIOR, 6 = ALL): ",ARG_INT]]],
	["card_is_level", "Check if a card is at a level.", [["Card User: ", ARG_UNIT], ["Level: ", ARG_INT]]],
	["card_is_class", "Check if card is a certain class.", [["Card User: ", ARG_UNIT], ["Class (0 = Warrior, 1 = Ranger, 2 = Mage, 3 = WARRIORRANGER, 4 = RANGERMAGE, 5 = MAGEWARRIOR, 6 = ALL): ): ",ARG_INT]]],
	["card_is_type", "Check if card is a certain type.", [["Card User: ", ARG_UNIT], ["Type (0 = SKILL, 1 = PHYSICALATTACK, 2 = MAGICATTACK, 3 = MAGICSPELL, 4 = ITEM): ", ARG_INT]]],
	["card_has_element", "Check if unit has a status.", [["Card User: ", ARG_UNIT], ["Element (0 = None 1 = Fire, 2 = Ice, 3 = Electric): ", ARG_INT]]],
	["card_has_range", "Check if unit has a status.", [["Card User: ", ARG_UNIT], ["Range: ", ARG_INT]]],
	["card_range_less_than", "Check if unit has a status.", [["Card User: ", ARG_UNIT], ["Range: ", ARG_INT]]],
	["card_range_more_than", "Check if unit has a status.", [["Card User: ", ARG_UNIT], ["Range: ", ARG_INT]]],
	["card_has_vertical_range", "Check if unit has a status.", [["Card User: ", ARG_UNIT], ["Range: ", ARG_INT]]],
	["card_vertical_range_less_than", "Check if unit has a status.", [["Card User: ", ARG_UNIT], ["Range: ", ARG_INT]]],
	["card_vertical_range_more_than", "Check if unit has a status.", [["Card User: ", ARG_UNIT], ["Range: ", ARG_INT]]],
	["card_has_attack", "Check if unit has a status.", [["Card User: ", ARG_UNIT], ["Attack: ", ARG_INT]]],
	["card_attack_less_than", "Check if unit has a status.", [["Card User: ", ARG_UNIT], ["Attack: ", ARG_INT]]],
	["card_attack_more_than", "Check if unit has a status.", [["Card User: ", ARG_UNIT], ["Attack: ", ARG_INT]]],
	["card_can_attack", "Check if unit has a status.", [["Card User: ", ARG_UNIT], ["True/False: ", ARG_BOOL]]],
	["card_can_defend", "Check if unit has a status.", [["Card User: ", ARG_UNIT], ["True/False: ", ARG_BOOL]]],
	["card_has_rarity", "Check if unit has a status.", [["Card User: ", ARG_UNIT], ["Rarity: ", ARG_INT]]],
	["card_rarity_less_than", "Check if unit has a status.", [["Card User: ", ARG_UNIT], ["Rarity: ", ARG_INT]]],
	["card_rarity_more_than", "Check if unit has a status.", [["Card User: ", ARG_UNIT], ["Rarity: ", ARG_INT]]],
	["player_has_lower_card_num", "Check if unit has a status.", [["Player: ", ARG_PLAYER], ["Number of cards in hand: ", ARG_INT]]],
	["player_has_higher_card_num", "Check if unit has a status.", [["Player: ", ARG_PLAYER], ["Number of cards in hand: ", ARG_INT]]],
	["player_has_same_card_num", "Check if unit has a status.", [["Player: ", ARG_PLAYER], ["Number of cards in hand: ", ARG_INT]]],
	["cell_is_type", "Check if unit has a status.", [["Cell: ", ARG_CELL], ["Surface type: ", ARG_INT]]],
	["unit_was_pushed", "Check if unit has a status.", [["Unit: ", ARG_UNIT]]],
	["unit_was_pulled", "Check if unit has a status.", [["Unit: ", ARG_UNIT]]],
	["unit_has_leveled", "Check if unit has a status.", [["Unit: ", ARG_UNIT]]],
	["unit_has_item", "Check if unit has a status.", [["Unit: ", ARG_UNIT]]],
	["unit_is_alive", "Check if unit has a status.", [["Unit: ", ARG_UNIT]]],
	["unit_is_dead", "Check if unit has a status.", [["Unit: ", ARG_UNIT]]],
	["unit_is_critical", "Check if unit has a status.", [["Unit: ", ARG_UNIT]]],
	["unit_is_distance", "Check if unit has a status.", [["Unit: ", ARG_UNIT], ["Distance: ", ARG_INT]]],
	["unit_has_higher_distance", "Check if unit has a status.", [["Source unit: ", ARG_UNIT], ["Target unit: ", ARG_UNIT], ["Distance: ", ARG_INT]]],
	["unit_has_lower_distance", "Check if unit has a status.", [["Source unit: ", ARG_UNIT], ["Target unit: ", ARG_UNIT], ["Distance: ", ARG_INT]]],
	["unit_has_lower_HP", "Check if unit has a status.", [["Source unit: ", ARG_UNIT], ["Target unit: ", ARG_UNIT], ["or Target HP: ", ARG_INT]]],
	["unit_has_higher_HP", "Check if unit has a status.", [["Source unit: ", ARG_UNIT], ["Target unit: ", ARG_UNIT], ["or Target HP: ", ARG_INT]]],
	["unit_has_same_HP", "Check if unit has a status.", [["Source unit: ", ARG_UNIT], ["Target unit: ", ARG_UNIT], ["or Target HP: ", ARG_INT]]],
	["unit_has_lower_AP", "Check if unit has a status.", [["Source unit: ", ARG_UNIT], ["Target unit: ", ARG_UNIT], ["or Target AP: ", ARG_INT]]],
	["unit_has_higher_AP", "Check if unit has a status.", [["Source unit: ", ARG_UNIT], ["Target unit: ", ARG_UNIT], ["or Target AP: ", ARG_INT]]],
	["unit_has_same_AP", "Check if unit has a status.", [["Source unit: ", ARG_UNIT], ["Target unit: ", ARG_UNIT], ["or Target AP: ", ARG_INT]]],
	["unit_has_armor", "Check if unit has armor.", [["Unit: ", ARG_UNIT]]],
	["unit_has_higher_armor", "Check if unit has armor higher than value.", [["Source unit: ", ARG_UNIT], ["Target unit: ", ARG_UNIT], ["or Target Armor: ", ARG_INT]]],
	["unit_has_lower_armor", "Check if unit has armor lower than value.", [["Source unit: ", ARG_UNIT], ["Target unit: ", ARG_UNIT], ["or Target Armor: ", ARG_INT]]],
	["unit_has_same_armor", "Check if unit has a status.", [["Source unit: ", ARG_UNIT], ["Target unit: ", ARG_UNIT], ["or Target Armor: ", ARG_INT]]],
	["unit_has_higher_magic_armor", "Check if unit has a status.", [["Source unit: ", ARG_UNIT], ["Target unit: ", ARG_UNIT], ["or Target Magic Armor: ", ARG_INT]]],
	["unit_has_lower_magic_armor", "Check if unit has a status.", [["Source unit: ", ARG_UNIT], ["Target unit: ", ARG_UNIT], ["or Target Magic Armor: ", ARG_INT]]],
	["unit_has_same_magic_armor", "Check if unit has a status.", [["Source unit: ", ARG_UNIT], ["Target unit: ", ARG_UNIT], ["or Target Magic Armor: ", ARG_INT]]],
	["unit_has_lower_move", "Check if unit has a status.", [["Source unit: ", ARG_UNIT], ["Target unit: ", ARG_UNIT], ["or Target Move: ", ARG_INT]]],
	["unit_has_higher_move", "Check if unit has a status.", [["Source unit: ", ARG_UNIT], ["Target unit: ", ARG_UNIT], ["or Target Move: ", ARG_INT]]],
	["unit_has_same_move", "Check if unit has a status.", [["Source unit: ", ARG_UNIT], ["Target unit: ", ARG_UNIT], ["or Target Move: ", ARG_INT]]],
	["unit_has_lower_jump", "Check if unit has a status.", [["Source unit: ", ARG_UNIT], ["Target unit: ", ARG_UNIT], ["or Target Jump: ", ARG_INT]]],
	["unit_has_higher_jump", "Check if unit has a status.", [["Source unit: ", ARG_UNIT], ["Target unit: ", ARG_UNIT], ["or Target Jump: ", ARG_INT]]],
	["unit_has_same_jump", "Check if unit has a status.", [["Source unit: ", ARG_UNIT], ["Target unit: ", ARG_UNIT], ["or Target Jump: ", ARG_INT]]],
	["unit_has_lower_elevation", "Check if unit has a status.", [["Source unit: ", ARG_UNIT], ["Target unit: ", ARG_UNIT], ["or Target Elevation: ", ARG_INT]]],
	["unit_has_higher_elevation", "Check if unit has a status.", [["Source unit: ", ARG_UNIT], ["Target unit: ", ARG_UNIT], ["or Target Elevation: ", ARG_INT]]],
	["unit_has_same_elevation", "Check if unit has a status.", [["Source unit: ", ARG_UNIT], ["Target unit: ", ARG_UNIT], ["or Target Elevation: ", ARG_INT]]],
	["unit_has_lower_level", "Check if unit has a status.", [["Source unit: ", ARG_UNIT], ["Target unit: ", ARG_UNIT], ["or Target Level: ", ARG_INT]]],
	["unit_has_higher_level", "Check if unit has a status.", [["Source unit: ", ARG_UNIT], ["Target unit: ", ARG_UNIT], ["or Target Level: ", ARG_INT]]],
	["unit_has_same_level", "Check if unit has a status.", [["Source unit: ", ARG_UNIT], ["Target unit: ", ARG_UNIT], ["or Target Level: ", ARG_INT]]],
]

var valid_effects:Array = [
	["AddStatus", "Add status to unit with duration.", [["Source unit: ", ARG_UNIT], ["Status: ", ARG_STATUS], ["Number of turns: ", ARG_INT], ["Unlimited?", ARG_BOOL], ["Accumulates?", ARG_BOOL]]],
	["RemoveStatus", "Remove status from unit.", [["Source unit: ", ARG_UNIT], ["Status: ", ARG_STATUS]]],
	["RemoveAllStatus", "Remove all status effects from unit.", [["Source unit: ", ARG_UNIT]]],
	["ChangeStatusDuration", "Change duration of a unit's status.", [["Source unit: ", ARG_UNIT], ["Status: ", ARG_STATUS], ["Number of turns: ", ARG_INT], ["Unlimited?", ARG_BOOL], ["Accumulates?", ARG_BOOL]]],
	["Move", "Move target x spaces in y direction.", [["Source unit: ", ARG_UNIT], ["Spaces: ", ARG_INT], ["Direction: ", ARG_INT]]],
	["MoveRandom", "Move target x spaces in a random direction.", [["Source unit: ", ARG_UNIT], ["Spaces: ", ARG_INT]]],
	["PushFromUnit", "Move source unit x spaces away from target unit.", [["Source unit: ", ARG_UNIT], ["Target unit: ", ARG_UNIT], ["Spaces: ", ARG_INT]]],
	["PullFromUnit", "Move source unit x spaces towards target unit.", [["Source unit: ", ARG_UNIT], ["Target unit: ", ARG_UNIT], ["Spaces: ", ARG_INT]]],
	["PushFromCell", "Move source unit x spaces away from target cell.", [["Source unit: ", ARG_UNIT], ["Target cell: ", ARG_CELL], ["Spaces: ", ARG_INT]]],
	["PullToCell", "Move source unit x spaces towards target cell.", [["Source unit: ", ARG_UNIT], ["Target cell: ", ARG_CELL], ["Spaces: ", ARG_INT]]],
	["MoveTo", "Move source unit directly to cell.", [["Source unit: ", ARG_UNIT], ["Target cell: ", ARG_CELL]]],
	["Unblockable", "Make card unblockable.", [["Unblockable: ", ARG_BOOL]]],
	["SetCardCost", "Set card cost to x.", [["Cost: ", ARG_INT], ["OR Select Source unit: ", ARG_UNIT], ["AND Select stat: ", ARG_STAT]]],
	["ChangeCost", "Add/Remove x AP to card.", [["Cost: ", ARG_INT], ["OR Select Source unit: ", ARG_UNIT], ["AND Select stat: ", ARG_STAT]]],
	["SetAP", "Set x AP for unit.", [["Unit: ", ARG_UNIT], ["AP: ", ARG_INT], ["OR Select Source unit: ", ARG_UNIT], ["AND Select stat: ", ARG_STAT]]],
	["ChangeAP", "Add/Remove x AP to unit.", [["Unit: ", ARG_UNIT], ["AP: ", ARG_INT], ["OR Select Source unit: ", ARG_UNIT], ["AND Select stat: ", ARG_STAT]]],
	["SetHP", "Set unit HP to x.", [["Unit: ", ARG_UNIT], ["HP: ", ARG_INT], ["OR Select Source unit: ", ARG_UNIT], ["AND Select stat: ", ARG_STAT]]],
	["ChangeHP", "Add/Remove x HP to unit.", [["Unit: ", ARG_UNIT], ["HP: ", ARG_INT], ["OR Select Source unit: ", ARG_UNIT], ["AND Select stat: ", ARG_STAT]]],
	["DivideHP", "Divide HP from unit by 2.", [["Unit: ", ARG_UNIT], ["OR Select Source unit: ", ARG_UNIT], ["AND Select stat: ", ARG_STAT]]],
	["ReviveUnit", "Revive unit to 1 HP.", [["Unit: ", ARG_UNIT], ["OR Select Source unit: ", ARG_UNIT], ["AND Select stat: ", ARG_STAT]]],
	["SetRange", "Set card Range to x.", [["Range: ", ARG_INT], ["OR Select Source unit: ", ARG_UNIT], ["AND Select stat: ", ARG_STAT]]],
	["ChangeRange", "Add/Remove x Range to card.", [["Range: ", ARG_INT], ["OR Select Source unit: ", ARG_UNIT], ["AND Select stat: ", ARG_STAT]]],
	["SetVerticalRange", "Set card Vertical Range to x.", [["Range: ", ARG_INT], ["OR Select Source unit: ", ARG_UNIT], ["AND Select stat: ", ARG_STAT]]],
	["ChangeVerticalRange", "Add/Remove x Vertical Range to card.", [["Range: ", ARG_INT], ["OR Select Source unit: ", ARG_UNIT], ["AND Select stat: ", ARG_STAT]]],
	["SetMove", "Set unit Move to x.", [["Unit: ", ARG_UNIT], ["Move: ", ARG_INT], ["OR Select Source unit: ", ARG_UNIT], ["AND Select stat: ", ARG_STAT]]],
	["ChangeMove", "Add/Remove x Move to unit.", [["Unit: ", ARG_UNIT], ["Move: ", ARG_INT], ["OR Select Source unit: ", ARG_UNIT], ["AND Select stat: ", ARG_STAT]]],
	["SetJump", "Set unit Jump to x.", [["Unit: ", ARG_UNIT], ["Jump: ", ARG_INT], ["OR Select Source unit: ", ARG_UNIT], ["AND Select stat: ", ARG_STAT]]],
	["ChangeJump", "Add/Remove x Jump to unit.", [["Unit: ", ARG_UNIT], ["Jump: ", ARG_INT], ["OR Select Source unit: ", ARG_UNIT], ["AND Select stat: ", ARG_STAT]]],
	["SetLevel", "Set unit Level to x.", [["Unit: ", ARG_UNIT], ["Level: ", ARG_INT], ["OR Select Source unit: ", ARG_UNIT], ["AND Select stat: ", ARG_STAT]]],
	["ChangeLevel", "Add/Remove x Level to unit.", [["Unit: ", ARG_UNIT], ["Level: ", ARG_INT], ["OR Select Source unit: ", ARG_UNIT], ["AND Select stat: ", ARG_STAT]]],
	["PlayerDrawCards", "Target draw x cards.", [["Owner of Unit: ", ARG_UNIT], ["Number of cards: ", ARG_INT], ["OR Select Source unit: ", ARG_UNIT], ["AND Select stat: ", ARG_STAT]]],
	["PlayerDiscardCards", "Target discard x cards.", [["Owner of Unit: ", ARG_UNIT], ["Number of cards: ", ARG_INT], ["OR Select Source unit: ", ARG_UNIT], ["AND Select stat: ", ARG_STAT]]],
	["CanAttack", "Set if card can attack.", [["Can attack: ", ARG_BOOL]]],
	["CanDefend", "Set if card can defend.", [["Can defend: ", ARG_BOOL]]],
	["ChangeCardType", "Change card type.", [["Type (0 = SKILL, 1 = PHYSICALATTACK, 2 = MAGICATTACK, 3 = MAGICSPELL, 4 = ITEM): ", ARG_INT]]],
	["ChangeCardClass", "Change card class.", [["Class (0 = Warrior, 1 = Ranger, 2 = Mage, 3 = WARRIORRANGER, 4 = RANGERMAGE, 5 = MAGEWARRIOR, 6 = ALL): ): ", ARG_INT]]],
	["ChangeUnitClass", "Change unit class.", [["Unit: ", ARG_UNIT], ["Class (0 = Warrior, 1 = Ranger, 2 = Mage, 3 = WARRIORRANGER, 4 = RANGERMAGE, 5 = MAGEWARRIOR, 6 = ALL): ): ", ARG_INT]]],
	["AddElementChoice", "Let player choose element of card.", [["Add Element Choice: ", ARG_BOOL]]],
	["AddElement", "Add element x to this card.", [["0 = NONE, 1 = FIRE, 2 = ICE, 3 = ELECTRIC: ", ARG_INT]]],
	["RemoveElement", "Remove element x from this card.", [["0 = NONE, 1 = FIRE, 2 = ICE, 3 = ELECTRIC: ", ARG_INT]]],
	["ShowNextHand", "Show next hand from unit.", [["Unit: ", ARG_UNIT]]],
	["AddConditionalEffect", "Add a condition and effect to a unit.", [["Unit: ", ARG_UNIT], ["Condition: ", ARG_CONDITION], ["Effect: ", ARG_EFFECT]]],
	["RemoveUnitCondition", "Remove a condition and it's effect from a unit.", [["Unit: ", ARG_UNIT], ["Condition: ", ARG_CONDITION]]],
	["RemoveCardCondition", "Remove a condition and it's effect from this card.", [["Condition: ", ARG_CONDITION]]]
]

var valid_resolves:Array = [
	["Instant"],
	["CardCasted", ARG_CARD],
	["ConditionSuccess"],
	["ConditionFailed"],
	["NumTurnsEnded", ARG_INT],
	["NumSelfTurnsEnded", ARG_INT],
	["NumFriendlyTurnsEnded", ARG_INT],
	["NumEnemyTurnsEnded", ARG_INT],
	["NumTurnsStarted", ARG_INT],
	["NumSelfTurnsStarted", ARG_INT],
	["NumFriendlyTurnsStarted", ARG_INT],
	["NumEnemyTurnsStarted", ARG_INT]
]


var data = {
	"valid_statuses": valid_statuses,
	"valid_conditions": valid_conditions,
	"valid_effects": valid_effects,
	"valid_resolves": valid_resolves
}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#loadCardFile()
	#save_dictionary(data)
	#load_dictionary()

func load_dictionary() -> void:
	var file:File = File.new()
	if file.file_exists(path):
		var error = file.open(path,File.READ)
		if error == OK:
			var text = file.get_as_text()
			file.close()
			data = parse_json(text)

func save_dictionary(save_data) -> void:
	var file:File = File.new()
	if file.file_exists(path):
		var error = file.open(path,File.WRITE)
		if error == OK:
			file.store_line(to_json(save_data))
			file.close()

static func toRoman(num:int) -> String: #converts int to roman numeral up to 10
	match num:
		0:
			return ""
		1:
			return ""
		2:
			return "II"
		3:
			return "III"
		4:
			return "IV"
		5:
			return "V"
		6:
			return "VI"
		7:
			return "VII"
		8:
			return "VIII"
		9:
			return "IX"
		10:
			return "X"
	return ""
