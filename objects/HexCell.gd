extends Spatial

class_name HexCell

func get_class() -> String: return "HexCell"

#var Topology = preload("res://objects/HexTopology.gd")
#var attack_cell = preload("res://resources/shaders/attack_cell.tres")
onready var coords = $Viewport/Label
var grid:Spatial

var save_data
var position:Vector3

var axialCoordinates:Vector2
var cubeCoordinates:Vector3
var oddRCoordinates:Vector2


var pathFrom:Spatial
var distance:int
var target_distance:int
var walkDistance:int
#var searchPhase:int
var valid:bool
var valid_range:bool
var valid_attack:bool
var extended:bool = false
var unit:KinematicBody
var hasObstacle:bool
var validRangeCells:Array
var updating_height:bool = false

onready var cell_height = get_node("CellBody").scale.y

onready var top = get_node("Top")
onready var top_mesh = get_node("Top").mesh
onready var new_mesh_top = get_node("SlopedTop")
onready var innerSides = get_node("InnerSides")
onready var sides = get_node("CellBody/Sides")
onready var downEdges = get_node("InnerSides/Down")
onready var upEdges = get_node("InnerSides/Up")
onready var originalShape = get_node("CellBody/CollisionShape")
onready var slopedShape = get_node("StaticBody2/CollisionShape")
onready var select = get_node("CellBody/Select")
onready var outline = get_node("CellBody/Outline")
onready var edge_positions = get_node("EdgePositions")

var east
var northEast
var northWest
var west
var southWest
var southEast
var neighbors:Array = [null,null,null,null,null,null]

onready var new_arr_mesh:ArrayMesh = ArrayMesh.new()
var new_shape:Shape
var sloped:bool = false
var isSlopeable:bool = true

var type:String = "grass"
var isTerrain:bool = true
signal height_updated()

func _ready():
	coords.text = str(cubeCoordinates)

func slopeEdges(mesh:Mesh,upNeighbors:Array,downNeighbors:Array):
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(mesh, 0)
	for i in downNeighbors.size():
		if downNeighbors[i] != 0:
			var vertex2 = mdt.get_vertex(downNeighbors[i]+1)
			var vertex5 = mdt.get_vertex(downNeighbors[i]+4)
			var vertex6 = mdt.get_vertex(downNeighbors[i]+5)
			vertex2.y =  -.5
			vertex5.y =  -.5
			vertex6.y =  -.5
			mdt.set_vertex(downNeighbors[i]+1, vertex2)
			mdt.set_vertex(downNeighbors[i]+4, vertex5)
			mdt.set_vertex(downNeighbors[i]+5, vertex6)
			match i:
				0:
					#print("east down")
					sides.get_node("E").visible = false
					if downNeighbors[i+1] != 30:
						downEdges.get_node("2").visible = true
					if downNeighbors[i-1] != 42:
						downEdges.get_node("4").visible = true
				1:
					#print("northeast down")
					sides.get_node("NE").visible = false
					if downNeighbors[i+1] != 24:
						downEdges.get_node("12").visible = true
					if downNeighbors[i-1] != 36:
						downEdges.get_node("2").visible = true
				2:
					#print("northwest down")
					sides.get_node("NW").visible = false
					if downNeighbors[i+1] != 18:
						downEdges.get_node("10").visible = true
					if downNeighbors[i-1] != 30:
						downEdges.get_node("12").visible = true
				3:
					#print("west down")
					sides.get_node("W").visible = false
					if downNeighbors[i+1] != 48:
						downEdges.get_node("8").visible = true
					if downNeighbors[i-1] != 24:
						downEdges.get_node("10").visible = true
				4:
					#print("southwest down")
					sides.get_node("SW").visible = false
					if downNeighbors[i+1] != 42:
						downEdges.get_node("6").visible = true
					if downNeighbors[i-1] != 18:
						downEdges.get_node("8").visible = true
				5:
					#print("southeast down")
					sides.get_node("SE").visible = false
					if downNeighbors[0] != 36:
						downEdges.get_node("4").visible = true
					if downNeighbors[i-1] != 48:
						downEdges.get_node("6").visible = true
	for i in upNeighbors.size():
		if upNeighbors[i] != 0:
			var vertex2 = mdt.get_vertex(upNeighbors[i]+1)
			var vertex5 = mdt.get_vertex(upNeighbors[i]+4)
			var vertex6 = mdt.get_vertex(upNeighbors[i]+5)
			vertex2.y =  .5
			vertex5.y =  .5
			vertex6.y =  .5
			mdt.set_vertex(upNeighbors[i]+1, vertex2)
			mdt.set_vertex(upNeighbors[i]+4, vertex5)
			mdt.set_vertex(upNeighbors[i]+5, vertex6)
			match i:
				0:
					#print("east down")
					if upNeighbors[i+1] != 48:
						upEdges.get_node("2").visible = true
					if upNeighbors[i-1] != 36:
						upEdges.get_node("4").visible = true
				1:
					#print("northeast down")
					if upNeighbors[i+1] != 18:
						upEdges.get_node("12").visible = true
					if upNeighbors[i-1] != 42:
						upEdges.get_node("2").visible = true
				2:
					#print("northwest down")
					if upNeighbors[i+1] != 24:
						upEdges.get_node("10").visible = true
					if upNeighbors[i-1] != 48:
						upEdges.get_node("12").visible = true
				3:
					#print("west down")
					if upNeighbors[i+1] != 30:
						upEdges.get_node("8").visible = true
					if upNeighbors[i-1] != 18:
						upEdges.get_node("10").visible = true
				4:
					#print("southwest down")
					if upNeighbors[i+1] != 36:
						upEdges.get_node("6").visible = true
					if upNeighbors[i-1] != 24:
						upEdges.get_node("8").visible = true
				5:
					#print("southeast down")
					if upNeighbors[0] != 42:
						upEdges.get_node("4").visible = true
					if upNeighbors[i-1] != 30:
						upEdges.get_node("6").visible = true
	mesh.surface_remove(0)
	mdt.commit_to_surface(mesh)
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.create_from(mesh, 0)
	st.generate_normals()
	st.generate_tangents()
	mesh.surface_remove(0)
	st.commit(mesh)
	st.clear()
	st.index()
	mdt.clear()
	mdt.call_deferred("queue_free")
	st.call_deferred("queue_free")

