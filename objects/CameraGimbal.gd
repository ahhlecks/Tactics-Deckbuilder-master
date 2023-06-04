extends Spatial

export (NodePath) var target

export (int) var rotation_speed = 2
export (float, 0.0, 1.0) var ACCELERATION:float = .04
export (float, 0.0, 1.0) var DEACCELERATION:float = .04
export (int) var movement_speed = 10

export (bool) var lock_y_axis = true
export (bool) var invert_y = false
export (bool) var invert_x = false
export (float) var mouse_sensitivity = 0.005
export (bool) var right_click_rotation = true

# zoom settings
export (float) var max_zoom = 3.0
export (float) var min_zoom = 0.4
export (float, 0.05, 1.0) var zoom_speed = 0.09

var current_speed = Vector3()
onready var camera = $InnerGimbal/Camera
onready var tween = $InnerGimbal/Tween

var dir = Vector3()
var hv:Vector3
var new_pos:Vector3
var accel:float
onready var saved_angle:float = $InnerGimbal.rotation.x

var moved_right_mouse_x:bool = false
var moved_right_mouse_y:bool = false

var overview_distance = 14
var focus_distance = 6
var overview_angle = deg2rad(-60)
var zoomed_angle = deg2rad(-60)
var zoom = 70
export (float) var zoom_level = 1.4

func _ready():
	$InnerGimbal.rotation.x = overview_angle

func _process(delta):
	rotation_keyboard()
	smooth_translate(delta)
	$InnerGimbal.rotation.x = clamp($InnerGimbal.rotation.x, deg2rad(-90), deg2rad(-15))
	if target:
		global_transform.origin = get_node(target).global_transform.origin

func _unhandled_input(event):
	if Input.is_action_pressed("shift_key"):
		lock_y_axis = false
	else:
		lock_y_axis = true
	if right_click_rotation:
		if Input.is_action_pressed("mouse_right"):
			if event is InputEventMouseMotion:
				if event.relative.x != 0:
					moved_right_mouse_y = true
					event.relative.x = -event.relative.x if invert_x else event.relative.x
					rotate_object_local(Vector3.UP, event.relative.x * mouse_sensitivity)
				if event.relative.y != 0:
					moved_right_mouse_x = true
					event.relative.y = -event.relative.y if invert_y else event.relative.y
					$InnerGimbal.rotate_object_local(Vector3.RIGHT, event.relative.y * mouse_sensitivity)
	else:
		if Input.is_action_pressed("mouse_left"):
			if event is InputEventMouseMotion:
				if event.relative.x != 0:
					event.relative.x = -event.relative.x if invert_x else event.relative.x
					rotate_object_local(Vector3.UP, event.relative.x * mouse_sensitivity)
				if event.relative.y != 0:
					event.relative.y = -event.relative.y if invert_y else event.relative.y
					$InnerGimbal.rotate_object_local(Vector3.RIGHT, event.relative.y * mouse_sensitivity)

func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_WHEEL_UP:
			zoom -= zoom_speed
		if event.button_index == BUTTON_WHEEL_DOWN:
			zoom += zoom_speed
	zoom = clamp(zoom, min_zoom, max_zoom)
	scale = Vector3.ONE * zoom

