class_name BattleScene extends EventScene

#region Declarations
@onready var timeline_holder : Control = $TimelineHolder

@export var battle_manager : BattleManager

var timeline_count : int = 0
var current_timeline : Timeline
var diverged_timeline : Timeline
var zone_data : ZoneData
var player : TileEntity
#endregion

#region Events
func _ready() -> void:
	_generate_initial_timeline()
	
	battle_manager._prep_move_player.connect(_prep_tiles_move)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("divergence") and (timeline_count - 1) < Global.diverge_max:
		diverged_timeline = current_timeline
		generate_new_timeline()
	
	if timeline_holder.get_child_count() < 2:
		return
	
	if event.is_action_pressed(&"move_left_timeline"):
		_move_to_next_timeline(current_timeline.left_timeline)
	elif event.is_action_pressed(&"move_right_timeline"):
		_move_to_next_timeline(current_timeline.right_timeline)

func generate_new_timeline(count: int = 1) -> void:
	# TODO: Grab data from regular timeline and rebuild.
	for i in range(count):
		var new_timeline_data = diverged_timeline.save_data()
		var new_timeline := Timeline.rebuild_timelines(new_timeline_data, diverged_timeline.name + str(i))
		timeline_holder.call_deferred("add_child", new_timeline)
	
	await get_tree().process_frame
	for timeline in timeline_holder.get_children():
		timeline.hide()
		timeline.light.hide()
	_assign_timeline_neighbors()
	timeline_count += 1
	current_timeline.is_focused = true
	current_timeline.show()
	current_timeline.light.show()

func _generate_initial_timeline() -> void:
	# HACK make this call _generate_new_timeline()
	# then move the signal connecting to that section
	var new_timeline = Timeline.generate_timeline(zone_data, &"Timeline")
	timeline_holder.call_deferred("add_child", new_timeline)
	for tile : BattleTile  in new_timeline.map.battle_tiles:
		tile.clicked.connect(move_player)
	
	current_timeline = new_timeline
	timeline_count += 1
	

func _prep_tiles_move():
	var to_be_edited = []
	to_be_edited = current_timeline.map.topmost_tiles
	if diverged_timeline:
		to_be_edited.append_array(diverged_timeline.map.topmost_tiles)
	
	for tile :BasicTile in to_be_edited:
		tile._change_color(false)
	return

func _assign_timeline_neighbors() -> void:
	if timeline_holder.get_child_count() < 2:
		return
	
	var i : int = 0
	var timelines : Array[Timeline] = []
	for child in timeline_holder.get_children():
		if not (child is Timeline):
			Global.logs.post_warning(timeline_holder, "A non-timeline is mixed in with the children.")
			return
		
		timelines.append(child)
	
	for timeline in timelines:
		if i == 0:
			timeline.left_timeline = timelines.get(timelines.size() - 1)
		else:
			timeline.left_timeline = timelines.get(i - 1)
		
		if i == (timelines.size() - 1):
			timeline.right_timeline = timelines.get(0)
		else:
			timeline.right_timeline = timelines.get(i + 1)
		
		timeline.is_focused = false
		i += 1

func _move_to_next_timeline(next_timeline: Timeline) -> void:
	current_timeline.hide()
	current_timeline.is_focused = false
	current_timeline.light.hide()
	current_timeline = next_timeline
	current_timeline.show()
	current_timeline.is_focused = true
	current_timeline.light.show()
#endregion

#region Signal Callbacks
func move_player(target_tile:BattleTile):
	if not player:
		player = get_tree().get_first_node_in_group(&"player")
		
	# TYLER and it will move the player to that tile
	target_tile.held_entity = player
	# player.stand_tile = target_tile
	return
#endregion
