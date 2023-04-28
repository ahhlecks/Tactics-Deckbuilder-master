extends Spatial

class_name HexGrid

const MAP_SAVE_DIR:String = "user://maps/"

#var CellPrefab = preload("res://objects/HexCell.tscn")
var UnitPrefab = preload("res://objects/HexUnit.tscn")
var NinePatchPrefab = preload("res://objects/UI/NinePatchRect.tscn")

export (int) var width = 5
export (int) var height = 5
export (int) var cell_size = 3
export (float) var cell_height = 1

#onready var camera = get_node("../Camera")
#onready var camera_gimbal = get_node("../CameraGimbal")
onready var camera_rig = get_node("../CameraRig")
onready var camera = get_node("../CameraRig/Camera")
onready var battle_controller = get_node("../BattleController")

var lastClickedCell:Spatial
var lastHighlighted:MeshInstance
var lastHighlightedUnit:HexUnit
var lastSelectedUnit:HexUnit
var editMode:bool = true
var disableHexHighlight:bool = false
var clear:bool = true

onready var ui = get_node("../EditMenu/UI")
onready var edit_menu = get_node("../EditMenu")
#onready var unit_maker = get_node("../EditMenu/UnitMaker")
onready var edit_mode_label = get_node("../EditModeLabel")
onready var window_dialog = get_node("../WindowDialog")
onready var play_button = get_node("../PlayButton")
var action_prompt

signal unit_selected(unit)
signal destination_selected()
signal map_loaded()

# Array for all hex cells
var cells = Array()
# Array for all hex units
var units = Array()

#onready var card_actor:Card = Card.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
#	battle_controller.clearAll()
#	for z in range(0,height):
#		for x in range(0,width):
#			createCell(x,z,cell_height,"grass")
#			x += 1
#		z += 1
#	for i in cells.size():
#		setNeighbors(i)

#Map Editor
func _unhandled_input(event):
	# Click a cell or unit
	var click = mouseClick(event)
	if click:
#		print(click.collider.name)
		if click.collider.get_class() == "Spatial":
			if click.collider.name == "WorldScene":
				deselectUnit(lastSelectedUnit)
		if click.collider.get_class() == "StaticBody":
			if click.collider.name == "WorldMesh":
				deselectUnit(lastSelectedUnit)
				if ui.get_node("HBox2/Add").pressed:
					var pixToHex:Vector2 = HexUtils.pixelToHex(Vector2(click.position.x,-click.position.z),cell_size)
					var hex:Vector2 = Vector2(pixToHex.x,pixToHex.y)
					for i in cells.size():
						if cells[i].axialCoordinates == hex:
							return
					var newCell = createCell(pixToHex.x+(pixToHex.y/2),pixToHex.y,1,"grass")
					newCell.setNeighbors(cells)
					if ui.get_node("HBox1/Height").pressed:
						newCell.updateHeight(clamp(float(ui.get_node("./HBox1/HeightValue").get_line_edit().text),1.0,30.0))
			if click.collider.get_owner().name.find("HexCell") == 1 or click.collider.get_owner().name.find("HexCell") == 0:
				var selectedHex = click.collider.get_owner()
				lastClickedCell = selectedHex
				#Deselect Unit if Click Invalid Cell
				if selectedHex.valid:
					#Move Unit to new Cell
					if !editMode:
						battle_controller.battle_gui.active_unit.moveTo(selectedHex)
					else:
						lastSelectedUnit.editModeMoveTo(selectedHex)
				elif selectedHex.valid_range:
					if !editMode:
						for cell in cells:
							cell.unvalidifyRange()
						battle_controller.battle_gui.actionPrompt(selectedHex)
				else:
					deselectUnit(lastSelectedUnit)
				#Change cell texture
				if ui.get_node("HBox1/SurfaceType").selected == 1:
					selectedHex.changeSurface("grass")
				if ui.get_node("HBox1/SurfaceType").selected == 2:
					selectedHex.changeSurface("dirt")                 
				#Change cell Height
				if ui.get_node("HBox1/Height").pressed:
					selectedHex.cell_height = clamp(float(ui.get_node("./HBox1/HeightValue").get_line_edit().text),1.0,30.0)
					selectedHex.updateHeight(selectedHex.cell_height)
					if selectedHex.unit != null:
						selectedHex.unit.set_translation(Vector3(selectedHex.unit.position.x,(selectedHex.cell_height * 0.5) + 1 ,selectedHex.unit.position.z))
				#Delete Cell
				if ui.get_node("HBox2/Delete").pressed:
					var ref_cell = weakref(selectedHex)
					if ref_cell.get_ref() != null:
						ref_cell.get_ref().updateHeight(1)
						lastHighlighted = null
						cells.erase(cells[cells.find(ref_cell.get_ref())])
						ref_cell.get_ref().setNeighbors(cells)
