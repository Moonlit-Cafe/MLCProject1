extends EventScene

#region Declarations
@onready var timeline_holder : Control = $TimelineHolder

var current_timeline : Timeline
var diverged_timeline : Timeline
var zone_data : ZoneData
#endregion

#region Events
func _ready() -> void:
	_generate_initial_timeline()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("divergence"):
		diverged_timeline = current_timeline
		generate_new_timeline()
	
	if timeline_holder.get_child_count() < 2:
		return
	
	if event.is_action_pressed(&"move_left_timeline"):
		_move_to_next_timeline(current_timeline.left_timeline)
	elif event.is_action_pressed(&"move_right_timeline"):
		_move_to_next_timeline(current_timeline.right_timeline)

func generate_new_timeline(count: int = 1) -> void:
	for i in range(count):
		var new_timeline = diverged_timeline.duplicate()
		timeline_holder.call_deferred("add_child", new_timeline)
	
	await get_tree().process_frame
	for timeline in timeline_holder.get_children():
		timeline.hide()
		timeline.light.hide()
	_assign_timeline_neighbors()
	current_timeline.is_focused = true
	current_timeline.show()
	current_timeline.light.show()

func _generate_initial_timeline() -> void:
	var new_timeline = Timeline.generate_timeline(zone_data, &"Timeline")
	timeline_holder.call_deferred("add_child", new_timeline)
	current_timeline = new_timeline

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