# Function to update the height of hexagon
func updateHeight(height):
	updating_height = true
	#top.visible = false
	cell_height = height
	get_node("CellBody").scale.y = height
	get_node("StaticBody2").translation.y = height + 0.01
#	top.translation.y = height
	new_mesh_top.translation.y = height
	innerSides.translation.y = height
	edge_positions.translation.y = height
	if cell_height > 1:
		shadow(true)
	else:
		shadow(false)

	var mdt = MeshDataTool.new()
	mdt.create_from_surface(top_mesh, 0)
	if new_arr_mesh.get_surface_count() > 0:
		new_arr_mesh.surface_remove(0)
	mdt.commit_to_surface(new_arr_mesh)

	neighbors = [null,null,null,null,null,null]
	var vertices = [0,0,0,0,0,0]
	if east != null:
		neighbors[0] = east
		vertices[0] = 36
	if northEast != null:
		neighbors[1] = northEast
		vertices[1] = 30
	if northWest != null:
		neighbors[2] = northWest
		vertices[2] = 24
	if west != null:
		neighbors[3] = west
		vertices[3] = 18
	if southWest != null:
		neighbors[4] = southWest
		vertices[4] = 48
	if southEast != null:
		neighbors[5] = southEast
		vertices[5] = 42
	
	resetEdges()
	
	var slopeUpNeighbors = [0,0,0,0,0,0]
	var slopeDownNeighbors = [0,0,0,0,0,0]
	
	for i in neighbors.size():
		var vertex = vertices[i]
		var wr = weakref(neighbors[i])
		if (!wr.get_ref()):
			continue
		else:
			if neighbors[i] != null:
				neighbors[i].updateNeighborHeight()
				if cell_height == neighbors[i].cell_height - 1:
					slopeUpNeighbors[i] = vertex
					sloped = true
				if cell_height == neighbors[i].cell_height + 1:
					slopeDownNeighbors[i] = vertex
					sloped = true
	if sloped and isSlopeable:
		slopeEdges(new_arr_mesh,slopeUpNeighbors,slopeDownNeighbors)
		new_mesh_top.mesh = new_arr_mesh
