extends Camera3D

#region Declarations
@export var SPEED : float = 50.
@export var DISTANCE : float = 8.

var center_pos : Vector3
var rot := Vector2(PI / 4., PI / 4.)
var rot_speed : float = PI / 8.
var rot_dir := Vector2.ZERO
var mov_speed : float = 1.
var mov_dir : float = 0.
#endregion

#region Events
func _input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton):
		return

func init(center: Vector3) -> void:
	center_pos = center
	position = center + Vector3(0, DISTANCE, DISTANCE)
	swivel(rot.x)
	swivel(rot.y, false)

func swivel(theta: float, xz_plane: bool = true) -> void:
	if xz_plane:
		position.x = (DISTANCE * sin(theta)) + center_pos.x
		position.z = (DISTANCE * cos(theta)) + center_pos.z
		return
	
	position.y = (DISTANCE * cos(theta)) + center_pos.y
	look_at(center_pos)
#endregion

#region Processes
func _process(delta: float) -> void:
	_cam_input()
	_cam_movement(delta)

func _cam_input() -> void:
	rot_dir = Input.get_vector(&"cam_left", &"cam_right", &"cam_down", &"cam_up")
	mov_dir = Input.get_axis(&"cam_backward", &"cam_forward")

func _cam_movement(delta: float) -> void:
	if rot_dir.length() == 0 and mov_dir == 0:
		return
	
	if rot.x != 0:
		if rot.x > (2. * PI):
			rot.x = 0
		elif rot.x < 0:
			rot.x = (2. * PI)
		rot.x += rot_dir.x * rot_speed * delta
		swivel(rot.x)
	
	if rot.y != 0:
		if rot.y <= (PI / 6.):
			rot.y = PI / 6.
		elif rot.y >= (2. * PI / 6.):
			rot.y = ((2. * PI) / 6)
		rot.y += rot_dir.y * rot_speed * delta
		swivel(rot.y, false)
	
	if mov_dir == 0:
		return
	
	var dir := position.direction_to(center_pos)
	dir.y = 0
	center_pos += mov_dir * dir * mov_speed * delta
	swivel(rot.x)
	swivel(rot.y, false)
#endregion
