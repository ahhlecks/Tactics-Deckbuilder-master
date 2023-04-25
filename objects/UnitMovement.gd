extends Node

signal moved_cell
signal completed
signal turned

var custom_theme = preload("res://resources/themes/custom/new_theme2.tres")
var NinePatchPrefab = preload("res://objects/UI/NinePatchRect.tscn")

var play:bool = false
var time:float = 0
var move_time:float = .65
var completion:float
var play_back_speed:float = 1.0
var path:Array = []
var current_path:int
var old_rotation:Vector3
var new_rotation:Vector3
var facing:String
var editMode:bool = false
var jump:bool = false
var is_push:bool = false

var straightPaths:Dictionary = {
	"E" : Vector2(-11, 0),
	"SE" : Vector2(-6, -9),
	"SW" : Vector2(5, -9),
	"W" : Vector2(10, 0),
	"NW" : Vector2(5, 9),
	"NE" : Vector2(-6, 9),
}

onready var unit:HexUnit = get_parent()
onready var smooth_step_curve:Curve = preload("res://resources/effects/smooth_step_curve.tres")
onready var linear_curve:Curve = preload("res://resources/effects/linear_curve.tres")
onready var jump_curve:Curve = preload("res://resources/effects/jump_curve.tres")
onready var fall_curve:Curve = preload("res://resources/effects/fall_curve.tres")
onready var start_curve:Curve = preload("res://resources/effects/start_curve.tres")
onready var end_curve:Curve = preload("res://resources/effects/end_curve.tres")

#onready var ray:RayCast = $RayCast


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if play:
		if !is_push:
			get_parent().rotation = lerp(get_parent().rotation, new_rotation, delta * 10)
		time += delta
		completion = (time / move_time) * play_back_speed
		if completion != 0:
			

#			else:
			play_back_speed = 1
			if current_path == 0: # start
				if path.size() == 2:
					unit.translation.x = path[current_path].x + (smooth_step_curve.interpolate(completion) * (path[current_path+1].x - path[current_path].x))
					unit.translation.z = path[current_path].z + (smooth_step_curve.interpolate(completion) * (path[current_path+1].z - path[current_path].z))
				else:
					unit.translation.x = path[current_path].x + (start_curve.interpolate(completion) * (path[current_path+1].x - path[current_path].x))
					unit.translation.z = path[current_path].z + (start_curve.interpolate(completion) * (path[current_path+1].z - path[current_path].z))
			elif current_path == path.size() - 2: # end
				unit.translation.x = path[current_path].x + (end_curve.interpolate(completion) * (path[current_path+1].x - path[current_path].x))
				unit.translation.z = path[current_path].z + (end_curve.interpolate(completion) * (path[current_path+1].z - path[current_path].z))
			else:
				unit.translation.x = path[current_path].x + (completion * (path[current_path+1].x - path[current_path].x))
				unit.translation.z = path[current_path].z + (completion * (path[current_path+1].z - path[current_path].z))

			if path[current_path].y < path[current_path+1].y:
				doJumpAnimation(path[current_path].y - path[current_path+1].y)
				unit.translation.y = path[current_path].y + (jump_curve.interpolate(completion) * (path[current_path+1].y - path[current_path].y))
			else:
				doJumpAnimation(path[current_path].y - path[current_path+1].y)
				unit.translation.y = path[current_path].y + (fall_curve.interpolate(completion) * (path[current_path+1].y - path[current_path].y))

			if completion > 1:
				emit_signal("moved_cell")
				current_path += 1
				if current_path != path.size() -1:
					checkFacing()
				time = 0

		if current_path == path.size() -1:
			play = false
			unit.translation = path.back()
			if !get_parent().is_ai_controlled:
				var move_prompt = NinePatchPrefab.instance()
				move_prompt.centered = true
				add_child(move_prompt)
				move_prompt.setup("Move Here?")
				move_prompt.setupOptions("Accept","Decline",self,self,"validateMove","moveBack")
			else:
				validateMove()


func move(pathLocation:Array) -> void:
	is_push = false
	editMode = false
	path = pathLocation
	current_path = 0
	time = 0
	get_parent().grid.camera_rig.current_target = get_parent()
	unit.unit_owner.get_parent().battle_gui.actions.visible = false
	old_rotation = unit.rotation
	checkFacing()
	play = true

func push(pathLocation:Array) -> void: #getting pushed
	is_push = true
	editMode = false
	path = pathLocation
	current_path = 0
	time = 0
	#get_parent().grid.camera_rig.current_target = get_parent()
	#unit.unit_owner.get_parent().battle_gui.actions.visible = false
	#old_rotation = unit.rotation
	#checkFacing()
	play = true