#		get_node("CellBody/CollisionShape").scale.y = max(get_node("CellBody").scale.y - .5, 1)
#		get_node("CellBody/CollisionShape").translation.y -= .5
		createNewCollision()
	else:
		revertCollision()
	emit_signal("height_updated")
	updating_height = false
	mdt.call_deferred("queue_free")

func updateNeighborHeight():
	top.visible = false
	get_node("CellBody").scale.y = cell_height
	get_node("StaticBody2").translation.y = cell_height + 0.01
#	top.translation.y = cell_height
	new_mesh_top.translation.y = cell_height
	innerSides.translation.y = cell_height
	edge_positions.translation.y = cell_height
	if cell_height > 1:
		shadow(true)
	else:
		shadow(false)

	var mdt = MeshDataTool.new()
	mdt.create_from_surface(top_mesh, 0)
	if new_arr_mesh.get_surface_count() > 0:
		new_arr_mesh.surface_remove(0)
	mdt.commit_to_surface(new_arr_mesh)
	mdt.call_deferred("queue_free")

	neighbors = [null,null,null,null,null,null]
	var vertices = [0,0,0,0,0,0]
	if east != null:
		neighbors[0] = east
		vertices[0] = 36
	if northEast != null:
		neighbors[1] = northEast
		vertices[1] = 30
	if northWest != null:
		neighbors[2] = northWest
		vertices[2] = 24
	if west != null:
		neighbors[3] = west
		vertices[3] = 18
	if southWest != null:
		neighbors[4] = southWest
		vertices[4] = 48
	if southEast != null:
		neighbors[5] = southEast
		vertices[5] = 42
	
	resetEdges()
	
	var slopeUpNeighbors = [0,0,0,0,0,0]
	var slopeDownNeighbors = [0,0,0,0,0,0]
	
	for i in neighbors.size():
		var vertex = vertices[i]
		var wr = weakref(neighbors[i])
		if (!wr.get_ref()):
			continue
		else:
			if neighbors[i] != null:
				if cell_height == neighbors[i].cell_height - 1:
					slopeUpNeighbors[i] = vertex
					sloped = true
				if cell_height == neighbors[i].cell_height + 1:
					slopeDownNeighbors[i] = vertex
					sloped = true
	if sloped and isSlopeable:
		slopeEdges(new_arr_mesh,slopeUpNeighbors,slopeDownNeighbors)
		new_mesh_top.mesh = new_arr_mesh
#		get_node("CellBody/CollisionShape").scale.y = max(get_node("CellBody").scale.y - .5, 1)
#		get_node("CellBody/CollisionShape").translation.y -= .5
		createNewCollision()
	else:
		revertCollision()

# Function to turn on and off the hexagon's shadow
func shadow(on:bool):
	if on:
#		top.cast_shadow = GeometryInstance.SHADOW_CASTING_SETTING_ON
		new_mesh_top.cast_shadow = GeometryInstance.SHADOW_CASTING_SETTING_ON
		for i in sides.get_child_count():
			sides.get_child(i).cast_shadow = GeometryInstance.SHADOW_CASTING_SETTING_ON
	else:
#		top.cast_shadow = GeometryInstance.SHADOW_CASTING_SETTING_OFF
		new_mesh_top.cast_shadow = GeometryInstance.SHADOW_CASTING_SETTING_OFF
		for i in sides.get_child_count():
			sides.get_child(i).cast_shadow = GeometryInstance.SHADOW_CASTING_SETTING_OFF

func resetEdges():
	sides.get_node("E").visible = true
	sides.get_node("NE").visible = true
	sides.get_node("NW").visible = true
	sides.get_node("W").visible = true
	sides.get_node("SW").visible = true
	sides.get_node("SE").visible = true
	downEdges.get_node("2").visible = false
	downEdges.get_node("4").visible = false
	downEdges.get_node("6").visible = false
	downEdges.get_node("8").visible = false
	downEdges.get_node("10").visible = false
	downEdges.get_node("12").visible = false
	upEdges.get_node("2").visible = false
	upEdges.get_node("4").visible = false
	upEdges.get_node("6").visible = false
	upEdges.get_node("8").visible = false
	upEdges.get_node("10").visible = false
	upEdges.get_node("12").visible = false

