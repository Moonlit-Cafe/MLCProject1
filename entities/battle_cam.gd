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
@onready var camera : Camera3D = $SpringArm3D/Camera3D
@onready var timer : Timer = $Timer

var rot_dir := Vector2.ZERO
var mov_dir : float = 0.
var can_swivel : bool = true :
	set(value):
		if not value:
			timer.start(timer_delay)
		can_swivel = value
var available_positions : Dictionary[int, Vector3] = {}
var current_position : int = 0
var timeline : Timeline
var focus_tile : BattleTile
var enemy_target_count = 0
#endregion

#region Events
func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	
	if get_tree().get_node_count_in_group(&"player") > 0:
		focus_tile = get_tree().get_first_node_in_group(&"player").tile
		global_position = focus_tile.global_position
	
	var start_position := Vector3.ZERO
	if focus_tile:
		start_position = focus_tile.global_position
	else:
		_get_start_position()
	
	position = start_position
	_generate_positions()
	spring_arm.rotation_degrees.x = -45
	spring_arm.spring_length = 5
	x_rotation_range = Vector2(-deg_to_rad(x_rotation_range.x), -deg_to_rad(x_rotation_range.y))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_handle_mouse_motion(event)
	
	if event.is_action_pressed(&"rotate_cam"):
		var next_position : int = current_position
		# HACK de-hard code controls later
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
		focus_tile = get_tree().get_first_node_in_group(&"player").tile
		_pan_camera(focus_tile.global_position)
	
	if event.is_action_pressed(&"cycle"):
		var enemies = get_tree().get_nodes_in_group(&"enemy")
		
		if Input.is_key_pressed(KEY_SHIFT):
			enemy_target_count = enemies.size() - 1
		
		if focus_tile in enemies:
			enemy_target_count = enemies.find(focus_tile)
			if Input.is_key_pressed(KEY_SHIFT):
				enemy_target_count -= 1
			else:
				enemy_target_count += 1
			
			if enemy_target_count == enemies.size():
				enemy_target_count = 0
			elif enemy_target_count == -1:
				enemy_target_count = enemies.size() - 1
		
		focus_tile = enemies.get(enemy_target_count).get_parent()
		_pan_camera(focus_tile.global_position)
	
	if not event is InputEventMouseButton:
		return
	
	_handle_mouse_clicks(event)

func _process(delta: float) -> void:
	_cam_movement(delta)
	_player_pan()

func _player_pan():
	# HACK this should be in a config somewhere
	var pan_speed = 2
	var pan_diff : Vector3  = Vector3.ZERO
	if Input.is_action_pressed("menu_up"):
		pan_diff.z -= pan_speed
	if Input.is_action_pressed("menu_down"):
		pan_diff.z += pan_speed
	if Input.is_action_pressed("menu_left"):
		pan_diff.x -= pan_speed
	if Input.is_action_pressed("menu_right"):
		pan_diff.x += pan_speed
	
	if pan_diff != Vector3.ZERO:
		pan_diff = pan_diff.rotated(Vector3.UP, self.rotation.y)
		_pan_camera(pan_diff + self.global_position) 
		# HACK currently this works, but doesnt allow for "smooth panning" when a direction is held. Probably due to tweening in _pan_camera()
		

func _get_start_position() -> Vector3:
	var map_size : Vector2i = timeline.zone_data.map_size
	var height : Curve = timeline.zone_data.height_range
	var height_min : float = height.get_point_position(0).y
	var height_max : float = height.get_point_position(height.point_count - 1).y
	var height_mid : float = (height_min + height_max) / 2.
	return Vector3(map_size.x / 2., height_mid, map_size.y / 2.)

func _generate_positions() -> void:
	var factor : float = 2. / position_count
	for i in range(position_count):
		available_positions.set(i, Vector3(0., PI * factor * i, 0.))

func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	if event.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
		position -= (Vector3(event.relative.x, 0, event.relative.y) / 100).rotated(Vector3.UP, rotation.y)

