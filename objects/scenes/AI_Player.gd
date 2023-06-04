extends Player

class_name AI_Player

var best_actions:Array = []
# getParent() = BattleController
#-----Extended variables-----#
#var battle_gui 
#var battle_controller
#var player_name
#var is_human:bool
#var alliance:int
#var deepDrawCount:int = 3
#var units:Array
#var current_unit_deck:Array
#var player_deck:Array
#var hand:Array
#var discard:Array
#var shuffled:bool = false
#------Extended Func---------#
#moveCards(unit:HexUnit, draw_amount:int = 1, index:int = 0, from_deck:String = "active_deck", to_deck:String = "hand_deck", fallback:bool = true)

signal ai_complete()

# Called when the node enters the scene tree for the first time.
func _ready():
	is_human = false
	alliance = 1

func aiDoBestMove(unit:HexUnit) -> void:
	var turn_target
	if unit.reaction.empty():
		for c in unit.hand_deck:
			if c.can_defend[c.card_level]:
				var actual_cost:int
				actual_cost = c.action_costs[c.card_level] - int(c.has_counter[c.card_level])
				if actual_cost <= unit.current_action_points:
					unit.reaction = c.duplicate(true)
					unit.current_action_points -= actual_cost
					unitEliminateCards(unit, 1, "hand_deck", "", c.unique_id)
					break
	#Do the best attacks available
	var leastAPCardCost = ascendingCardAPValue(unit.hand_deck)[0].action_costs[ascendingCardAPValue(unit.hand_deck)[0].card_level]
	while unit.current_action_points > leastAPCardCost and unit.hand_deck.size() > 0:
		var current_move:Array = aiBestMove(unit)
		# Returns: [card, action_value, from, to]
		if !current_move.empty() and !current_move[0].empty() and current_move[3] != null:
			var best_card = current_move[0]
			var from = current_move[2]
			var to = current_move[3]
			turn_target = to
			#If Unit has to move before doing best move
			if unit.current_movement_points >= unit.currentCell.distanceTo(from):
				if from.distanceTo(to) <= best_card.card_max_range[best_card.card_level]:
					if from != unit.currentCell:
						unit.moveTo(from)
						yield(unit,"moved")
				#Unit does acion
				get_parent().emit_signal("unit_acted",unit,self,current_move[0],current_move[2],current_move[3])
				unit.current_action_points -= best_card.action_costs[best_card.card_level]
				if best_card.is_consumable[best_card.card_level]:
					unitConsumeCards(unit,1,"hand_deck","",best_card.unique_id)
				elif best_card.self_eliminating[best_card.card_level]:
					unitEliminateCards(unit,1,"hand_deck","",best_card.unique_id)
				else:
					unitDiscardCards(unit,1,"hand_deck","",best_card.unique_id)
				yield(get_parent(),"turn_ready")
			else:
				break
		else:
			break
		if unit.hand_deck.size() > 0:
			var leastAPCard = ascendingCardAPValue(unit.hand_deck)[0]
			leastAPCardCost = leastAPCard.action_costs[leastAPCard.card_level]
	#If low health, run away
	if float(unit.current_health) / float(unit.max_health) <= .20:
		if unit.current_movement_points > 0:
			unit.searchCellDistance(get_parent().grid.cells)
			var valid_move_cells:Array = []
			unit.checkValidMoveCells(unit.currentCell, unit.current_movement_points, unit.current_jump_points)
			valid_move_cells = unit.validMoveCells
			if valid_move_cells.empty():
				valid_move_cells.append(unit.currentCell)
			var enemy_occupied_cells:Array = []
			var ally_occupied_cells:Array = []
			for cell in get_parent().grid.cells:
				if cell.unit != null and cell.unit.team != unit.team:
					enemy_occupied_cells.append(cell)
				if cell.unit != null and cell.unit.team == unit.team and cell.unit != unit:
					ally_occupied_cells.append(cell)
			var best_move_cell:Array = []
			for cells in valid_move_cells:
				var cell_value:int = 0
				for enemy_cell in enemy_occupied_cells:
					cell_value += (cells.distanceTo(enemy_cell))
				for ally_cell in ally_occupied_cells:
					cell_value -= (cells.distanceTo(ally_cell))
				best_move_cell.append([cells,cell_value])
			unit.moveTo(descendingActionValue(best_move_cell)[0][0])
			yield(unit,"moved")