func changeSurface(surface):
	if surface == "grass":
		var grass:Material = load("res://resources/materials/grass.material")
		var grass_side:Material = load("res://resources/materials/grass_side.material")
		type = surface
		new_mesh_top.set_surface_material(0,grass)
		top.set_surface_material(0,grass)
		for node in downEdges.get_children():
			node.mesh.surface_set_material(0,grass_side)
		for node in upEdges.get_children():
			node.mesh.surface_set_material(0,grass_side)
	if surface == "dirt":
		var dirt:Material = load("res://resources/materials/dirt.material")
		var dirt_side:Material = load("res://resources/materials/dirt_side.material")
		type = surface
		new_mesh_top.set_surface_material(0,dirt)
		top.set_surface_material(0,dirt)
		for node in downEdges.get_children():
			node.mesh.surface_set_material(0,dirt_side)
		for node in upEdges.get_children():
			node.mesh.surface_set_material(0,dirt_side)

func setTransparency(transparent:bool) -> void:
	originalShape.disabled = transparent
	slopedShape.disabled = transparent
#	var transparent_top_material:SpatialMaterial = top.get_surface_material(0).duplicate()
#	var transparent_innerside_material:SpatialMaterial = downEdges.get_child(0).mesh.surface_get_material(0).duplicate()
#	var transparent_side_material:SpatialMaterial = sides.get_child(0).get_surface_material(0).duplicate()
#	if transparent:
#		transparent_top_material.flags_transparent = true
#		transparent_top_material.albedo_color = Color(1,1,1,.25)
#		transparent_innerside_material.flags_transparent = true
#		transparent_innerside_material.albedo_color = Color(1,1,1,.25)
#		transparent_side_material.flags_transparent = true
#		transparent_side_material.albedo_color = Color(1,1,1,.25)
#	else:
#		transparent_top_material.flags_transparent = false
#		transparent_top_material.albedo_color = Color(1,1,1,1)
#		transparent_innerside_material.flags_transparent = false
#		transparent_innerside_material.albedo_color = Color(1,1,1,1)
#		transparent_side_material.flags_transparent = false
#		transparent_side_material.albedo_color = Color(1,1,1,1)
#	top.set_surface_material(0, transparent_top_material)
#	new_mesh_top.set_surface_material(0, transparent_top_material)
#	for node in downEdges.get_children():
#		node.mesh.surface_set_material(0,transparent_innerside_material)
#	for node in upEdges.get_children():
#		node.mesh.surface_set_material(0,transparent_innerside_material)
#	for node in sides.get_children():
#		node.set_surface_material(0,transparent_side_material)

func createNewCollision():
	new_mesh_top.visible = true
#	top.visible = false
	new_shape = new_arr_mesh.create_trimesh_shape()
	slopedShape.shape = new_shape
	originalShape.disabled = false
	slopedShape.disabled = false

func revertCollision():
	new_mesh_top.visible = true
#	top.visible = true
	originalShape.disabled = false
	slopedShape.disabled = false

func setNeighbors(cells):
	for i in cells.size():
		if cells[i] == null:
			continue
		if cells[i].cubeCoordinates == HexUtils.cubeNeighbor(cubeCoordinates, 0):
			east = cells[i]
			east.neighborSetNeighbors(cells)
		if cells[i].cubeCoordinates == HexUtils.cubeNeighbor(cubeCoordinates, 1):
			southEast = cells[i]
			southEast.neighborSetNeighbors(cells)
		if cells[i].cubeCoordinates == HexUtils.cubeNeighbor(cubeCoordinates, 2):
			southWest = cells[i]
			southWest.neighborSetNeighbors(cells)
		if cells[i].cubeCoordinates == HexUtils.cubeNeighbor(cubeCoordinates, 3):
			west = cells[i]
			west.neighborSetNeighbors(cells)
		if cells[i].cubeCoordinates == HexUtils.cubeNeighbor(cubeCoordinates, 4):
			northWest = cells[i]
			northWest.neighborSetNeighbors(cells)
		if cells[i].cubeCoordinates == HexUtils.cubeNeighbor(cubeCoordinates, 5):
			northEast = cells[i]
			northEast.neighborSetNeighbors(cells)
	populateNeighbors()

