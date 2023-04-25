extends Spatial

onready var camera = $Camera
export (float) var normal_speed:float = .15
export (float) var fast_speed:float = .3
onready var movement_speed:float = normal_speed
export (float) var movement_time:float = 4.0

export (int) var rotation_amount = 30

export (int) var zoom_amount = 1
export (int) var zoom_scroll_amount = 5
export (int) var min_zoom = 35
export (int) var normal_zoom = 55
export (int) var max_zoom = 85
var current_tilt:int = 45
export (int) var tilt_amount = 5
export (int) var min_tilt = 35
export (int) var max_tilt = 90
var unfocus:int = 2
var current_target:Spatial
var last_target:Spatial
#onready var ref_target = null

var new_position:Vector3
var new_rotation:Vector3
var new_zoom:int

var drag_start:Vector3
var drag_current:Vector3


# Called when the node enters the scene tree for the first time.
func _ready():
	new_position = translation
	new_rotation = rotation
	new_zoom = camera.translation.y


func _process(delta):
	handleMovement(delta)
	if current_target != null:
		focusTarget(current_target)
	setCameraHeight()

func handleMovement(delta):
#	if(Input.is_action_just_pressed("toggle_focus")):
#		toggleFocus()
	if(Input.is_action_pressed("shift_key")):
		movement_speed = fast_speed
	if(Input.is_action_just_released("shift_key")):
		movement_speed = normal_speed
	if current_target == null:
		if(Input.is_action_pressed("move_fw")):
			new_position -= transform.basis.z * movement_speed
		if(Input.is_action_pressed("move_bw")):
			new_position += transform.basis.z * movement_speed
		if(Input.is_action_pressed("move_l")):
			new_position -= transform.basis.x * movement_speed
		if(Input.is_action_pressed("move_r")):
			new_position += transform.basis.x * movement_speed
		new_position.y = 0
#	else:
#		if(Input.is_action_just_pressed("move_l")):
#			new_rotation -= Vector3(0,deg2rad(rotation_amount), 0)
#		if(Input.is_action_just_pressed("move_r")):
#			new_rotation += Vector3(0,deg2rad(rotation_amount), 0)
	
	if(Input.is_action_just_pressed("rotate_left")):
		new_rotation -= Vector3(0,deg2rad(rotation_amount), 0)
	if(Input.is_action_just_pressed("rotate_right")):
		new_rotation += Vector3(0,deg2rad(rotation_amount), 0)
	
	if(Input.is_action_pressed("cam_up") and new_zoom > min_zoom):
		new_zoom -= zoom_amount
	if(Input.is_action_pressed("cam_down") and new_zoom < max_zoom):
		new_zoom += zoom_amount
	
	if(Input.is_action_just_pressed("cam_tilt_up")):
		new_rotation.x = max(deg2rad(max_tilt),rotation.x - deg2rad(tilt_amount))
	if(Input.is_action_just_pressed("cam_tilt_down")):
		new_rotation.x = min(deg2rad(min_tilt),rotation.x + deg2rad(tilt_amount))
	
	translation = lerp(translation, new_position, delta * movement_time)
	rotation = lerp(rotation, new_rotation, delta * movement_time)
	camera.translation.y = lerp(camera.translation.y, new_zoom, delta * movement_time)

func _unhandled_input(event):
#	if event is InputEventMouseButton:
	if current_target == null:
		if Input.is_action_just_pressed("cam_pan") and event is InputEventMouse:
			var from:Vector3 = camera.project_ray_origin(event.position)
			var to = from + camera.project_ray_normal(event.position) * camera.far
			var space_state = get_world().get_direct_space_state()
			# use global coordinates, not local to node
			var result = space_state.intersect_ray( from, to )
			if result.has("position"):
				drag_start = result.get("position")
		if Input.is_action_pressed("cam_pan") and event is InputEventMouse:
			var from:Vector3 = camera.project_ray_origin(event.position)
			var to = from + camera.project_ray_normal(event.position) * camera.far
			var space_state = get_world().get_direct_space_state()
			# use global coordinates, not local to node
			var result = space_state.intersect_ray( from, to )
			if result.has("position"):
				drag_current = result.get("position")
				new_position.x = translation.x + (drag_start.x - drag_current.x)
				new_position.z = translation.z + (drag_start.z - drag_current.z)
		if Input.is_action_just_released("cam_pan") and event is InputEventMouse:
			drag_start = Vector3.ZERO
			drag_current = Vector3.ZERO
	
	if Input.is_action_just_pressed("cam_reset"):
		new_rotation.x = deg2rad(45)
		new_rotation.z = 0
		new_zoom = 55
	
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_WHEEL_UP and new_zoom > min_zoom:
			new_zoom -= zoom_scroll_amount
		if event.button_index == BUTTON_WHEEL_DOWN and new_zoom < max_zoom:
			new_zoom += zoom_scroll_amount

func focusTarget(target):
	new_position = target.translation + Vector3(0,1,0)

func unfocusTarget():
	new_position.y = unfocus
	last_target = current_target
	current_target = null

func toggleFocus():
	if current_target != null:
		unfocusTarget()
	elif last_target != null:
		current_target = last_target

func setCameraHeight() -> void:
	var center:Vector2 = Vector2(get_viewport().size.x/2,get_viewport().size.y/2)
	var from:Vector3 = camera.project_ray_origin(center)
	var to = from + camera.project_ray_normal(center) * camera.far
	var space_state = get_world().get_direct_space_state()
	var result = space_state.intersect_ray( from, to )
	if result.has("position"):
		unfocus = result.get("position").y
	else:
		unfocus = 2