#	Movement after attacking
	elif unit.current_movement_points > 0:
		unit.searchCellDistance(get_parent().grid.cells)
		var valid_move_cells:Array = []
		unit.checkValidMoveCells(unit.currentCell, unit.current_movement_points, unit.current_jump_points)
		valid_move_cells = unit.validMoveCells
		if valid_move_cells.empty():
			valid_move_cells.append(unit.currentCell)
		var enemy_occupied_cells:Array = []
		var ally_occupied_cells:Array = []
		for cell in get_parent().grid.cells:
			if cell.unit != null and cell.unit.team != unit.team:
				enemy_occupied_cells.append(cell)
			if cell.unit != null and cell.unit.team == unit.team and cell.unit != unit:
				ally_occupied_cells.append(cell)
		var best_move_cell:Array = []
		for cells in valid_move_cells:
			var cell_value:int = 0
			for enemy_cell in enemy_occupied_cells:
				cell_value += (cells.distanceTo(enemy_cell))
			for ally_cell in ally_occupied_cells:
				cell_value -= (cells.distanceTo(ally_cell))
			best_move_cell.append([cells,cell_value])
		unit.moveTo(descendingActionValue(best_move_cell)[0][0])
		yield(unit,"moved")
	
	#Turn towards nearest enemy
	unit.searchCellDistance(get_parent().grid.cells)
	var enemy_occupied_cells:Array = []
	var ally_occupied_cells:Array = []
	for cell in get_parent().grid.cells:
		if cell.unit != null and cell.unit.team != unit.team:
			enemy_occupied_cells.append(cell)
		if cell.unit != null and cell.unit.team == unit.team and cell.unit != unit:
			ally_occupied_cells.append(cell)
	var best_turn_cell:Array = []
	for cells in get_parent().grid.cells:
		var cell_value:int = 0
		for enemy_cell in enemy_occupied_cells:
			cell_value += (cells.distanceTo(enemy_cell))
		#for ally_cell in ally_occupied_cells:
		#	cell_value -= (cells.distanceTo(ally_cell))
		best_turn_cell.append([cells,cell_value])
	unit.turnTo(ascendingActionValue(best_turn_cell)[0][0])
	yield(unit,"turned")
	emit_signal("ai_complete")