func neighborSetNeighbors(cells):
	var cellNeighbor
	for i in cells.size():
		cellNeighbor = cells[i]
		if cellNeighbor == null:
			continue
		if cellNeighbor.cubeCoordinates == HexUtils.cubeNeighbor(cubeCoordinates, 0):
			east = cellNeighbor
		if cellNeighbor.cubeCoordinates == HexUtils.cubeNeighbor(cubeCoordinates, 1):
			southEast = cellNeighbor
		if cellNeighbor.cubeCoordinates == HexUtils.cubeNeighbor(cubeCoordinates, 2):
			southWest = cellNeighbor
		if cellNeighbor.cubeCoordinates == HexUtils.cubeNeighbor(cubeCoordinates, 3):
			west = cellNeighbor
		if cellNeighbor.cubeCoordinates == HexUtils.cubeNeighbor(cubeCoordinates, 4):
			northWest = cellNeighbor
		if cellNeighbor.cubeCoordinates == HexUtils.cubeNeighbor(cubeCoordinates, 5):
			northEast = cellNeighbor
	populateNeighbors()

func populateNeighbors():
	neighbors.clear()
	if east != null:
		neighbors.append(east)
	if southEast != null:
		neighbors.append(southEast)
	if southWest != null:
		neighbors.append(southWest)
	if west != null:
		neighbors.append(west)
	if northWest != null:
		neighbors.append(northWest)
	if northEast != null:
		neighbors.append(northEast)

func isHexagonalTo(other:HexCell) -> bool:
	if other.cubeCoordinates.x == cubeCoordinates.x:
		if other.cubeCoordinates.y != cubeCoordinates.y and other.cubeCoordinates.z != cubeCoordinates.z:
			return true
	if other.cubeCoordinates.y == cubeCoordinates.y:
		if other.cubeCoordinates.x != cubeCoordinates.x and other.cubeCoordinates.z != cubeCoordinates.z:
			return true
	if other.cubeCoordinates.z == cubeCoordinates.z:
		if other.cubeCoordinates.x != cubeCoordinates.x and other.cubeCoordinates.y != cubeCoordinates.y:
			return true
	return false

func get_neighbors() -> Array:
	var neigh:Array = []
	for i in neighbors.size():
		if neighbors[i] != null:
			neigh.append(neighbors[i])
	return neigh

# Function to get distance to another cell
func distanceTo(other):
# warning-ignore:narrowing_conversion
	var dx:int = abs(cubeCoordinates.x - other.cubeCoordinates.x)
# warning-ignore:narrowing_conversion
	var dy:int = abs(cubeCoordinates.y - other.cubeCoordinates.y)
# warning-ignore:narrowing_conversion
	var dz:int = abs(cubeCoordinates.z - other.cubeCoordinates.z)
# warning-ignore:integer_division
	return (dx+dy+dz) / 2


func searchCellSplashDistance():
	var cells = grid.cells
	for i in cells.size():
		cells[i].target_distance = distanceTo(cells[i])


# warning-ignore:unused_argument
func checkValidSplashRangeCells(card,splash_min_range,splash_max_range,splash_up_vertical_range,splash_down_vertical_range):
	clearValidRangeCells()
	walkDistance = 0
	var frontier:Array = [self]
	var card_min_splash_range:int = splash_min_range
	var card_max_splash_range:int = splash_max_range
	var card_up_vertical_range:int = splash_up_vertical_range
	var card_down_vertical_range:int = splash_down_vertical_range
	validRangeCells.append(self) # include source cell
	while frontier.size() > 0:
		frontierSearchNeighbors(frontier, card_max_splash_range)
	for i in range(validRangeCells.size() - 1, -1, -1):
		if validRangeCells[i].target_distance < card_min_splash_range:
			validRangeCells[i].unvalidifyRange()
			validRangeCells.remove(i)
			continue
		if validRangeCells[i].target_distance > card_max_splash_range:
			validRangeCells[i].unvalidifyRange()
			validRangeCells.remove(i)
			continue
		if validRangeCells[i].cell_height - cell_height > card_up_vertical_range or cell_height - validRangeCells[i].cell_height > card_down_vertical_range:
			validRangeCells[i].unvalidifyRange()
			validRangeCells.remove(i)
			continue

