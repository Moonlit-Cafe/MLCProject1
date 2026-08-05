## The actual battle system within the game, contained within a "Timeline" for the divergence feature.
class_name Timeline extends SubViewportContainer

#region Declarations
const battle_cam_scene : PackedScene = preload("res://entities/battle_cam.tscn")

var camera : BattleCam
var light : DirectionalLight3D
var left_timeline : Timeline = null
var right_timeline : Timeline = null
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

#region Events
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
	new_timeline.sub_view = new_viewport
	
	var new_map := GameTileMap.generate_map(i_zone_data, &"BattleMap")
	new_map.generate_battle_tiles()
	var p_tile := new_map.get_random_tile()
	var e_data : BaseCharacter = GlobalResources.get_data(GlobalResources.DataType.CHARACTER, &"E001")
	var p_entity := TileEntityPlayer.generate_entity(BaseCharacter.CharType.ENEMY, e_data)
	print(e_data)
	p_entity.add_to_group(&"player")
	p_tile.add_entity(p_entity)
	print("Generated at %s" % p_tile.name)
	
	var new_cam : BattleCam = battle_cam_scene.instantiate()
	new_cam.timeline = new_timeline
	new_timeline.camera = new_cam
	
	var new_light := DirectionalLight3D.new()
	new_timeline.light = new_light
	
	new_viewport.add_child(new_light)
	new_viewport.add_child(new_cam)
	new_viewport.add_child(new_map)
	new_timeline.add_child(new_viewport)
	
	new_cam.position = Vector3(0, 1, 20)
	new_light.rotate_x(-PI / 2.)
	
	return new_timeline

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouse:
		return
	
	var local_event = event.duplicate()
	local_event.position = sub_view.get_final_transform().affine_inverse() * event.position
	print("Event Pos: %s, Local Pos: %s" % [event.position, local_event.position])
	sub_view.push_input(local_event)
	
	#if sub_view.is_input_handled():
	#	get_tree().set_input_as_handled()
#endregion