#						ref_cell.get_ref().call_deferred("queue_free")
#					selectedHex.free()
					selectedHex.clear()
				#Add Unit
				if ui.get_node("HBox3/AddUnit").pressed:
					if selectedHex.unit == null:
						var newUnit = createUnit(selectedHex)
						selectedHex.unit = newUnit
			if click.collider.name.find("Direction") == 0:
				click.collider.get_parent().get_parent().turnDirection(click.collider.name)
			if click.collider.get_parent().get_parent().get_class() == "HexUnit" and click.collider.name.find("Direction") == -1: # Clicked on Unit's Side Collision Shape
				var selectedUnit:HexUnit = click.collider.get_parent().get_parent()
				if editMode:
					selectUnit(selectedUnit)
#					unit_maker._on_Owned_toggled(selectedUnit.player_owned)
#					unit_maker.owned_button.pressed = selectedUnit.player_owned
#					unit_maker.update_fields(selectedUnit)
					if ui.get_node("HBox3/DeleteUnit").pressed:
						deleteUnit(selectedUnit) # Needs to be fixed
				elif selectedUnit.currentCell.valid_range and !editMode:
					for cell in cells:
						cell.unvalidifyRange()
					battle_controller.battle_gui.actionPrompt(selectedUnit.currentCell)
				if !editMode:
					if selectedUnit.isActive and !selectedUnit.is_ai_controlled:
						selectedUnit.select()
		if click.collider.get_class() == "HexUnit": # Click on the unit itself
				var selectedUnit:HexUnit = click.collider
				if editMode:
					selectUnit(selectedUnit)
#					unit_maker._on_Owned_toggled(selectedUnit.player_owned)
#					unit_maker.owned_button.pressed = selectedUnit.player_owned
#					unit_maker.update_fields(selectedUnit)
					if ui.get_node("HBox3/DeleteUnit").pressed:
						deleteUnit(selectedUnit) # Needs to be fixed
				elif selectedUnit.currentCell.valid_range and !editMode:
					for cell in cells:
						cell.unvalidifyRange()
					battle_controller.battle_gui.actionPrompt(selectedUnit.currentCell)
				if !editMode:
					if selectedUnit.isActive and !selectedUnit.is_ai_controlled:
						selectedUnit.select()
	# Mouse over a cell
	var over = mouseOver(event)
	if over:
		if over.collider.get_class() == "StaticBody":
			if !editMode:
#				lastHighlightedUnit.hideLifeBar()
				lastHighlightedUnit = null
			if over.collider.get_owner().name.find("HexCell") == 1 or over.collider.get_owner().name.find("HexCell") == 0:
				var selectedHex:Spatial = over.collider.get_owner()
				if selectedHex != null and !disableHexHighlight:
					var wr = weakref(lastHighlighted)
					if (!wr.get_ref()):
						pass
					else:
						lastHighlighted.visible = false
					lastHighlighted = selectedHex.get_node("./CellBody/Select")
					lastHighlighted.visible = true
				#Click and Drag over cells
				if lastClickedCell != selectedHex:
					if Input.is_action_pressed("mouse_left"):
						#Change cell texture
						if ui.get_node("./HBox1/SurfaceType").selected == 1:
							selectedHex.changeSurface("grass")
						if ui.get_node("./HBox1/SurfaceType").selected == 2:
							selectedHex.changeSurface("dirt")
						#Change Cell Height
						if ui.get_node("./HBox1/Height").pressed:
							selectedHex.cell_height = clamp(float(ui.get_node("./HBox1/HeightValue").get_line_edit().text),1.0,30.0)
							selectedHex.updateHeight(selectedHex.cell_height)
							if selectedHex.unit != null:
								selectedHex.unit.set_translation(Vector3(selectedHex.unit.position.x,(selectedHex.cell_height * 0.5) + 1 ,selectedHex.unit.position.z))
		if over.collider.get_class() == "HexUnit":
			var selectedHex:Spatial = over.collider.currentCell
			if selectedHex != null and !disableHexHighlight:
				if lastHighlighted != null: lastHighlighted.visible = false
				lastHighlighted = selectedHex.get_node("./CellBody/Select")
				lastHighlighted.visible = true
		if over.collider.name.find("Side") == 0:
			var selectedHex:Spatial = over.collider.get_parent().get_parent().currentCell
			if selectedHex != null and !disableHexHighlight:
				if lastHighlighted != null: lastHighlighted.visible = false
				lastHighlighted = selectedHex.get_node("./CellBody/Select")
				lastHighlighted.visible = true
