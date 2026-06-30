## Progression Scene, wher the actual "game" is held. Controls the progression
## of events such as the Shop, Battle, etc.
class_name ProgScene extends Node

#region Declarations
@export var button_container : VBoxContainer ## The container holding the buttons for next progression scene 
@export var scene_holder : Node ## The Node that acts as a parent to the event scenes.
@export var test_version : bool = false

@onready var sector_generator : SectorGenerator = $SectorGenerator

var current_scene_index: int = 0 ## The current scene index from start (0)
var current_scene : BaseEventScene = null ## Reference of the current accessible scene
var event_history: Array[String] = [] ## The total list of events that the player has gone through
var is_frequency := false ## Is the current event a frequency event
var generation_height : int = 3
var focused_event : EventPoint
#endregion

#region Events
func _ready() -> void:
	SceneManager.prog_scene = self
	
	test_version = self.name.begins_with("TEST")
	
	sector_generator.GenerateEvents()
	focused_event = sector_generator.EventList.get(0).get(0)
	generate_next_events()

## Generates the next set of events
# TODO: Probably do a one or two over the current scene progression logic, there's definitely some
# improvements to be made.
func generate_next_events() -> void:
	button_container.get_parent().show()
	for event_button in button_container.get_children():
		button_container.remove_child(event_button)
	
	print(focused_event)
	if focused_event.ConnectionsTo.size() > 0:
		for connection in focused_event.ConnectionsTo:
			_generate_event_button(connection)
	
	#button_container.set_position(Vector2.ZERO)

func _generate_event_button(event: EventPoint) -> void:
	var event_button := EventButton.new()
	event_button.event = event
	event_button.text = event.TypeName
	button_container.add_child(event_button)
	event_button.next_event.connect(_on_event_button_pressed)
	if test_version:
		return
		# TYLER Implement this
		# should should pull from list of all events instead of whatever filters are present

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
func _on_event_button_pressed(event: EventPoint) -> void:
	var new_scene : BaseEventScene = event.Scene.instantiate()
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
	if test_version:
			get_parent().get_parent().get_child(0).button_container.get_parent().hide()
#endregion




# Tyler implement test version function
# func setup_test
