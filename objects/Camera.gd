extends Camera

export (NodePath) var target
onready var target_node = get_node(target)

var enabled:bool = true

export (float) var speed:float = 5.0

var move_delta
var target_transform

func _ready():
	make_current()


func _process(delta):
	if not enabled or not target_node:
		return
	move_delta = speed * delta
	target_transform = target_node.global_transform
	global_transform = global_transform.interpolate_with(target_transform, move_delta)
	if target_node is Camera and target_node.projection == projection:
		var new_near = lerp(near, target_node.near, move_delta)
		var new_far = lerp(far, target_node.far, move_delta)
		
		#if target_node.projection == PROJECTION_ORTHOGONAL:
		#	set_orthogonal(lerp(size, target_node.size, move_delta), new_near, new_far)
		#else:
		#	set_perspective(lerp(fov, target_node.fov, move_delta), new_near, new_far)