#		Show the HP bar when mouse hovers over unit
#		if over.collider.get_class() == "KinematicBody" and !editMode:
#			if (over.collider.name.find("HexUnit") == 1 or over.collider.name.find("HexUnit") == 0):
#				lastHighlightedUnit = over.collider
#				lastHighlightedUnit.showLifeBar()
#		else:
#			if lastHighlighted != null:
#				lastHighlighted.visible = false

func createCell(x,z,height,surface):
	var data = {
		"x": x,
		"z": z,
		"height": height,
		"surface": surface
	}
	var axial = Vector2(x-(z/2),z)
	var cube = HexUtils.axialToCube(axial)
	var oddR = HexUtils.cubeToOddR(cube)
	var position:Vector3 = Vector3(0,0,0)
	position.x = HexUtils.axialToPixel(axial,cell_size).x
	position.z = -HexUtils.axialToPixel(axial,cell_size).y
#	var cell:Spatial = CellPrefab.instance()
	var cell:Spatial = load("res://objects/HexCell.tscn").instance()
	cell.grid = self
	cell.save_data = data
	cell.axialCoordinates = axial
	cell.cubeCoordinates = cube
	cell.oddRCoordinates = oddR
	cell.translate(position)
	cell.get_node("CellBody").scale.x = cell_size * 1.001
	cell.get_node("CellBody").scale.z = cell_size * 1.001
	cell.get_node("EdgePositions").scale.x = cell_size * 1.001
	cell.get_node("EdgePositions").scale.z = cell_size * 1.001
	cell.get_node("StaticBody2").scale.x = cell_size * 1.001
	cell.get_node("StaticBody2").scale.z = cell_size * 1.001
	cell.get_node("Top").scale.x = cell_size * 1.001
	cell.get_node("Top").scale.z = cell_size * 1.001
	cell.get_node("SlopedTop").scale.x = cell_size * 1.001
	cell.get_node("SlopedTop").scale.z = cell_size * 1.001
	cell.get_node("InnerSides").scale.x = cell_size * 1.001
	cell.get_node("InnerSides").scale.z = cell_size * 1.001
	cells.append(cell)
	add_child(cell)
	cell.changeSurface(surface)
	cell.updateHeight(height)
	return cell

func createUnit(cell):
	var axial = cell.axialCoordinates
	var cube = HexUtils.axialToCube(axial)
	var oddR = HexUtils.cubeToOddR(cube)
	var position:Vector3 = Vector3(0,0,0)
	position.x = HexUtils.axialToPixel(cell.axialCoordinates, cell_size).x
	position.y = cell.cell_height * cell.scale.y
	position.z = -HexUtils.axialToPixel(cell.axialCoordinates, cell_size).y
	var unit:HexUnit = UnitPrefab.instance()
	unit.loadData(edit_menu.current_unit)
	unit.grid = self
	unit.axialCoordinates = axial
	unit.cubeCoordinates = cube
	unit.oddRCoordinates = oddR
	unit.translate(position)
	unit.position = position
	unit.currentCell = cell
	unit.currentCell.unit = unit
	unit.elevation = cell.cell_height
#	unit_maker.updateUnit(unit)
	units.append(unit)
	add_child(unit)
	return unit

func loadUnit(save_data):
	var unit:HexUnit = UnitPrefab.instance()
	unit.grid = self
#	unit.loadData(save_data)
	unit.basicLoadData(save_data)
	units.append(unit)
	add_child(unit)
	return unit

