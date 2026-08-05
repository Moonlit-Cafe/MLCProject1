## A simple, but flexible StateMachine.
class_name StateMachine extends Node

#region Declarations
@export var initial_state : State = null
@export var initial_data : Dictionary = {}

## Defines the current state by either grabbing the first child or if [property initial_state] is set.
@onready var state : State = (func () -> State:
	return initial_state if initial_state != null else get_child(0)
).call()
#endregion

#region Events
func _ready() -> void:
	for state_node : State in find_children("*", "State"):
		state_node.finished.connect(_transition_to_next_state)
		print("Added state %s to signals" % state_node.name)
		
	if owner:
		await owner.ready
	elif get_parent():
		var parent = get_parent()
		if not parent.is_node_ready():
			await get_parent().ready
	state.enter("", initial_data)

func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)

func _process(delta: float) -> void:
	state.update(delta)

func _physics_process(delta: float) -> void:
	state.physics_update(delta)
#endregion

#region Signal Callbacks
## Handles the transitioning between [property state] and [param target_state_path]. Can also pass a
## dicitonary [param data] to provide additional context for the new state's initialization.
func _transition_to_next_state(target_state_path: String, data:={}) -> void:
	if not has_node(target_state_path):
		Global.logs.post_error(self, "Trying to transition to state %s but it does not exist." % target_state_path)
		return
	
	var previous_state_path := state.name
	state.exit()
	state = get_node(target_state_path)
	state.enter(previous_state_path, data)
#endregion