func aiBestMove(unit:HexUnit) -> Array:
	var final_best_actions:Array = [] #
	var card_best_action:Array = []
	var grid = get_parent().grid
	var grid_cells = get_parent().grid.cells
	unit.searchCellDistance(grid_cells)
	var valid_move_cells:Array = []
	unit.checkValidMoveCells(unit.currentCell, unit.current_movement_points, unit.current_jump_points)
	valid_move_cells = unit.validMoveCells
	if valid_move_cells.empty():
		valid_move_cells.append(unit.currentCell)
	var enemy_occupied_cells:Array = []
	var ally_occupied_cells:Array = []
	for cell in grid_cells:
		if cell.unit != null and cell.unit.team != unit.team:
			enemy_occupied_cells.append(cell)
		if cell.unit != null and cell.unit.team == unit.team and cell.unit != unit:
			ally_occupied_cells.append(cell)
	for c in unit.hand_deck:
		var valid_reach_cells:Array = []
		var card_min_reach:int = c.card_min_range[c.card_level]
		var card_max_reach:int = c.card_max_range[c.card_level] + unit.current_movement_points
		var card_lowest_reach:int = c.card_down_vertical_range[c.card_level]
		var card_highest_reach:int = c.card_up_vertical_range[c.card_level]
		var card:Card = Card.new()
		card.load_card(c)
		if card.hasSplashRange(): #only accounts for splash 1
			for ally_cell in ally_occupied_cells:
				for neighbor in ally_cell:
				 ally_occupied_cells.append(neighbor)
			for enemy_cell in enemy_occupied_cells:
				for neighbor in enemy_cell:
				 enemy_occupied_cells.append(neighbor)
		for cell in grid_cells:
			if cell.distance <= card_max_reach and cell.distance >= card_min_reach:
				if unit.elevation - cell.cell_height < card_lowest_reach and unit.elevation - cell.cell_height < card_highest_reach:
					valid_reach_cells.append(cell)
		card.free()
		
		var best_move_cells:Array = []
		var enemy_in_range_cells:Array = [] #cells that this unit can move to that will reach and hit an enemy
		var ally_in_range_cells:Array = [] #cells that this unit can move to that will reach and hit an ALLY
		if c.card_attack[c.card_level] > 0:
			for i in valid_move_cells:
				for j in enemy_occupied_cells:
					if i.distanceTo(j) >= card_min_reach and i.distanceTo(j) <= card_max_reach:
						enemy_in_range_cells.append([i,j])
		else:
			for i in valid_move_cells:
				for j in ally_occupied_cells:
					if i.distanceTo(j) >= card_min_reach and i.distanceTo(j) <= card_max_reach:
						ally_in_range_cells.append([i,j])
		
		
		for enemy_in_range_cell in enemy_in_range_cells:
			var total_distance_score:int = 0
			var total_enemy_health_difference:int = 0
			total_distance_score += enemy_in_range_cell[0].distanceTo(enemy_in_range_cell[1]) * 2
			total_enemy_health_difference += unit.current_health - enemy_in_range_cell[1].unit.current_health
			if enemy_occupied_cells.size() != 0:
				total_distance_score /= enemy_occupied_cells.size()
				total_enemy_health_difference /= enemy_occupied_cells.size()
				var movement_value:int = enemy_in_range_cell[0].cell_height - enemy_in_range_cell[1].cell_height
				var total_score = total_distance_score + total_enemy_health_difference + movement_value
				best_move_cells.append(actionResults(c,unit,enemy_in_range_cell[0],enemy_in_range_cell[1],total_score))
				
		for ally_in_range_cell in ally_in_range_cells:
			var total_distance_score:int = 0
			total_distance_score -= ally_in_range_cell[0].distanceTo(ally_in_range_cell[1]) * 2
			if ally_occupied_cells.size() != 0:
				total_distance_score /= ally_occupied_cells.size()
				var movement_value:int = ally_in_range_cell[0].cell_height - ally_in_range_cell[1].cell_height
				var total_score = total_distance_score + movement_value
				best_move_cells.append(actionResults(c,unit,ally_in_range_cell[0],ally_in_range_cell[1],total_score))
		if best_move_cells.size() > 0:
			card_best_action = descendingActionValue(best_move_cells)[0]
			best_move_cells.clear()
			final_best_actions.append(card_best_action)
	final_best_actions = descendingActionValue(final_best_actions)
	if !final_best_actions.empty():
		return(final_best_actions[0])
	else:
		return([])