func setCellNeighbors(cell:HexCell):
	var cellNeighbor:HexCell
	for i in cells.size():
		cellNeighbor = cells[i]
		if cellNeighbor == null:
			return
		if cellNeighbor.cubeCoordinates == HexUtils.cubeNeighbor(cell.cubeCoordinates, 0):
			cell.east = cellNeighbor
		if cellNeighbor.cubeCoordinates == HexUtils.cubeNeighbor(cell.cubeCoordinates, 1):
			cell.southEast = cellNeighbor
		if cellNeighbor.cubeCoordinates == HexUtils.cubeNeighbor(cell.cubeCoordinates, 2):
			cell.southWest = cellNeighbor
		if cellNeighbor.cubeCoordinates == HexUtils.cubeNeighbor(cell.cubeCoordinates, 3):
			cell.west = cellNeighbor
		if cellNeighbor.cubeCoordinates == HexUtils.cubeNeighbor(cell.cubeCoordinates, 4):
			cell.northWest = cellNeighbor
		if cellNeighbor.cubeCoordinates == HexUtils.cubeNeighbor(cell.cubeCoordinates, 5):
			cell.northEast = cellNeighbor
	cell.populateNeighbors()

func setNeighbors(i):
	var originCell = cells[i]
	var cellNeighbor = load("res://objects/HexCell.tscn").instance()
	for i in cells.size():
		if cells[i] == null:
			return
		cellNeighbor = cells[i]
		if cellNeighbor.cubeCoordinates == HexUtils.cubeNeighbor(originCell.cubeCoordinates, 0):
			originCell.east = cellNeighbor
		if cellNeighbor.cubeCoordinates == HexUtils.cubeNeighbor(originCell.cubeCoordinates, 1):
			originCell.southEast = cellNeighbor
		if cellNeighbor.cubeCoordinates == HexUtils.cubeNeighbor(originCell.cubeCoordinates, 2):
			originCell.southWest = cellNeighbor
		if cellNeighbor.cubeCoordinates == HexUtils.cubeNeighbor(originCell.cubeCoordinates, 3):
			originCell.west = cellNeighbor
		if cellNeighbor.cubeCoordinates == HexUtils.cubeNeighbor(originCell.cubeCoordinates, 4):
			originCell.northWest = cellNeighbor
		if cellNeighbor.cubeCoordinates == HexUtils.cubeNeighbor(originCell.cubeCoordinates, 5):
			originCell.northEast = cellNeighbor
	originCell.populateNeighbors()

func findHex(coords:Vector2) -> HexCell:
	for i in cells.size():
		if cells[i].axialCoordinates == coords:
			return cells[i]
	return null

func findCubeHex(coords:Vector3) -> HexCell:
	for i in cells.size():
		if cells[i].cubeCoordinates == coords:
			return cells[i]
	return null

func mouseClick(event):
	if Input.is_action_pressed("mouse_left"):
		if event is InputEventMouseButton:
			var from:Vector3 = camera.project_ray_origin(event.position)
			var to = from + camera.project_ray_normal(event.position) * camera.far
			var space_state = get_world().get_direct_space_state()
			# use global coordinates, not local to node
			var result = space_state.intersect_ray( from, to )
			if result.has("collider"):
				return result
			else:
				var noCollider = {"collider": get_parent()}
				return noCollider

func mouseOver(event):
	if event is InputEventMouseMotion:
		var from:Vector3 = camera.project_ray_origin(event.position)
		var to = from + camera.project_ray_normal(event.position) * camera.far
		var space_state = get_world().get_direct_space_state()
		# use global coordinates, not local to node
		var result = space_state.intersect_ray( from, to )
		if result.has("collider"):
			return result
		else:
			return null

func selectUnit(unit:HexUnit):
	deselectUnit(lastSelectedUnit)
	if unit != null and lastSelectedUnit != unit:
		unit.select()
#		if editMode:
#			unit_maker.update_fields(unit)
		lastSelectedUnit = unit
	else:
		lastSelectedUnit = null

func deselectUnit(unit:HexUnit):
	if unit != null:
		unit.deselect()

func deleteUnit(unit:HexUnit):
	deselectUnit(unit)
	unit.currentCell.unit = null
	units.erase(units[units.find(unit)])
	lastHighlighted = null
	unit.call_deferred("queue_free")
	lastSelectedUnit = null

