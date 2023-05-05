extends KinematicBody

class_name HexUnit

func get_class() -> String: return "HexUnit"

var NinePatchPrefab = preload("res://objects/UI/NinePatchRect.tscn")

# warning-ignore:unused_signal
signal selected(unit)
# warning-ignore:unused_signal
signal deselected(unit)
# warning-ignore:unused_signal
signal select_unit()
# warning-ignore:unused_signal
signal select_tile()
# warning-ignore:unused_signal
signal selected_target()
# warning-ignore:unused_signal
signal reflex_targeted(card)
# warning-ignore:unused_signal
signal targeted(card, card_caster) #
# warning-ignore:unused_signal
signal crit_attacked(card)
# warning-ignore:unused_signal
signal crit_damaged(card, amount)
# warning-ignore:unused_signal
signal attacked(card)
signal damaged(card, amount) #
# warning-ignore:unused_signal
signal receive_heal(card,amount) # receive heal
signal give_heal(card,amount) # give heal
# warning-ignore:unused_signal
signal buffed(card, stat, amount)
# warning-ignore:unused_signal
signal debuffed(card, stat, amount)
signal reacted(card)
signal reflex_reacted(card)
signal moved(from, to)
signal pushed(from, to)
signal turned()
signal reaction_complete()
# warning-ignore:unused_signal
signal blocked(card,amount) #
# warning-ignore:unused_signal
signal deflected(card,amount) #
# warning-ignore:unused_signal
signal evaded(card) #
# warning-ignore:unused_signal
signal missed(card) #
# warning-ignore:unused_signal
signal draw(card) #
# warning-ignore:unused_signal
signal discard(card) #
# warning-ignore:unused_signal
signal recover_discard() #
# warning-ignore:unused_signal
signal consume(card) #
# warning-ignore:unused_signal
signal eliminate(card) #
# warning-ignore:unused_signal
signal turn_started(round_count, turn_count)
signal animate_done()
signal animate_react_done()

onready var sides = $"Sides"
onready var directions = $Directions
var deck:Array = [] # Array containing card names only for data storage
var active_deck:Array = [] # Array of card dictionaries for in-game use
var hand_deck:Array = [] # Array of card dictionaries for in-game use. Each hand is made at the beginning of each round.
var discard_deck:Array = [] # Array of card dictionaries for in-game use. 
var consumed_deck:Array = [] # Array of card dictionaries for in-game use. 
var unit_deck_size:int
var unit_hand_size:int
var unit_discard_size:int
var unit_consumed_size:int
var player_deck_size:int

var grid:Spatial
# The unique identifier in the unit_list
var id:String
var player_owned:bool
var unit_owner
var is_ai_controlled:bool
var ai_type:int = 0
var battle_controller
#var current_card
#var current_card_delay:int = 0
var current_react_card
#var card_follow_unit:HexUnit
var cards_played:Array
var best_actions:Array
var queue_number:int
var initiative_counter:int

var selected:bool = false
var isSelectable:bool = true
var isActive:bool = false
var move_speed:float = .7 # How many seconds to move one cell
var path:Array
var validMoveCells:Array
var validRangeCells:Array
enum reaction_animations {NONE, HIT, HEAL, MISS, BLOCK}
var reaction_animation:int
var evasion_degradation:float = 0
var evasion_degradation_amount:float = 5.0

var position:Vector3
var axialCoordinates:Vector2
var cubeCoordinates:Vector3
var oddRCoordinates:Vector2
var currentCell:Spatial
var elevation:int
var facing:String = "E"
var old_facing:String
var old_rotation:float

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
var deflect:int
var strength:int
var willpower:int
var has_combo:bool
var traits:Array
var statuses:Array
var proficiencies:Array
var reaction:Dictionary
#var untargetable:bool = false # used by behavior_tree/leaves/bt_attack.gd to make sure statuses are not added after failing an evasion check

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# warning-ignore:unused_argument
func _physics_process(delta):
	pass

func _unhandled_input(_event):
	pass

func getDeckSpeed() -> float:
	var deck_AP:float = 0 #Total of all cards AP in unit's deck
	var deck_speed:float = 0
	if deck.size() > 0:
		for i in deck:
			var action_costs:Array
			if !CardLoader.loadSingleCardFile(i,true).empty():
				action_costs = CardLoader.loadSingleCardFile(i,true).get("action_costs")
			else:
				action_costs = [0,0,0]
			if proficiencies.size() > 0:
				for j in proficiencies:
					if j[0] == i:
						var proficiency_value:float = j[1]
						deck_AP += max(action_costs[proficiency_value-1],1)
			else:
				deck_AP += max(action_costs[0],1)
		if deck_AP == 0:
			deck_AP = 1
		deck_speed = (max_action_points / (deck_AP / deck.size())) / 2
	return deck_speed

func getUnitSpeed(speed = base_speed) -> float:
	return speed + getDeckSpeed()

func searchCellDistance(cells:Array):
	for i in cells.size():
		cells[i].distance = currentCell.distanceTo(cells[i])