func actionResults(card_info:Dictionary, unit:HexUnit, from:HexCell, to:HexCell, added_value:int) -> Array:
	# Returns: [card_info, action_value, from, to]
	# [From, To, Attack, Attack Modifiers, List of Modifiers, Hit Rate, Crit Chance, Utility Score]
	var card:Card = Card.new()
	card.load_card(card_info)
	var card_damage_value:float = 0
	var card_utility:float = 0
	card.card_caster = unit
	card.source_cell = from
	card.target_cell = to
	if card.isValid(true) and unit.current_movement_points >= unit.currentCell.distanceTo(from) and from.distanceTo(to) >= card.card_min_range[card.card_level] and from.distanceTo(to) <= card.card_max_range[card.card_level]:
		card.execute(false)
			
		for result in card.results:
			if result[2] != null and result[0] != null and result[1] != null and result[6] != null:
				if result[2] >= 0 and (result[0].team != result[1].team):
					card_damage_value += result[2] * (1+(result[6] / 100.0))
					if result[1].current_health - (result[2] * (1+(result[6] / 100.0))) <= 0: #if this action kills a bad guy
						card_damage_value += 10
				elif result[2] >= 0 and !(result[0].team != result[1].team):
					card_damage_value -= result[2] * (1+(result[6] / 100.0))
				if result[2] < 0 and (result[0].team == result[1].team):
					card_damage_value += result[2]
					if result[1].max_health - result[1].current_health >= result[2]:
						card_utility += 5
					if result[1].max_health - result[1].current_health < result[2]:
						card_utility -= 5
					if float(result[1].current_health) / float(result[1].max_health) < .5:
						card_utility += 5
				elif result[2] < 0 and !(result[0].team == result[1].team):
					card_damage_value -= result[2]
			var delay_turns:float = round(float(card.delay[card.card_level]) * float(get_parent().turn_queue.get_child_count()) / 100.0)
			if delay_turns > result[1].queue_number and !card.is_homing[card.card_level]:
				card_utility -= 50
		if card.need_los[card.card_level]:
			card_utility -= 2
		if card.is_piercing[card.card_level]:
			if to.unit.block > 0 and card.card_type == 1:
				card_utility += 10
		if card.is_consumable[card.card_level] or card.self_eliminating[card.card_level]:
			card_utility -= 2
		if card.is_homing[card.card_level]:
			card_utility += 2
		if card.has_combo[card.card_level]:
			card_utility += 4
			if unit.has_combo:
				card_utility += 6
		card_utility += (card.card_caster.current_action_points - card.action_costs[card.card_level]) * 5 #Remainder action cost times 5 is added to utility value
		card_utility += card.utility_value
		if from.distanceTo(to) == 1: #unit doesn't have to move to use card
			added_value += 5
		var action_value:float = (added_value + round(card_damage_value) + card_utility) / max(card.action_costs[card.card_level],.5)
	#	card_best_actions.append([card.card_name, action_value, str(from.cubeCoordinates), str(to.cubeCoordinates)])
		var card_export:Dictionary = card.export_vars().duplicate(true)
		card.free()
		return([card_export, action_value, from, to])
	card.free()
	return([{},added_value,from,null])


func descendingActionValue(reachable_cells) -> Array:
	reachable_cells.sort_custom(CellActionSorter, "sort_descending")
	return reachable_cells

func ascendingActionValue(reachable_cells) -> Array:
	reachable_cells.sort_custom(CellActionSorter, "sort_ascending")
	return reachable_cells

class CellActionSorter:
	static func sort_descending(a, b):
		if a[1] > b[1]:
			return true
		return false
	static func sort_ascending(a, b):
		if a[1] < b[1]:
			return true
		return false

func lowestMovementValue(reachable_cells) -> Array:
	reachable_cells.sort_custom(CellMovementSorter, "sort_ascending")
	return reachable_cells[0]

func highestMovementValue(reachable_cells) -> Array:
	reachable_cells.sort_custom(CellMovementSorter, "sort_descending")
	return reachable_cells[0]

class CellMovementSorter:
	static func sort_descending(a, b):
		if a[1] > b[1]:
			return true
		return false
	static func sort_ascending(a, b):
		if a[1] < b[1]:
			return true
		return false

func descendingCardAPValue(cards) -> Array:
	cards.sort_custom(CardAPSorter, "sort_descending")
	return cards

func ascendingCardAPValue(cards) -> Array:
	cards.sort_custom(CardAPSorter, "sort_ascending")
	return cards

class CardAPSorter:
	static func sort_descending(a, b):
		if a.action_costs[a.card_level] > b.action_costs[b.card_level]:
			return true
		return false
	static func sort_ascending(a, b):
		if a.action_costs[a.card_level] < b.action_costs[b.card_level]:
			return true
		return false