# warning-ignore:unused_argument
func checkValidInlineRangeCells(card,inline_inner_range,inline_outer_range,inline_up_vertical_range,inline_down_vertical_range):
	clearValidRangeCells()
	walkDistance = 0
	var frontier:Array = [self]
	var unit_coordinates:Vector3 = card.card_caster.currentCell.cubeCoordinates
	var direction:Vector3 = cubeCoordinates - unit_coordinates
	var card_inner_range:int = inline_inner_range
	var card_outer_range:int = inline_outer_range
	var card_up_vertical_range:int = inline_up_vertical_range
	var card_down_vertical_range:int = inline_down_vertical_range
	validRangeCells.append(self) # include source cell
	while frontier.size() > 0:
		frontierSearchNeighbors(frontier, card_outer_range)
	for i in range(validRangeCells.size() - 1, -1, -1):
		if validRangeCells[i].cell_height - cell_height > card_up_vertical_range or cell_height - validRangeCells[i].cell_height > card_down_vertical_range:
			validRangeCells[i].unvalidifyRange()
			validRangeCells.remove(i)
			continue
		if direction.x == 0 or direction.y == 0:
			if direction.z > 0: # target is NE
				if validRangeCells[i].cubeCoordinates.z < cubeCoordinates.z - card_inner_range:
					validRangeCells[i].unvalidifyRange()
					validRangeCells.remove(i)
				if validRangeCells[i].cubeCoordinates.z > cubeCoordinates.z + card_outer_range:
					validRangeCells[i].unvalidifyRange()
					validRangeCells.remove(i)
			else:
				if validRangeCells[i].cubeCoordinates.z > cubeCoordinates.z + card_inner_range:
					validRangeCells[i].unvalidifyRange()
					validRangeCells.remove(i)
				if validRangeCells[i].cubeCoordinates.z < cubeCoordinates.z - card_outer_range:
					validRangeCells[i].unvalidifyRange()
					validRangeCells.remove(i)
		if direction.z == 0:
			if direction.x > 0: # target is E
				if validRangeCells[i].cubeCoordinates.y > cubeCoordinates.y + card_inner_range:
					validRangeCells[i].unvalidifyRange()
					validRangeCells.remove(i)
				if validRangeCells[i].cubeCoordinates.y < cubeCoordinates.y - card_outer_range:
					validRangeCells[i].unvalidifyRange()
					validRangeCells.remove(i)
			else:
				if validRangeCells[i].cubeCoordinates.y < cubeCoordinates.y - card_inner_range:
					validRangeCells[i].unvalidifyRange()
					validRangeCells.remove(i)
				if validRangeCells[i].cubeCoordinates.y > cubeCoordinates.y + card_outer_range:
					validRangeCells[i].unvalidifyRange()
					validRangeCells.remove(i)
		if unit_coordinates.x == cubeCoordinates.x:
			if validRangeCells[i].cubeCoordinates.x != cubeCoordinates.x:
				validRangeCells[i].unvalidifyRange()
				validRangeCells.remove(i)
				continue
		if unit_coordinates.y == cubeCoordinates.y:
			if validRangeCells[i].cubeCoordinates.y != cubeCoordinates.y:
				validRangeCells[i].unvalidifyRange()
				validRangeCells.remove(i)
				continue
		if unit_coordinates.z == cubeCoordinates.z:
			if validRangeCells[i].cubeCoordinates.z != cubeCoordinates.z:
				validRangeCells[i].unvalidifyRange()
				validRangeCells.remove(i)
				continue

func frontierSearchNeighbors(frontier, horizontalCheck):
#	var sourceCell = self
	var currentCell = frontier.front() # currentCell is first cell in frontier
	frontier.pop_front() # remove first cell from frontier
	for i in currentCell.neighbors.size():
		var frontier_cell = currentCell.neighbors[i]
		if currentCell.neighbors[i] != null:
			if validRangeCells.find(frontier_cell) == -1: #if it's not valid yet
				if currentCell.walkDistance < horizontalCheck: #if it's within walking range
					frontier_cell.walkDistance = currentCell.walkDistance + 1
					frontier_cell.pathFrom = currentCell
					validRangeCells.append(frontier_cell)
					frontier.push_back(frontier_cell) #add valid neighbor cells to frontier