func editMove(pathLocation:Array) -> void:
	is_push = false
	editMode = true
	path = pathLocation
	current_path = 0
	time = 0
	get_parent().grid.camera_rig.current_target = get_parent()
	old_rotation = unit.rotation
	checkFacing()
	play = true


func checkFacing():
	var space_state = get_parent().grid.get_world().get_direct_space_state()
	var from = path[current_path] + Vector3(0,1,0)
	var to = path[current_path+1] + Vector3(0,1,0)
	var result = space_state.intersect_ray(from, to)
	var rotation:Vector3 = get_parent().rotation
	new_rotation = get_parent().rotation
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
		new_rotation += Vector3(0,deg2rad(rotation_amount), 0)

func quadratic_bezier(a:Vector2, b:Vector2, c:Vector2, t:float) -> Vector2:
	var r:float = 1.0 - t
	return r * r * a + 2.0 * r * t * b + t * t * c

func getAngle(a:Vector2, b:Vector2, c:Vector2, t:float) -> float:
	return (2 * ((1 - t) * (b - a) + t * (c - b))).angle()

func isStraightPath(p0,p2) -> bool:
	var straight_path:Vector2 = p0 - p2
	for i in straightPaths.values():
		if i.x == floor(straight_path.x) and i.y == floor(straight_path.y):
			return true
	return false

func moveBack() -> void:
	get_parent().get_node("Character_Mesh").get_node("AnimationPlayer").play("Idle")
	unit.rotation = old_rotation
	unit.translation = path[0]
	unit.isSelectable = true
	current_path = 0
	time = 0
	unit.highlightMove()
	if !editMode:
		if get_parent().player_owned:
			if !get_parent().is_ai_controlled:
				unit.unit_owner.get_parent().battle_gui.actions.visible = true
	unit.grid.camera_rig.current_target = unit

func validateMove() -> void:
	if unit.rotation_degrees.y > -1 and unit.rotation_degrees.y < 1:
		facing = "E"
	if unit.rotation_degrees.y > 59 and unit.rotation_degrees.y < 61:
		facing = "NE"
	if unit.rotation_degrees.y > 119 and unit.rotation_degrees.y < 121:
		facing = "NW"
	if unit.rotation_degrees.y < -179 or unit.rotation_degrees.y > 179:
		facing = "W"
	if unit.rotation_degrees.y > -121 and unit.rotation_degrees.y < -119:
		facing = "SW"
	if unit.rotation_degrees.y > -61 and unit.rotation_degrees.y < -59:
		facing = "SE"
	unit.old_facing = facing
	if !editMode:
		unit.current_movement_points -= path.size()-1
		if get_parent().player_owned:
			if !get_parent().is_ai_controlled:
				unit.unit_owner.get_parent().battle_gui.actions.visible = true
				unit.unit_owner.get_parent().battle_gui.actionPopout()
	old_rotation = unit.rotation
	if !is_push:
		unit.grid.camera_rig.current_target = unit
	if get_parent().unit_owner != null:
		var startHex:Vector2 = HexUtils.pixelToHex(Vector2(path[0].x,-path[0].z),get_parent().unit_owner.get_parent().grid.cell_size)
		var endHex:Vector2 = HexUtils.pixelToHex(Vector2(path[current_path].x,-path[current_path].z),get_parent().unit_owner.get_parent().grid.cell_size)
		get_parent().unit_owner.get_parent().emit_signal("unit_moved",
			get_parent(),
			get_parent().unit_owner,
			get_parent().unit_owner.get_parent().grid.findHex(startHex),
			get_parent().unit_owner.get_parent().grid.findHex(endHex))
	path.clear()
	emit_signal("completed")

func doJumpAnimation(yDiff:float) -> void:
	if !jump and (yDiff >= 1.4 or yDiff <= -1.4):
		jump = true
		if !(yDiff >= 2.24 or yDiff <= -2.24):
			get_parent().get_node("Character_Mesh").get_node("AnimationPlayer").play("JumpQuick")
		else:
			get_parent().get_node("Character_Mesh").get_node("AnimationPlayer").play("Jump")
		yield(get_parent().get_node("Character_Mesh").get_node("AnimationPlayer"),"animation_finished")
		jump = false
		if completion < 1:
			get_parent().get_node("Character_Mesh").get_node("AnimationPlayer").play("Walk")