func checkValidMoveCells(fromCell, horizontalCheck, verticalCheck):
#	clearValidMoveCells()
	fromCell.walkDistance = 0
	var frontier:Array = [fromCell]
	while frontier.size() > 0:
		frontierSearchNeighbors(frontier, horizontalCheck, verticalCheck, true)
	# Remove the tile that the hero is standing on
	#var resize:int = 0
	for i in range(validMoveCells.size() - 1, -1, -1):
		if validMoveCells[i].unit != null or validMoveCells[i].hasObstacle:
			validMoveCells[i].unvalidify()
			validMoveCells.remove(i)

func checkValidRangeCells(fromCell, card):
	clearValidRangeCells()
	fromCell.walkDistance = 0
	var frontier:Array = [fromCell]
	var card_type = card.card_type
	var card_min_range:int = card.card_min_range[card.card_level]
	var card_max_range:int = card.card_max_range[card.card_level]
	var card_up_vertical_range:int = card.card_up_vertical_range[card.card_level]
	var card_down_vertical_range:int = card.card_down_vertical_range[card.card_level]
	var card_hexagonal_targeting:bool = card.hexagonal_targeting[card.card_level]
	while frontier.size() > 0:
		frontierSearchNeighbors(frontier, card_max_range, card_up_vertical_range, false)
	for i in range(validRangeCells.size() - 1, -1, -1):
		if validRangeCells[i].distance < card_min_range:
			validRangeCells[i].unvalidifyRange()
			validRangeCells.remove(i)
			continue
		if validRangeCells[i].distance > card_max_range and !(card_type == 1 and card_max_range > 1):
			validRangeCells[i].unvalidifyRange()
			validRangeCells.remove(i)
			continue
		if validRangeCells[i].cell_height - currentCell.cell_height > card_up_vertical_range or currentCell.cell_height - validRangeCells[i].cell_height > card_down_vertical_range:
			validRangeCells[i].unvalidifyRange()
			validRangeCells.remove(i)
			continue
		if card_hexagonal_targeting and (validRangeCells[i].cubeCoordinates.x != fromCell.cubeCoordinates.x and validRangeCells[i].cubeCoordinates.y != fromCell.cubeCoordinates.y and validRangeCells[i].cubeCoordinates.z != fromCell.cubeCoordinates.z):
			validRangeCells[i].unvalidifyRange()
			validRangeCells.remove(i)
			continue


func frontierSearchNeighbors(frontier, horizontalCheck, verticalCheck, isMove):
	var sourceCell = currentCell
	var current_cell = frontier.front() # currentCell is first cell in frontier
	frontier.pop_front() # remove first cell from frontier
	for i in current_cell.neighbors.size():
		var frontier_cell = current_cell.neighbors[i]
		var ref_cell = weakref(current_cell.neighbors[i])
		if ref_cell.get_ref() != null:
			if isMove: #this is a move range check
				if validMoveCells.find(ref_cell.get_ref()) == -1: #if it's not valid yet
					if current_cell.walkDistance < horizontalCheck: #if it's within walking range
						if abs(ref_cell.get_ref().cell_height - current_cell.cell_height) <= verticalCheck: #if it's within jumping range
							if ref_cell.get_ref().unit == null: #if the cell is not occupied by a unit
								ref_cell.get_ref().walkDistance = current_cell.walkDistance + 1
								ref_cell.get_ref().pathFrom = current_cell
								validMoveCells.append(ref_cell.get_ref())
								frontier.push_back(ref_cell.get_ref()) #add valid neighbor cells to frontier
							elif ref_cell.get_ref().unit.team == team: #if occupied by unit, if the unit is of the same team
								ref_cell.get_ref().walkDistance = current_cell.walkDistance + 1
								ref_cell.get_ref().pathFrom = current_cell
								validMoveCells.append(ref_cell.get_ref())
								frontier.push_back(ref_cell.get_ref()) #add valid neighbor cells to frontier
			else: #this is an attack range check
				if validRangeCells.find(frontier_cell) == -1: #if it's not valid yet
					if current_cell.walkDistance < horizontalCheck: #if it's within walking range
						if current_cell.walkDistance == horizontalCheck - 1 and (!frontier_cell.extended and !current_cell.extended):
							frontier_cell.walkDistance = current_cell.walkDistance + int(frontier_cell.cell_height >= sourceCell.cell_height - 2)
							frontier_cell.extended = true
							#currentCell.extended = true
						else:
							frontier_cell.walkDistance = current_cell.walkDistance + 1
	#					if !frontier_cell.extended or (frontier_cell.extended and abs(frontier_cell.cell_height - sourceCell.cell_height) <= verticalCheck):
						frontier_cell.pathFrom = current_cell
						validRangeCells.append(frontier_cell)
						frontier.push_back(frontier_cell) #add valid neighbor cells to frontier

func frontierSearchPath(fromCell, toCell):
	path.clear()