func _handle_mouse_clicks(_event: InputEventMouseButton) -> void:
	if Input.is_action_pressed(&"zoom_in"):
		camera.size -= linear_zoom_speed * get_physics_process_delta_time()
	elif Input.is_action_pressed(&"zoom_out"):
		camera.size += linear_zoom_speed * get_physics_process_delta_time()
	
	if camera.size < linear_zoom_limits.x:
		camera.size = linear_zoom_limits.x
	elif camera.size > linear_zoom_limits.y:
		camera.size = linear_zoom_limits.y

func _rotate_camera_y(next_position: int) -> void:
	# FIXME when camera is negative (outside of 0-179), it flips around every rotation
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

func _cam_movement(delta: float) -> void:
	if rot_dir.y != 0:
		print(spring_arm.rotation)
		if spring_arm.rotation.x > x_rotation_range.x:
			spring_arm.rotation.x = x_rotation_range.x
		elif spring_arm.rotation.x < x_rotation_range.y:
			spring_arm.rotation.x = x_rotation_range.y
		spring_arm.rotate_x(x_angular_speed * delta * rot_dir.y)
#endregion

#region Signal Callbacks
func _on_timer_timeout() -> void:
	can_swivel = true
#endregion
#func _tile_hover(tile: BattleTile = MouseHandler.hovered_tile) -> void:
#	if MouseHandler.hovered_tile != tile and MouseHandler.hovered_tile:
#		MouseHandler.hovered_tile.highlighted = false
#	
#	# PLANNED This will have to be split for hovering over keywords and stats
#	if _hover_timer:
#		collapse_hover.emit()
#		_hover_timer.stop()
#		_hover_timer.free()
#		
#	_hover_timer = Timer.new()
#	_hover_timer.one_shot = true
#	_hover_timer.connect("timeout", hover_tile.emit)
#	add_child(_hover_timer)
#	_hover_timer.start(0.5)
#	
#	for p_tile in battle_map.board.values():
#		if p_tile.highlighted:
#			p_tile.highlighted = false
#	
#	MouseHandler.hovered_tile = tile
#	tile.highlighted = true
#	if CombatManager.selected_action != null:
#		var tile_pos := Vector2i(tile.tile_position.x, tile.tile_position.z)
#		for pos in CombatManager.selected_action.shape.shape_pos_arr:
#			var adj_tile : BattleTile = battle_map.board.get(tile_pos + pos)
#			if adj_tile:
#				adj_tile.highlighted = true
#
#func _raycast_tile() -> BattleTile:
#	var space_state := camera.get_world_3d().direct_space_state
#	var query := PhysicsRayQueryParameters3D.new()
#	query.collide_with_areas = true
#	query.collide_with_bodies = false
#	query.collision_mask = 0x0002 # Layer 2
#	
#	var mouse_pos := get_viewport().get_mouse_position()
#	var from := camera.project_ray_origin(mouse_pos)
#	var to := from + camera.project_ray_normal(mouse_pos) * ray_length
#	query.from = from
#	query.to = to
#	
#	var result : Dictionary = space_state.intersect_ray(query)
#	if result.has("collider"):
#		var collider : Area3D = result.get("collider")
#		var tile : BattleTile = collider.get_parent()
#		return tile
#	return null
#
#func _tile_selection() -> void:
#	var tile = _raycast_tile()
#	if not player_turn:
#		return
#	
#	if tile == null:
#		return
#	
#	print("Selecting %s" % tile)
#	MouseHandler.selected_tile = tile
#	
#	if CombatManager.moving:
#		if not tile.selectable:
#			print("Tile not selectable!")
#			return
#		
#		battle_map.determine_selectables()
#		tile.attach_entity(PlayerManager.occupied_tile.held_entity)
#		PlayerManager.occupied_tile = tile
#		
#		CombatManager.player_turn = false
#		GameGlobal.events.player_turn.emit()
#		_pan_camera(PlayerManager.entity_ref.global_position)
#		CombatManager.use_action.emit()
#	
#		#temp.clear_object()
#		
#	if tile == MouseHandler.selected_tile and tile and tile.selectable:
#		if CombatManager.selected_action:
#			CombatManager.attack_tile.emit()
#		return