func clearValidRangeCells():
	for i in validRangeCells.size():
		validRangeCells[i].unvalidifyRange()
	validRangeCells.clear()


func getSplash(card,splash_min_range,splash_max_range,splash_up_vertical_range,splash_down_vertical_range) -> Array:
	searchCellSplashDistance()
	checkValidSplashRangeCells(card,splash_min_range,splash_max_range,splash_up_vertical_range,splash_down_vertical_range)
	return validRangeCells

func getInline(card,inline_inner_range,inline_outer_range,inline_up_vertical_range,inline_down_vertical_range) -> Array:
	searchCellSplashDistance()
	checkValidInlineRangeCells(card,inline_inner_range,inline_outer_range,inline_up_vertical_range,inline_down_vertical_range)
	return validRangeCells

func getLeftRight(card,width,depth,splash_up_vertical_range,splash_down_vertical_range) -> Array:
	searchCellSplashDistance()
	checkValidSplashRangeCells(card,0,width,splash_up_vertical_range,splash_down_vertical_range)
	var caster_distance = distanceTo(card.card_caster.currentCell)
	var cells = validRangeCells
	for i in cells.size():
		cells[i].target_distance = card.card_caster.currentCell.distanceTo(cells[i])
	for i in range(validRangeCells.size() - 1, -1, -1):
		if validRangeCells[i].target_distance < caster_distance - depth or validRangeCells[i].target_distance > caster_distance:
			validRangeCells[i].unvalidifyRange()
			validRangeCells.remove(i)
			continue
	return validRangeCells

func validify():
	valid = true
	var top_material:SpatialMaterial = top.get_surface_material(0).duplicate()
	var shader_mat:ShaderMaterial = ShaderMaterial.new()
	shader_mat.shader = load("res://resources/shaders/move_cell.tres")
	top_material.next_pass = shader_mat
	new_mesh_top.set_surface_material(0, top_material)
#	var mat:SpatialMaterial = SpatialMaterial.new()
#	mat.albedo_color = Color.white
#	outline.mesh.surface_set_material(0,mat)
#	mat.call_deferred("queue_free")
#	outline.visible = true

func unvalidify():
	valid = false
	var top_material:SpatialMaterial = top.get_surface_material(0).duplicate()
	top_material.next_pass = null
	new_mesh_top.set_surface_material(0, top_material)
	outline.visible = false
	outline.visible = false

func validifyRange():
	valid_range = true
	var top_material:SpatialMaterial = top.get_surface_material(0).duplicate()
	var shader_mat:ShaderMaterial = ShaderMaterial.new()
	shader_mat.shader = load("res://resources/shaders/range_cell.tres")
	top_material.next_pass = shader_mat
	new_mesh_top.set_surface_material(0, top_material)
#	var mat:SpatialMaterial = SpatialMaterial.new()
#	mat.albedo_color = Color(1,1,1,.1)
#	outline.mesh.surface_set_material(0,mat)
#	mat.call_deferred("queue_free")
#	outline.visible = true

func unvalidifyRange():
	valid_range = false
	var top_material:SpatialMaterial = top.get_surface_material(0).duplicate()
	top_material.next_pass = null
	new_mesh_top.set_surface_material(0, top_material)
	outline.visible = false

func validifyAttack():
	valid_attack = true
	var top_material:SpatialMaterial = top.get_surface_material(0).duplicate()
	var shader_mat:ShaderMaterial = ShaderMaterial.new()
	shader_mat.shader = load("res://resources/shaders/attack_cell.tres")
	top_material.next_pass = shader_mat
#	top.set_surface_material(0, top_material)
	new_mesh_top.set_surface_material(0, top_material)

func unvalidifyAttack():
	valid_attack = false
	var top_material:SpatialMaterial = top.get_surface_material(0).duplicate()
	top_material.next_pass = null
#	top.set_surface_material(0, top_material)
	new_mesh_top.set_surface_material(0, top_material)

func save():
	var data = {
		"x": save_data.get("x"),
		"z": save_data.get("z"),
		"height": cell_height,
		"surface": type
	}
	return data

func clear():
#	new_arr_mesh.free()
	queue_free()