# warning-ignore:shadowed_variable
	var currentCell = toCell
	while currentCell != fromCell:
		path.push_front(currentCell)
		currentCell = currentCell.pathFrom
	path.push_front(fromCell)

func getPath():
	var pathLocations:Array = []
	for i in path.size():
		var location:Vector3 = path[i].translation
		location.y = (path[i].cell_height * path[i].scale.y) + 1
		pathLocations.append(location)
	return pathLocations

func highlightMove() -> void:
	clearValidMoveCells()
	searchCellDistance(grid.cells)
	checkValidMoveCells(currentCell, current_movement_points, current_jump_points)
	for i in validMoveCells.size():
		validMoveCells[i].validify()

func moveTo(cell) -> void:
	isSelectable = false
	hideDirections()
	clearValidMoveCells()
	var from = currentCell
	var to = cell
	frontierSearchPath(currentCell,cell)
	var pathLocations = getPath()
	$UnitMovement.move(getPath())
	get_node("Character_Mesh").get_node("AnimationPlayer").play("Walk")
	yield($UnitMovement,"completed")
	get_node("Character_Mesh").get_node("AnimationPlayer").play("Idle")
	currentCell.unit = null
	cell.unit = self
	currentCell = cell
	position = pathLocations.back()
	elevation = currentCell.cell_height
	axialCoordinates = currentCell.axialCoordinates
	isSelectable = true
	emit_signal("moved",from,to)

func editModeMoveTo(cell):
	isSelectable = false
	hideDirections()
	clearValidMoveCells()
	frontierSearchPath(currentCell,cell)
	var pathLocations = getPath()
	$UnitMovement.editMove(getPath())
	get_node("Character_Mesh").get_node("AnimationPlayer").play("Walk")
	yield($UnitMovement,"completed")
	get_node("Character_Mesh").get_node("AnimationPlayer").play("Idle")
	currentCell.unit = null
	cell.unit = self
	currentCell = cell
	position = pathLocations.back()
	elevation = currentCell.cell_height
	axialCoordinates = currentCell.axialCoordinates
	isSelectable = true
	showDirections()
	select()

func pushTo(cell) -> void:
	if cell != null:
		isSelectable = false
		var from = currentCell
		var to = cell
		var distance:int = from.distanceTo(to)
		checkValidMoveCells(currentCell, distance, 20)
	#	hideDirections()
	#	clearValidMoveCells()
		frontierSearchPath(currentCell,cell)
		var pathLocations = getPath()
		currentCell.unit = null
		cell.unit = self
		currentCell = cell
		position = pathLocations.back()
		elevation = currentCell.cell_height
		axialCoordinates = currentCell.axialCoordinates
		$UnitMovement.push(getPath())
		get_node("Character_Mesh").get_node("AnimationPlayer").play("Hurt")
		yield(get_node("Character_Mesh").get_node("AnimationPlayer"),"animation_finished")
		get_node("Character_Mesh").get_node("AnimationPlayer").play("Idle")
		
		#isSelectable = true
		emit_signal("pushed",from,to)

