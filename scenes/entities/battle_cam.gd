class_name BattleCam extends Node3D

#region Declarations
@export_range(1., 16., 1.) var position_count : int = 8
@export var x_rotation_range := Vector2(30, 70)
@export var x_angular_speed : float = PI / 8.
@export var linear_move_speed : float = 20.
@export var linear_zoom_speed : float = 16.
@export var linear_zoom_limits := Vector2(2, 16)
@export var timer_delay : float = 0.2

@onready var spring_arm : SpringArm3D = $SpringArm3D
@onready var camera : Camera3D = $SpringArm3D/BattleCam
@onready var timer : Timer = $Timer

var rot_dir := Vector2.ZERO
var mov_dir : float = 0.
var can_swivel : bool = true:
	set(value):
		if not value:
			timer.start(timer_delay)
		
		can_swivel = value
var available_positions : Dictionary[int, Vector3] = {}
var current_position : int = 0
#endregion

#region Events
func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)

func _input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	
	if Input.is_action_pressed(&"zoom_in"):
		camera.size -= linear_zoom_speed * get_physics_process_delta_time()
	elif Input.is_action_pressed("zoom_out"):
		camera.size += linear_zoom_speed * get_physics_process_delta_time()
	
	if camera.size < linear_zoom_limits.x:
		camera.size = linear_zoom_limits.x
	elif camera.size > linear_zoom_limits.y:
		camera.size = linear_zoom_limits.y

func init(center: Vector3) -> void:
	position = center
	_generate_positions()
	spring_arm.rotation_degrees.x = -45
	x_rotation_range = Vector2(-deg_to_rad(x_rotation_range.x), -deg_to_rad(x_rotation_range.y))
#endregion

#region Processes
func _process(delta: float) -> void:
	_cam_input()
	_cam_movement(delta)

func _cam_input() -> void:
	rot_dir = Input.get_vector(&"cam_left", &"cam_right", &"cam_down", &"cam_up")
	mov_dir = Input.get_axis(&"cam_backward", &"cam_forward")

func _cam_movement(delta: float) -> void:
	if rot_dir.x != 0 and can_swivel:
		var next_position : int = current_position + rot_dir.x
		if next_position >= available_positions.size():
			next_position = 0
		elif next_position < 0:
			next_position = available_positions.size() - 1
		
		_rotate_camera_y(next_position)
		
		current_position = next_position
		can_swivel = false
	
	if rot_dir.y != 0:
		print(spring_arm.rotation)
		if spring_arm.rotation.x > x_rotation_range.x:
			spring_arm.rotation.x = x_rotation_range.x
		elif spring_arm.rotation.x < x_rotation_range.y:
			spring_arm.rotation.x = x_rotation_range.y
		spring_arm.rotate_x(x_angular_speed * delta * rot_dir.y)
	

func _generate_positions() -> void:
	var factor : float = 2. / position_count
	for i in range(position_count):
		available_positions.set(i, Vector3(0., PI * factor * i, 0.))

func _rotate_camera_y(next_position: int) -> void:
	var tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_CIRC).set_loops(1)
	var dir : Vector3 = available_positions.get(next_position)
	if current_position == 0 and next_position == available_positions.size() - 1:
		rotation = available_positions.get(next_position) + available_positions.get(1)
		tween.tween_property(self, "rotation", dir, timer_delay)
		return
	elif current_position == available_positions.size() - 1 and next_position == 0:
		rotation = available_positions.get(next_position) - available_positions.get(1)
		tween.tween_property(self, "rotation", dir, timer_delay)
		return
	tween.tween_property(self, "rotation", dir, timer_delay)
#endregion

#region Signal Callbacks
func _on_timer_timeout() -> void:
	can_swivel = true
#endregion
