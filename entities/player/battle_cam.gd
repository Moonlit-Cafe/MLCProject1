class_name BattleCam extends Node3D

#region Declarations
@export_range(1., 16., 1.) var position_count : int = 8
@export var x_rotation_range := Vector2(30, 70)
@export var x_angular_speed : float = PI / 8.
@export var linear_move_speed : float = 5.
@export var linear_zoom_speed : float = 16.
@export var linear_zoom_limits := Vector2(2, 16)
@export var timer_delay : float = 0.2
@export var ray_length : float = 50.
@export var bounds : Rect2

@onready var spring_arm : SpringArm3D = $SpringArm3D
@onready var camera : Camera3D = $SpringArm3D/BattleCam
@onready var timer : Timer = $Timer

var rot_dir := Vector2.ZERO
var mov_dir : float = 0.
var player_turn : bool = false
var can_swivel : bool = true:
	set(value):
		if not value:
			timer.start(timer_delay)
		
		can_swivel = value
var available_positions : Dictionary[int, Vector3] = {}
var current_position : int = 0
var battle_board : BattleMap3D
var focus_target : TileEntity
#endregion

#region Events
func _ready() -> void:
	CombatManager.rehover.connect(_tile_hover)
	
	timer.timeout.connect(_on_timer_timeout)
	battle_board = get_parent()
	
	if get_tree().get_node_count_in_group(&"player") > 0:
		focus_target = get_tree().get_first_node_in_group(&"player")
		global_position = focus_target.global_position
		

func _input(event: InputEvent) -> void:
	# PLANNED: Come back to this later on to adapt to gamepad if we wanna add that.
	if event is InputEventMouseMotion:
		_handle_mouse_motion(event)
	
	if event.is_action_pressed(&"rotate_cam"):
		var next_position : int = current_position
		if Input.is_key_pressed(KEY_SHIFT):
			next_position -= 1
		else:
			next_position += 1
		
		if next_position >= available_positions.size():
			next_position = 0
		elif next_position < 0:
			next_position = available_positions.size() - 1
		
		_rotate_camera_y(next_position)
		
		current_position = next_position
		can_swivel = false
	
	if event.is_action_pressed(&"focus_player"):
		focus_target = get_tree().get_first_node_in_group(&"player")
		_pan_camera(focus_target.global_position)
	
	if event.is_action_pressed(&"cycle"):
		var enemies = get_tree().get_nodes_in_group(&"enemy")
		var i : int = 0
		if Input.is_key_pressed(KEY_SHIFT):
			i = enemies.size() - 1
		
		if focus_target in enemies:
			i = enemies.find(focus_target)
			if Input.is_key_pressed(KEY_SHIFT):
				i -= 1
			else:
				i += 1
			
			if i == enemies.size():
				i = 0
			elif i == -1:
				i = enemies.size() - 1
		
		focus_target = enemies.get(i)
		_pan_camera(focus_target.global_position)
	
	if not event is InputEventMouseButton:
		return
	
	_handle_mouse_clicks(event)

func init(center: Vector3) -> void:
	position = center
	_generate_positions()
	spring_arm.rotation_degrees.x = -45
	x_rotation_range = Vector2(-deg_to_rad(x_rotation_range.x), -deg_to_rad(x_rotation_range.y))

func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	if event.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
		position -= (Vector3(event.relative.x, 0, event.relative.y) / 100).rotated(Vector3.UP, rotation.y)
	
	var tile = _raycast_tile()
	
	if not tile:
		return
	
	if not tile.selectable:
		return
	
	_tile_hover(tile)

func _tile_hover(tile: BattleTile = MouseHandler.hovered_tile) -> void:
	if MouseHandler.selected_tile != null:
		return
	
	if MouseHandler.hovered_tile != tile and MouseHandler.hovered_tile != null:
		MouseHandler.hovered_tile.highlighted = false
	
	for p_tile in battle_board.board.values():
		if p_tile.highlighted:
			p_tile.highlighted = false
	
	MouseHandler.hovered_tile = tile
	tile.highlighted = true
	if CombatManager.selected_action != null:
		var tile_pos := Vector2i(tile.tile_position.x, tile.tile_position.z)
		for pos in CombatManager.selected_action.shape.shape_pos_arr:
			var adj_tile : BattleTile = battle_board.board.get(tile_pos + pos)
			if adj_tile:
				adj_tile.highlighted = true

func _handle_mouse_clicks(event: InputEventMouseButton) -> void:
	if event.is_action_pressed(&"tile_select"):
		_tile_selection()
	
	# Zoom Behavior
	if Input.is_action_pressed(&"zoom_in"):
		camera.size -= linear_zoom_speed * get_physics_process_delta_time()
	elif Input.is_action_pressed("zoom_out"):
		camera.size += linear_zoom_speed * get_physics_process_delta_time()
	
	if camera.size < linear_zoom_limits.x:
		camera.size = linear_zoom_limits.x
	elif camera.size > linear_zoom_limits.y:
		camera.size = linear_zoom_limits.y

func _raycast_tile() -> BattleTile:
	var space_state := camera.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.new()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = 0x0002 # Layer 2
	
	var mouse_pos := get_viewport().get_mouse_position()
	var from := camera.project_ray_origin(mouse_pos)
	var to := from + camera.project_ray_normal(mouse_pos) * ray_length
	query.from = from
	query.to = to
	
	var result : Dictionary = space_state.intersect_ray(query)
	if result.has("collider"):
		var collider : Area3D = result.get("collider")
		var tile : BattleTile = collider.get_parent()
		return tile
	return null

func _tile_selection() -> void:
	var tile = _raycast_tile()
	if not player_turn:
		return
	
	if tile == MouseHandler.selected_tile and tile != null:
		if CombatManager.selected_action:
			CombatManager.attack_tile.emit()
		return
	
	if tile != null:
		print("Selecting %s" % tile)
		MouseHandler.selected_tile = tile
	
	if CombatManager.moving and tile != null:
		if not tile.selectable:
			print("Tile not selectable!")
			return
		
		battle_board.determine_selectables()
		tile.attach_entity(PlayerManager.occupied_tile.held_entity)
		PlayerManager.occupied_tile = tile
		CombatManager.player_turn = false
		GameGlobalEvents.player_turn.emit()
		_pan_camera(PlayerManager.entity_ref.global_position)
		CombatManager.use_action.emit()
		

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

func _pan_camera(target_pos: Vector3) -> void:
	var tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_CUBIC).set_loops(1)
	tween.tween_property(self, "global_position", target_pos, 0.4)
#endregion

#region Processes
func _process(delta: float) -> void:
	_cam_movement(delta)

func _cam_movement(delta: float) -> void:
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
#endregion

#region Signal Callbacks
func _on_timer_timeout() -> void:
	can_swivel = true
#endregion