func turnTo(cell:HexCell) -> void:
	var space_state = grid.get_world().get_direct_space_state()
	var from = position + Vector3(0,1,0)
	var to = cell.translation + Vector3(0,1,0)
	var result = space_state.intersect_ray(from, to)
	var old_rotation = rotation
	var rotation_amount:int = 0
	if result.has("collider"):
		var direction:String = result.collider.name
		if direction ==  "DirectionBackward" or direction ==  "SideBackward":
			rotation_amount = 180
		if direction ==  "DirectionForwardRight" or direction ==  "SideForwardRight":
			rotation_amount = -60
		if direction ==  "DirectionBackwardRight" or direction ==  "SideBackwardRight":
			rotation_amount = -120
		if direction ==  "DirectionForward" or direction ==  "SideForward":
			rotation_amount = 0
		if direction ==  "DirectionBackwardLeft" or direction ==  "SideBackwardLeft":
			rotation_amount = 120
		if direction ==  "DirectionForwardLeft" or direction ==  "SideForwardLeft":
			rotation_amount = 60
		var new_rotation_y = deg2rad(rotation_amount)
		var new_rotation:Vector3 = Vector3(0,old_rotation.y + new_rotation_y,0)
		var tween = get_node("Tween")
		tween.interpolate_property(self, "rotation",
				old_rotation, new_rotation, .15,
				Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
		yield(tween,"tween_completed")
		if rotation_degrees.y < -180:
			rotation.y += 2*PI
		if rotation_degrees.y > 180:
			rotation.y -= 2*PI
		if rotation_degrees.y > -4 and rotation_degrees.y < 4:
			rotation_degrees.y = 0
			facing = "E"
		if rotation_degrees.y > 56 and rotation_degrees.y < 64:
			rotation_degrees.y = 60
			facing = "NE"
		if rotation_degrees.y > 116 and rotation_degrees.y < 124:
			rotation_degrees.y = 120
			facing = "NW"
		if rotation_degrees.y < -176 or rotation_degrees.y > 176:
			rotation_degrees.y = 180
			facing = "W"
		if rotation_degrees.y > -124 and rotation_degrees.y < -116:
			rotation_degrees.y = -120
			facing = "SW"
		if rotation_degrees.y > -64 and rotation_degrees.y < -56:
			rotation_degrees.y = -60
			facing = "SE"
	self.old_rotation = old_rotation.y
	emit_signal("turned")

func needToTurn(cell:HexCell) -> bool:
	var space_state = grid.get_world().get_direct_space_state()
	var from = position + Vector3(0,1,0)
	var to = cell.translation + Vector3(0,1,0)
	var result = space_state.intersect_ray(from, to)
	var old_rotation = rotation
	var rotation_amount:int = 0
	if result.has("collider"):
		var direction:String = result.collider.name
		if direction ==  "DirectionBackward" or direction ==  "SideBackward":
			rotation_amount = 180
		if direction ==  "DirectionForwardRight" or direction ==  "SideForwardRight":
			rotation_amount = -60
		if direction ==  "DirectionBackwardRight" or direction ==  "SideBackwardRight":
			rotation_amount = -120
		if direction ==  "DirectionForward" or direction ==  "SideForward":
			rotation_amount = 0
		if direction ==  "DirectionBackwardLeft" or direction ==  "SideBackwardLeft":
			rotation_amount = 120
		if direction ==  "DirectionForwardLeft" or direction ==  "SideForwardLeft":
			rotation_amount = 60
	return rotation_amount != 0

func clearValidMoveCells():
	if !validMoveCells.empty():
		for i in validMoveCells.size():
			validMoveCells[i].unvalidify()
		validMoveCells.clear()

func clearValidRangeCells():
	if !validRangeCells.empty():
		for i in validRangeCells.size():
			validRangeCells[i].unvalidifyRange()
	#		validRangeCells[i].extended = false
		validRangeCells.clear()

func highlightRange(card_info) -> void:
	searchCellDistance(grid.cells)
	clearValidRangeCells()
	checkValidRangeCells(currentCell, card_info)
	for i in validRangeCells.size():
		validRangeCells[i].validifyRange()

func showDirections() -> void:
	for i in currentCell.neighbors.size():
		if currentCell.neighbors[i] != null:
			if currentCell.neighbors[i].cell_height > currentCell.cell_height + 3:
				currentCell.neighbors[i].setTransparency(true)
			if currentCell.neighbors[i].unit != null:
				currentCell.neighbors[i].unit.setTransparency(true)
	for direction in $Directions.get_children():
		direction.get_child(0).visible = true
		direction.get_child(1).disabled = false

func hideDirections() -> void:
	for i in currentCell.neighbors.size():
		if currentCell.neighbors[i] != null:
			if currentCell.neighbors[i].cell_height > currentCell.cell_height + 3:
				currentCell.neighbors[i].setTransparency(false)
			if currentCell.neighbors[i].unit != null:
				currentCell.neighbors[i].unit.setTransparency(false)
	for direction in $Directions.get_children():
		direction.get_child(0).visible = false
		direction.get_child(1).disabled = true

func turnDirection(direction:String) -> void:
	if direction == "DirectionForwardRight":
		rotate_y(-deg2rad(60))
	if direction == "DirectionBackwardRight":
		rotate_y(-deg2rad(120))
	if direction == "DirectionBackward":
		rotate_y(deg2rad(180))
	if direction == "DirectionBackwardLeft":
		rotate_y(deg2rad(120))
	if direction == "DirectionForwardLeft":
		rotate_y(deg2rad(60))
	if rotation_degrees.y > -4 and rotation_degrees.y < 4:
		set_rotation_degrees(Vector3(0,0,0))
		facing = "E"
	if rotation_degrees.y > 56 and rotation_degrees.y < 64:
		set_rotation_degrees(Vector3(0,60,0))
		facing = "NE"
	if rotation_degrees.y > 116 and rotation_degrees.y < 124:
		set_rotation_degrees(Vector3(0,120,0))
		facing = "NW"
	if rotation_degrees.y < -176 or rotation_degrees.y > 176:
		set_rotation_degrees(Vector3(0,180,0))
		facing = "W"
	if rotation_degrees.y > -124 and rotation_degrees.y < -116:
		set_rotation_degrees(Vector3(0,-120,0))
		facing = "SW"
	if rotation_degrees.y > -64 and rotation_degrees.y < -56:
		set_rotation_degrees(Vector3(0,-60,0))
		facing = "SE"
	hideDirections()
	$UnitMovement.old_rotation = rotation
	if !grid.editMode:
		battle_controller.emit_signal("unit_turned",self,unit_owner,old_facing)

func loadFacing(direction:String) -> void:
	if direction == "E":
		rotation_degrees.y = 0
	if direction == "NE":
		rotation_degrees.y = 60
	if direction == "NW":
		rotation_degrees.y = 120
	if direction == "W":
		rotation_degrees.y = 180
	if direction == "SW":
		rotation_degrees.y = -120
	if direction == "SE":
		rotation_degrees.y = -60

func activateSides() -> void:
	for sides in $Sides.get_children():
		sides.get_child(0).disabled = false

func deactivateSides() -> void:
	for sides in $Sides.get_children():
		sides.get_child(0).disabled = true

func activateCoreCollision() -> void:
	$CollisionShape.disabled = false

func deactivateCoreCollision() -> void:
	$CollisionShape.disabled = true

func toggleSelected():
	selected = !selected
	if selected:
		#highlightMove(grid.cells)
		if unit_owner != null:
			battle_controller.emit_signal("unit_selected",self,unit_owner)
	else:
		#clearValidMoveCells()
		if unit_owner != null:
			battle_controller.emit_signal("unit_deselected",self,unit_owner)

func select():
	selected = true
	if !grid.editMode:
		battle_controller.emit_signal("unit_selected",self,unit_owner)
	else:
		highlightMove()

func deselect():
	selected = false
	hideDirections()
	if !grid.editMode:
		battle_controller.emit_signal("unit_deselected",self,unit_owner)
	else:
		clearValidMoveCells()

func setTransparency(transparent:bool) -> void:
	get_node("CollisionShape").disabled = transparent
	for side in sides.get_children():
		side.get_child(0).disabled = transparent

func save() -> Dictionary:
	var save_dict = {
#		"self" : self,
#		"filename" : get_filename(),
#		"parent" : get_parent(),
#		"axial" : axialCoordinates,
#		"position" : position,
#		"facing" : facing,
		"unit_name" : unit_name,
		"team" : team,
		"unit_class" : unit_class,
		"unit_class_name" : unit_class_name,
		"bio": bio,
#		"currentCell" : currentCell.save(),
#		"cubeCoordinates" : cubeCoordinates,
#		"elevation" : elevation,
		"current_health" : current_health,
		"max_health" : max_health,
		"current_action_points" : current_action_points,
		"max_action_points" : max_action_points,
		"current_movement_points" : current_movement_points,
		"base_action_points_regen" : base_action_points_regen,
		"current_action_points_regen" : current_action_points_regen,
		"max_movement_points" : max_movement_points,
		"current_jump_points" : current_jump_points,
		"max_jump_points" : max_jump_points,
		"base_speed" : base_speed,
		"base_physical_accuracy" : base_physical_accuracy,
		"base_magic_accuracy" : base_magic_accuracy,
		"base_physical_evasion" : base_physical_evasion,
		"base_magic_evasion" : base_magic_evasion,
		"current_physical_accuracy" : current_physical_accuracy,
		"current_magic_accuracy" : current_magic_accuracy,
		"current_physical_evasion" : current_physical_evasion,
		"current_magic_evasion" : current_magic_evasion,
		"current_draw_points" : current_draw_points,
		"base_draw_points" : base_draw_points,
		"base_crit_damage" : base_crit_damage,
		"current_crit_damage" : current_crit_damage,
		"base_crit_chance" : base_crit_chance,
		"current_crit_chance" : current_crit_chance,
		"base_crit_evasion" : base_crit_evasion,
		"current_crit_evasion" : current_crit_evasion,
		"experience" : experience,
		"level" : level,
		"traits" : traits,
		"block" : block,
		"deflect" : deflect,
#		"statuses" : statuses.duplicate(),
		"proficiencies" : proficiencies,
		"player_owned" : player_owned,
		"is_ai_controlled" : is_ai_controlled,
		"id" : id,
		"deck" : deck,
		"current_speed" : getUnitSpeed(),
		}
	return save_dict

func basicSave():
	var save_dict = {
		"axial" : axialCoordinates,
		"position" : position,
		"facing" : facing,
		"currentCell" : currentCell.save(),
		"player_owned" : player_owned,
		"team" : team,
		"is_ai_controlled" : is_ai_controlled,
		"id" : id,
		}
	return save_dict

func loadData(data):
#	axialCoordinates = data.get("axial")
#	cubeCoordinates = HexUtils.axialToCube(axialCoordinates)
#	oddRCoordinates = HexUtils.cubeToOddR(cubeCoordinates)

#	print(data.get("bio"))
	unit_name = data.get("unit_name")
	team = data.get("team")
	unit_class = data.get("unit_class")
	unit_class_name = data.get("unit_class_name")
	var character_mesh = load("res://assets/3d/character_models/Vanguard/Vanguard.tscn")
	var character_mesh_instance:Spatial = character_mesh.instance()
	character_mesh_instance.name = "Character_Mesh"
	add_child(character_mesh_instance)
	get_node("Character_Mesh").get_node("AnimationPlayer").play("Idle")
	bio = data.get("bio")
#	currentCell = grid.findHex(axialCoordinates)
#	currentCell.unit = self
#	position = data.get("position")
#	position.y = currentCell.cell_height * currentCell.scale.y
#	translate(position)
#	facing = data.get("facing")
#	old_facing = facing
#	loadFacing(facing)
#	cubeCoordinates = data.get("cubeCoordinates")
#	elevation = currentCell.cell_height

	current_health = data.get("current_health")
	max_health = data.get("max_health")
	current_action_points = data.get("current_action_points")
	max_action_points = data.get("max_action_points")
	base_action_points_regen = data.get("base_action_points_regen")
	current_action_points_regen = data.get("current_action_points_regen")
	current_movement_points = data.get("current_movement_points")
	max_movement_points = data.get("max_movement_points")
	current_jump_points = data.get("current_jump_points")
	max_jump_points = data.get("max_jump_points")
	base_physical_accuracy = data.get("base_physical_accuracy")
	base_magic_accuracy = data.get("base_magic_accuracy")
	base_physical_evasion = data.get("base_physical_evasion")
	base_magic_evasion = data.get("base_magic_evasion")
	current_physical_accuracy = data.get("base_physical_accuracy")
	current_magic_accuracy = data.get("base_magic_accuracy")
	current_physical_evasion = data.get("current_physical_evasion")
	current_magic_evasion = data.get("current_magic_evasion")
	current_draw_points = data.get("current_draw_points")
	base_draw_points = data.get("base_draw_points")
	base_crit_damage = data.get("base_crit_damage")
	current_crit_damage = data.get("current_crit_damage")
	base_crit_chance = data.get("base_crit_chance")
	current_crit_chance = data.get("current_crit_chance")
	base_crit_evasion = data.get("base_crit_evasion")
	current_crit_evasion = data.get("current_crit_evasion")
	experience = data.get("experience")
	level = data.get("level")
	block = data.get("block")
	deflect = data.get("deflect")
	traits = data.get("traits")
	
#	statuses = data.get("statuses")

	proficiencies = data.get("proficiencies")
	player_owned = data.get("player_owned")
	is_ai_controlled = data.get("is_ai_controlled")
	id = data.get("id")
	deck = data.get("deck")
	unit_deck_size = deck.size()
	base_speed = data.get("base_speed")
	current_speed = getUnitSpeed()
	
#	var mat:SpatialMaterial = SpatialMaterial.new()
#	if unit_class == 0:
#		mat.albedo_color = Color.red
#	if unit_class == 1:
#		mat.albedo_color = Color.green
#	if unit_class == 2:
#		mat.albedo_color = Color.blue
#	$MeshInstance.mesh.surface_set_material(0,mat)
#	mat.call_deferred("queue_free")

func basicLoadData(map_player_data):
	var file:File = File.new()
	var error:int
	if map_player_data.get("player_owned") == true:
		error = file.open(PlayerVars.ALLY_UNIT_SAVE_DIR + map_player_data.id + ".dat", File.READ)
	else:
		error = file.open(PlayerVars.ENEMY_UNIT_SAVE_DIR + map_player_data.id + ".dat", File.READ)
	if !error:
		var unit_data = file.get_var()
		axialCoordinates = map_player_data.get("axial")
		cubeCoordinates = HexUtils.axialToCube(axialCoordinates)
		oddRCoordinates = HexUtils.cubeToOddR(cubeCoordinates)
		unit_name = unit_data.get("unit_name")
		team = unit_data.get("team")
		unit_class = unit_data.get("unit_class")
		unit_class_name = unit_data.get("unit_class_name")
		var character_mesh = load("res://assets/3d/character_models/Vanguard/Vanguard.tscn")
		var character_mesh_instance:Spatial = character_mesh.instance()
		character_mesh_instance.name = "Character_Mesh"
		add_child(character_mesh_instance)
		get_node("Character_Mesh").get_node("AnimationPlayer").play("Idle")
		bio = unit_data.get("bio")
		currentCell = grid.findHex(axialCoordinates)
		currentCell.unit = self
		position = map_player_data.get("position")
		position.y = currentCell.cell_height * currentCell.scale.y
		translate(position)
		facing = map_player_data.get("facing")
		old_facing = facing
		loadFacing(facing)
		elevation = currentCell.cell_height
		current_health = unit_data.get("current_health")
		max_health = unit_data.get("max_health")
		current_action_points = unit_data.get("current_action_points")
		max_action_points = unit_data.get("max_action_points")
		base_action_points_regen = unit_data.get("base_action_points_regen")
		current_action_points_regen = unit_data.get("current_action_points_regen")
		current_movement_points = unit_data.get("current_movement_points")
		max_movement_points = unit_data.get("max_movement_points")
		current_jump_points = unit_data.get("current_jump_points")
		max_jump_points = unit_data.get("max_jump_points")
		base_physical_accuracy = unit_data.get("base_physical_accuracy")
		base_magic_accuracy = unit_data.get("base_magic_accuracy")
		base_physical_evasion = unit_data.get("base_physical_evasion")
		base_magic_evasion = unit_data.get("base_magic_evasion")
		current_physical_accuracy = unit_data.get("base_physical_accuracy")
		current_magic_accuracy = unit_data.get("base_magic_accuracy")
		current_physical_evasion = unit_data.get("base_physical_evasion")
		current_magic_evasion = unit_data.get("base_magic_evasion")
		current_draw_points = unit_data.get("current_draw_points")
		base_draw_points = unit_data.get("base_draw_points")
		base_crit_damage = unit_data.get("base_crit_damage")
		current_crit_damage = unit_data.get("current_crit_damage")
		base_crit_chance = unit_data.get("base_crit_chance")
		current_crit_chance = unit_data.get("current_crit_chance")
		base_crit_evasion = unit_data.get("base_crit_evasion")
		current_crit_evasion = unit_data.get("current_crit_evasion")
		experience = unit_data.get("experience")
		level = unit_data.get("level")
		block = unit_data.get("block")
		deflect = unit_data.get("deflect")
		traits = unit_data.get("traits")
#		statuses = unit_data.get("statuses")
		proficiencies = unit_data.get("proficiencies")
		player_owned = unit_data.get("player_owned")
		is_ai_controlled = map_player_data.get("is_ai_controlled")
		id = unit_data.get("id")
		deck = unit_data.get("deck")
		unit_deck_size = deck.size()
		base_speed = unit_data.get("base_speed")
		current_speed = getUnitSpeed()
		
		var mat:SpatialMaterial = SpatialMaterial.new()
		if unit_class == 0:
			mat.albedo_color = Color.red
		if unit_class == 1:
			mat.albedo_color = Color.green
		if unit_class == 2:
			mat.albedo_color = Color.blue
		$MeshInstance.mesh.surface_set_material(0,mat)
#		mat.call_deferred("queue_free")
	file.call_deferred("queue_free")


func setTeamColor() -> void:
	var mat2:SpatialMaterial = SpatialMaterial.new()
	if team == 0:
		mat2.albedo_color = Color.blue
	if team == 1:
		mat2.albedo_color = Color.red
	$MeshInstance/Front.mesh.surface_set_material(0,mat2)
#	mat2.call_deferred("queue_free")

func hasStatus() -> int:
	return statuses.size()

func hasStatusType(status_code:int) -> int:
	if statuses.size() > 0:
		for i in statuses.size():
			if statuses[i][0] == status_code:
				return i
	return -1

func countdownStatuses() -> void:
	if hasStatus():
		for i in range(statuses.size()-1,-1,-1):
			if statuses[i][1] > 0:
				statuses[i][1] -= 1
			if statuses[i][1] <= 0:
				statuses.remove(i)

func setupTurn() -> void:
	if block / 2 < 2:
		block = 0
	else:
		block = floor(block / 2)
	if deflect / 2 < 2:
		deflect = 0
	else:
		deflect  = floor(deflect / 2)
	if strength / 2 < 2:
		strength = 0
	else:
		strength  = floor(strength / 2)
	if willpower / 2 < 2:
		willpower = 0
	else:
		willpower = floor(willpower / 2)
	has_combo = false
	current_action_points = min(current_action_points+1, max_action_points)
	current_draw_points = base_draw_points
	current_action_points_regen = base_action_points_regen
	current_speed = base_speed
	current_physical_accuracy = base_physical_accuracy
	current_magic_accuracy = base_magic_accuracy
	current_physical_evasion = base_physical_evasion
	current_magic_evasion = base_magic_evasion
	current_crit_damage = base_crit_damage
	current_crit_chance = base_crit_chance
	current_crit_evasion = base_crit_evasion
#	["StatChange", duration, str(stat) + " " + operationToString(operation) + " " + str(stat_value), "Debuff", stat, stat_value, operation]
	for i in statuses:
		if i[0] is String:
			if i[0] == "StatChange":
				match i[6]:
					0:
						set(i[4], i[5])
					1:
						set(i[4], get(i[4]) + i[5])
					2:
						set(i[4], get(i[4]) - i[5])
					3:
						set(i[4], get(i[4]) * i[5])
					4:
						if i[5] != 0:
							set(i[4], get(i[4]) / i[5])
					_:
						if str(i[4]).begins_with("base"):
							var current:String = str(i[4]).replace("base","current")
							set(current, i[4])

func endTurn() -> void:
	countdownStatuses()

#[unit,player,card_actor.export_vars(),from, to]
func _on_HexUnit_reflex_targeted(unit,player,card_info,from,to): #self,unit_owner,card,currentCell,target
	var distance_to_target = currentCell.distanceTo(card_info.card_caster.currentCell)
	var vertical_distance = card_info.card_caster.currentCell.cell_height - currentCell.cell_height
	if (distance_to_target <= reaction.card_max_range[reaction.card_level] and reaction.card_max_range[reaction.card_level] > 0) and (reaction.card_up_vertical_range[reaction.card_level] > vertical_distance and reaction.card_down_vertical_range[reaction.card_level] > -vertical_distance):
#		battle_controller.emit_signal("unit_acted",self,unit_owner, reaction, currentCell, card.card_caster)
#		yield(battle_controller,"turn_ready")
		emit_signal("reflex_reacted", card_info)
		battle_controller.stack.push_front([self,unit_owner,reaction.duplicate(true),currentCell,from,true])
		reaction.action_costs[reaction.card_level] -= 1
		discard_deck.append(reaction.duplicate(true))
		reaction.clear()
	elif reaction.card_max_range[reaction.card_level] == 0:
#		battle_controller.emit_signal("unit_acted",self,unit_owner, reaction, currentCell, currentCell)
#		yield(battle_controller,"turn_ready")
		emit_signal("reflex_reacted", card_info)
		battle_controller.stack.push_front([self,unit_owner,reaction.duplicate(true),currentCell,from,true])
		reaction.action_costs[reaction.card_level] -= 1
		discard_deck.append(reaction.duplicate(true))
		reaction.clear()
	else:
		print("too far!")
	emit_signal("reaction_complete")


func _on_HexUnit_targeted(unit,player,card_info,from,to):
	var distance_to_target = currentCell.distanceTo(card_info.card_caster.currentCell)
	var vertical_distance = card_info.card_caster.currentCell.cell_height - currentCell.cell_height
	if !reaction.empty():
		if (distance_to_target <= reaction.card_max_range[reaction.card_level] and reaction.card_max_range[reaction.card_level] > 0) and (reaction.card_up_vertical_range[reaction.card_level] > vertical_distance and reaction.card_down_vertical_range[reaction.card_level] > -vertical_distance):
			emit_signal("reacted", card_info)
			battle_controller.stack.push_back([self,unit_owner,reaction.duplicate(true),currentCell,from])
			reaction.action_costs[reaction.card_level] -= 1
			discard_deck.append(reaction.duplicate(true))
			reaction.clear()
		elif reaction.card_max_range[reaction.card_level] == 0:
			emit_signal("reacted", card_info)
			battle_controller.stack.push_back([self,unit_owner,reaction.duplicate(true),currentCell,from])
			reaction.action_costs[reaction.card_level] -= 1
			discard_deck.append(reaction.duplicate(true))
			reaction.clear()
	#	else:
	#		print("too far!")
	emit_signal("reaction_complete")

func animate(animation = [], weapon_left = "None", weapon_right = "None", projectile = "None") -> void:
	if animation[0] != 0:
		if BattleDictionary.valid_weapons[weapon_left] != "None":
			get_node("Character_Mesh").l_attachment.mesh = load("res://assets/3d/weapon_models/" + BattleDictionary.valid_weapons[weapon_left] + ".tres")
		else:
			get_node("Character_Mesh").l_attachment.mesh = null
		if BattleDictionary.valid_weapons[weapon_right] != "None":
			get_node("Character_Mesh").r_attachment.mesh = load("res://assets/3d/weapon_models/" + BattleDictionary.valid_weapons[weapon_right] + ".tres")
		else:
			get_node("Character_Mesh").r_attachment.mesh = null
		get_node("Character_Mesh").get_node("AnimationPlayer").play(BattleDictionary.valid_animations[animation[0]])
		yield(get_node("Character_Mesh").get_node("AnimationPlayer"),"animation_finished")
		if animation.size() > 1:
			if animation[1] != 0:
				get_node("Character_Mesh").get_node("AnimationPlayer").play(BattleDictionary.valid_animations[animation[1]])
				#yield(get_node("Character_Mesh").get_node("AnimationPlayer"),"animation_finished")
	get_node("Character_Mesh").l_attachment.mesh = null
	get_node("Character_Mesh").r_attachment.mesh = null
	emit_signal("animate_done")

func animate_react() -> void:
	match reaction_animation:
		reaction_animations.HIT:
			get_node("Character_Mesh").get_node("AnimationPlayer").play("Hurt")
			if current_health <= 0:
				yield(get_node("Character_Mesh").get_node("AnimationPlayer"),"animation_finished")
				die()
		reaction_animations.HEAL:
			get_node("Character_Mesh").get_node("AnimationPlayer").play("Cast5Sec")
		reaction_animations.BLOCK:
			get_node("Character_Mesh").get_node("AnimationPlayer").play("Block")
		reaction_animations.MISS:
			get_node("Character_Mesh").get_node("AnimationPlayer").play("Dodge")
	reaction_animation = 0
	battle_controller.signals_to_wait_for -= 1
	emit_signal("animate_react_done")


func die():
	get_node("Character_Mesh").get_node("AnimationPlayer").play("Die")

func clear():
#	for trait in $Traits.get_children():
#		$Traits.remove_child(trait)
	get_node("Character_Mesh").clear()
	get_node("Character_Mesh").call_deferred("queue_free")
	remove_child(get_node("Character_Mesh"))


func _on_HexUnit_evaded(card):
	evasion_degradation += evasion_degradation_amount


func _on_HexUnit_damaged(card, amount):
	evasion_degradation = 0