func deleteUnitAt(index:int):
	if units.size() > index:
		var current_unit = units[index]
		if (current_unit.player_owned and edit_menu.current_unit.player_owned) or (!current_unit.player_owned and !edit_menu.current_unit.player_owned):
			deselectUnit(current_unit)
			current_unit.currentCell.unit = null
			units.erase(units[units.find(index)])
			lastHighlighted = null
			current_unit.call_deferred("queue_free")
			lastSelectedUnit = null

func save_map(path:String):
	var saved_units:Array
	for i in units.size():
#		saved_units.append(units[i].save())
		saved_units.append(units[i].basicSave())
	var saved_cells:Array
	for i in cells.size():
		saved_cells.append(cells[i].save())
	var data = {
		"Units" : saved_units,
		"Cells" : saved_cells
	}
	var dir = Directory.new()
	if !dir.dir_exists(PlayerVars.MAP_SAVE_DIR):
		dir.make_dir_recursive(PlayerVars.MAP_SAVE_DIR)
	
	var file:File = File.new()
	var error = file.open_encrypted_with_pass(path, File.WRITE, "09polkmn")
	if error == OK:
		file.store_var(data)
		file.close()
	file.call_deferred("queue_free")
	dir.call_deferred("queue_free")
		#var not_saved:bool = false

func load_map(map:String):
	clear_map()
	battle_controller.clearAll()
	var map_data = MapLoader.loadSingleMapFile(map)
	var unit_data = map_data.get("Units")
	var cell_data = map_data.get("Cells")
	for i in cell_data.size():
		var x = cell_data[i].get("x")
		var z = cell_data[i].get("z")
		var height = cell_data[i].get("height")
		var surface = cell_data[i].get("surface")
		var cell = createCell(x,z,height,surface)
	for i in cells.size():
		setCellNeighbors(cells[i])
		cells[i].updateHeight(cells[i].cell_height)
	for i in unit_data.size():
		loadUnit(unit_data[i])
	clear = false
	emit_signal("map_loaded")

func clear_map():
	lastHighlighted = null
	lastHighlightedUnit = null
	lastClickedCell = null
	lastSelectedUnit = null
	#var saved_units:Array
	for i in units.size():
		units[i].clear()
		remove_child(units[i])
		units[i].free()
	units.clear()
	#var saved_cells:Array
	for i in cells.size():
		cells[i].clear()
		remove_child(cells[i])
		cells[i].free()
	cells.clear()
	camera_rig.unfocusTarget()
	clear = true


func _on_PlayButton_pressed():
	$"../EditButton".visible = false
	if initializePartyArray().size() > 1:
		startMatch()
#		var spin:SpinBox = SpinBox.new()
#		spin.min_value = 0
#		spin.max_value = initializePartyArray().size() - 1
#		window_dialog.add_child(spin)
#		window_dialog.popup_centered()
#		window_dialog.window_title = "Select which party to play as."
#		window_dialog.connect("confirmed",self,"startMatch",[spin])
#		window_dialog.connect("popup_hide",self,"closePopup",[spin])
#	else:
#		window_dialog.popup_centered()
#		window_dialog.dialog_text = "Not enough parties (" + str(initializePartyArray().size()) + "), 2 parties are required."

func startMatch() -> void:
#	window_dialog.remove_child(spin)
	edit_mode_label.text = "Play Mode"
	edit_menu.visible = false
	play_button.visible = false
	edit_menu.playMode()
#	battle_controller.clearAll()
	battle_controller.grid = self
#	battle_controller.setParties(initializePartyArray(),0) # Set the parties for the battle controller (party 0 is human player)
	battle_controller.setUnitList(units,0) # New way of setting up list, unit initiative is mixed
#	for i in units.size():
#		units[i].free()
#	units.clear()

func closePopup(spin) -> void:
	window_dialog.remove_child(spin)
	spin.call_deffered("queue_free")

# Group all units into their respective parties to be added the the battle controller's turn queue
func initializePartyArray() -> Array:
	var parties:Array = [[],[]]
	for i in units.size():
		for j in range(2):
			if int(units[i].player_owned) == j:
				parties[j].append(units[i])
	for empty in range(parties.size() - 1, -1, -1):
		if parties[empty].size() == 0:
			parties.remove(empty)
	return parties

func _init():
	GameUtils.connect("freeing_orphans", self, "_free_if_orphaned")

func _free_if_orphaned():
	if not is_inside_tree(): # Optional check - don't free if in the scene tree
		queue_free()