func rotation_keyboard():
	# Rotate outer gimbal around y axis
	var y_rotation = 0
	var is_snapped_y:int = (int(ceil(rotation_degrees.y)) % 30)
	if Input.is_action_just_pressed("cam_right"):
		if moved_right_mouse_y:
			if is_snapped_y < 0:
				y_rotation += deg2rad(is_snapped_y)
			elif is_snapped_y > 0:
				y_rotation += deg2rad(is_snapped_y)
				y_rotation -= deg2rad(30)
		y_rotation += deg2rad(30)
		moved_right_mouse_y = false
	if Input.is_action_just_pressed("cam_left"):
		if moved_right_mouse_y:
			if is_snapped_y < 0:
				y_rotation += deg2rad(is_snapped_y)
				y_rotation += deg2rad(30)
			elif is_snapped_y > 0:
				y_rotation += deg2rad(is_snapped_y)
		y_rotation -= deg2rad(30)
		moved_right_mouse_y = false
	y_rotation = -y_rotation if invert_x else y_rotation
	rotate_object_local(Vector3.UP, y_rotation)
	# Rotate inner gimbal around local x axis
	var x_rotation = 0
	var is_snapped_x:int = (int(abs(ceil($InnerGimbal.rotation_degrees.x))) % 15)
	var snap_difference_x:int = is_snapped_x
	if Input.is_action_just_pressed("cam_up"):
		if moved_right_mouse_x:
			if snap_difference_x > 0:
				x_rotation -= deg2rad(snap_difference_x)
			else:
				x_rotation -= deg2rad(snap_difference_x)
		x_rotation += deg2rad(-15)
		moved_right_mouse_x = false
	if Input.is_action_just_pressed("cam_down"):
		if moved_right_mouse_x:
			if snap_difference_x > 0:
				x_rotation -= deg2rad(snap_difference_x)
			else:
				x_rotation -= deg2rad(snap_difference_x)
		x_rotation += deg2rad(15)
		moved_right_mouse_x = false
	x_rotation = -x_rotation if invert_y else x_rotation
	$InnerGimbal.rotate_object_local(Vector3.RIGHT, x_rotation)

func smooth_translate(delta):
	# Translate Camera Controls
	if(Input.is_action_pressed("move_fw")):
		dir.z += -$InnerGimbal.transform.basis.z.length()
		dir.y += -$InnerGimbal.transform.basis.x.length()
	if(Input.is_action_just_released("move_fw")):
		dir.z = 0
		dir.y = 0
	if(Input.is_action_pressed("move_bw")):
		dir.z += $InnerGimbal.transform.basis.z.length()
		dir.y += $InnerGimbal.transform.basis.x.length()
	if(Input.is_action_just_released("move_bw")):
		dir.z = 0
		dir.y = 0
	if(Input.is_action_pressed("move_l")):
		dir.x += -$InnerGimbal.transform.basis.x.length()
	if(Input.is_action_just_released("move_l")):
		dir.x = 0
	if(Input.is_action_pressed("move_r")):
		dir.x += $InnerGimbal.transform.basis.x.length()
	if(Input.is_action_just_released("move_r")):
		dir.x = 0
	# Smoothing expressions
	if lock_y_axis:
		dir.y = 0
	dir = dir.normalized()
	hv = current_speed
	if lock_y_axis:
		hv.y = 0
	new_pos = dir * movement_speed
	accel = DEACCELERATION
	if (dir.dot(hv) > 0):
		accel = ACCELERATION
	current_speed = lerp(current_speed, new_pos, accel)
	translate(new_pos * delta)

func moveTo(target:Spatial) -> void:
	$InnerGimbal.rotation.x = zoomed_angle
#	printt("Original:",translation)
	translation.x = target.translation.x
	translation.z = target.translation.z
	translation.y = target.translation.y
#	printt("Target:",translation)
#	dir.z += $InnerGimbal.transform.basis.z.length()
#	dir.y += -$InnerGimbal.rotation.x
#	printt("Difference:", dir)
#	translate(dir)
#	dir.z = 0
#	dir.y = 0
#	printt("Result:",translation)
#	printt("-------------------")

func unfocusTarget(target:Spatial) -> void:
	$InnerGimbal.rotation.x = zoomed_angle
	translation.x = target.translation.x
	translation.z = target.translation.z
	translation.y = target.translation.y
	var trig = cos(abs($InnerGimbal.rotation.x)) * overview_distance
	var trig2 = sin(abs($InnerGimbal.rotation.x)) * overview_distance
	var result = trig
	var result2 = trig2
	translate(Vector3(0,result2,result))
