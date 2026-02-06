## Progression Scene, wher the actual "game" is held. Controls the progression
## of events such as the Shop, Battle, etc.
class_name ProgScene extends Node

#region Declarations
@export var event_references : Array[EventHolder] ## A reference list for all in-game events
@export var button_container : VBoxContainer ## The container holding the buttons for next progression scene 
@export var scene_holder : Node ## The Node that acts as a parent to the event scenes.

var current_scene_index: int = 0 ## The current scene index from start (0)
var current_scene : BaseEventScene = null ## Reference of the current accessible scene
var event_history: Array[String] = [] ## The total list of events that the player has gone through
var frequency_events : Array[EventHolder] ## Events that rely on showing up in a reliable fashion
var random_events : Array[EventHolder] ## Truly random events that are not dependent on [member current_scene_index]
var is_frequency := false ## Is the current event a frequency event
var generation_height : int = 3
#endregion

#region Events
func _ready() -> void:
	SceneManager.prog_scene = self
	_setup_progression()
	
	generate_next_events()

## Generates the next set of events
# TODO: Probably do a one or two over the current scene progression logic, there's definitely some
# improvements to be made.
func generate_next_events() -> void:
	button_container.get_parent().show()
	current_scene_index += 1
	@warning_ignore("integer_division")
	CombatManager.level_number = current_scene_index / 10
	var event_set : Array[EventHolder] = _generate_events()
	for event_button in button_container.get_children():
		button_container.remove_child(event_button)
	
	if event_set.size() > 1:
		for i in range(generation_height):
			_generate_event_button(event_set)
	else:
		_generate_event_button(event_set)
	
	button_container.set_position(Vector2.ZERO)

func _setup_progression() -> void:
	for event in event_references:
		if event.spawn_frequency != -1:
			frequency_events.append(event)
		else:
			random_events.append(event)

func _generate_events() -> Array[EventHolder]:
	var valid_events : Array[EventHolder] = []
	for event in frequency_events:
		if current_scene_index % event.spawn_frequency == 0:
			valid_events.append(event)
	
	if valid_events.size() > 1:
		var priority_event : EventHolder = null
		for event in valid_events:
			if not priority_event:
				priority_event = event
				continue
			
			if priority_event.priority < event.priority:
				valid_events.erase(priority_event)
				priority_event = event
	elif valid_events.size() == 0:
		return random_events
	
	return valid_events

func _generate_event_button(event_set: Array[EventHolder]) -> void:
	var event_button := EventButton.new()
	var chosen_event = _choose_event(event_set)
	event_button.event = chosen_event
	event_button.text = chosen_event.scene_name
	button_container.add_child(event_button)
	event_button.next_event.connect(_on_event_button_pressed)

func _choose_event(event_list: Array[EventHolder]) -> EventHolder:
	# Create weights excluding BossScene and CraftScene since they're handled by floor patterns
	var weights : PackedFloat32Array = []
	for event in event_list:
		weights.append(float(event.weight))
	var _index = GameGlobal.rng.rand_weighted(weights)
	return event_list.get(GameGlobal.rng.rand_weighted(weights))

func _clear_event_buttons() -> void:
	for button in button_container.get_children():
		button_container.remove_child(button)

func get_event_history() -> Array[String]:
	return event_history.duplicate()

func reset_progression():
	current_scene_index = 0
	event_history.clear()
	GameGlobal.rng.state = 0

# Utility function to get deterministic value based on scene index
func get_deterministic_value(min_val: int, max_val: int, d_offset: int = 0) -> int:
	var temp_rng = RandomNumberGenerator.new()
	temp_rng.seed = GameGlobal.rng.seed
	temp_rng.state = GameGlobal.rng.state + current_scene_index + d_offset
	return temp_rng.randi_range(min_val, max_val)

#endregion

#region Signal Callbacks
func _on_event_button_pressed(event: EventHolder) -> void:
	var new_scene : BaseEventScene = event.scene.instantiate()
	if current_scene:
		scene_holder.remove_child(current_scene)
		scene_holder.add_child(new_scene)
		current_scene.queue_free()
		current_scene = new_scene
	else:
		scene_holder.add_child(new_scene)
		current_scene = new_scene
	
	_clear_event_buttons()
	button_container.get_parent().hide()
#endregion
