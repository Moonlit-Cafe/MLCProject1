## The actual battle system within the game, contained within a "Timeline" for the divergence feature.
class_name Timeline extends SubViewportContainer

#region Declarations
const battle_cam_scene : PackedScene = preload("res://entities/battle_cam.tscn")

var camera : BattleCam
var light : DirectionalLight3D
var left_timeline : Timeline = null
var map : GameTileMap
var right_timeline : Timeline = null
var state_machine : StateMachine
var sub_view : SubViewport
var zone_data : ZoneData

var is_focused : bool = true :
	get:
		return _is_focused
	set(value):
		if not value:
			process_mode = Node.PROCESS_MODE_DISABLED
			set_physics_process(false)
		else:
			process_mode = Node.PROCESS_MODE_PAUSABLE
			set_physics_process(true)
		_is_focused = value

var _is_focused : bool = true
#endregion

#region Statics
## Creates a basic timeline that uses [param i_zone_data] to determine the shape of the map and what
## enemies can appear.
static func generate_timeline(i_zone_data: ZoneData, timeline_name: StringName=&"NewTimeline") -> Timeline:
	var new_timeline := Timeline.new()
	new_timeline.name = timeline_name
	new_timeline.zone_data = i_zone_data
	#new_timeline.mouse_filter = Control.MOUSE_FILTER_IGNORE
	#new_timeline.focus_mode = Control.FOCUS_NONE
	
	var new_viewport = SubViewport.new()
	print(GlobalSettings.display.current_resolution)
	new_viewport.size = GlobalSettings.display.current_resolution
	new_viewport.physics_object_picking = true
	new_viewport.set_process_unhandled_input(true)
	new_viewport.own_world_3d = true
	new_timeline.sub_view = new_viewport
	
	var new_map := GameTileMap.generate_map(i_zone_data, &"BattleMap")
	new_map.generate_battle_tiles()
	new_timeline.map = new_map
	
	var new_cam : BattleCam = battle_cam_scene.instantiate()
	new_cam.timeline = new_timeline
	new_timeline.camera = new_cam
	
	var new_light := DirectionalLight3D.new()
	new_timeline.light = new_light
	
	var new_state_machine := _generate_state_machine(new_timeline)
	new_timeline.state_machine = new_state_machine
	
	new_viewport.add_child(new_light)
	new_viewport.add_child(new_cam)
	new_viewport.add_child(new_map)
	new_timeline.add_child(new_viewport)
	new_timeline.add_child(new_state_machine)
	
	new_cam.position = Vector3(0, 1, 20)
	new_light.rotate_x(-PI / 2.)
	
	return new_timeline

## TODO: Shorten this code later, make it compatible with generate_timeline, but for now, this works.
static func rebuild_timelines(data: Dictionary[StringName, Variant], new_name: StringName) -> Timeline:
	var new_timeline := Timeline.new()
	new_timeline.name = new_name
	new_timeline.zone_data = data.get(&"zone_data")
	#new_timeline.mouse_filter = Control.MOUSE_FILTER_IGNORE
	#new_timeline.focus_mode = Control.FOCUS_NONE
	
	var new_viewport = SubViewport.new()
	print(GlobalSettings.display.current_resolution)
	new_viewport.size = GlobalSettings.display.current_resolution
	new_viewport.physics_object_picking = true
	new_viewport.set_process_unhandled_input(true)
	new_timeline.sub_view = new_viewport
	
	var new_map := GameTileMap.rebuild_map(data.get(&"map"), &"BattleMap")
	new_map.generate_battle_tiles()
	new_timeline.map = new_map
	
	var new_cam : BattleCam = battle_cam_scene.instantiate()
	new_cam.timeline = new_timeline
	new_timeline.camera = new_cam
	
	var new_light := DirectionalLight3D.new()
	new_timeline.light = new_light
	
	var new_state_machine := _generate_state_machine(new_timeline, data.get(&"state_machine"))
	new_timeline.state_machine = new_state_machine
	
	new_viewport.add_child(new_light)
	new_viewport.add_child(new_cam)
	new_viewport.add_child(new_map)
	new_timeline.add_child(new_viewport)
	new_timeline.add_child(new_state_machine)
	
	new_cam.position = Vector3(0, 1, 20)
	new_light.rotate_x(-PI / 2.)
	
	return new_timeline

static func _generate_state_machine(t_line: Timeline, data: Dictionary[StringName, Variant]={}) -> StateMachine:
	var new_state_machine := StateMachine.new()
	var new_init_state := BattleInitState.generate_combat_state(t_line)
	var new_round_state := BattleRoundStartState.generate_combat_state(t_line)
	var new_turn_state := BattleTurnState.generate_combat_state(t_line)
	var new_tile_state := BattleTileTurnState.generate_combat_state(t_line)
	var new_end_round_state := BattleRoundEndState.generate_combat_state(t_line)
	var new_end_battle_state := BattleEndState.generate_combat_state(t_line)
	
	new_state_machine.add_child(new_init_state)
	new_state_machine.add_child(new_round_state)
	new_state_machine.add_child(new_turn_state)
	new_state_machine.add_child(new_tile_state)
	new_state_machine.add_child(new_end_round_state)
	new_state_machine.add_child(new_end_battle_state)
	if data.size() > 0:
		for state in new_state_machine.get_children():
			if state.name != data.get(&"current_state"):
				continue
			new_state_machine.initial_state = state
		new_state_machine.initial_data = data.get(&"state_data")
	else:
		new_state_machine.initial_state = new_init_state
	
	return new_state_machine
#endregion

#region Events
func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouse:
		return
	
	var local_event = event.duplicate()
	local_event.position = sub_view.get_final_transform().affine_inverse() * event.position
	print("Event Pos: %s, Local Pos: %s" % [event.position, local_event.position])
	sub_view.push_input(local_event)
	
	#if sub_view.is_input_handled():
	#	get_tree().set_input_as_handled()

func save_data() -> Dictionary[StringName, Variant]:
	var dict : Dictionary[StringName, Variant] = {
		&"zone_data": zone_data,
		&"map": map.save_data(),
		&"state_machine": _save_state_machine_data()
	}
	return dict

func _save_state_machine_data() -> Dictionary[StringName, Variant]:
	var dict : Dictionary[StringName, Variant] = {
		&"current_state": state_machine.state.name,
		&"state_data": state_machine.state.save_data()
	}
	return dict
#endregion
