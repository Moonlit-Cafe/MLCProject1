## Base class for all states.
class_name State extends Node

#region Declarations
@warning_ignore("unused_signal")
## Emitted when the state finishes and wants to transition to another state.
signal finished(next_state_path: StringName, data: Dictionary)
#endregion

#region Events
## Called by the state machine upon changing the active state to this one. The [param data] parameter
## is an arbitrary dictionary the state can use to initialize with.
func enter(_previous_state_path: StringName, _data:={}) -> void:
	pass

## Called by the state machine when receiving unhandled input events.
func handle_input(_event: InputEvent) -> void:
	pass

## Called by the state machine on the engine's main loop tick.
func update(_delta: float) -> void:
	pass

## Called by the state machine on the engine's physics loop tick.
func physics_update(_delta: float) -> void:
	pass

## Called by the state machine before changing the active state to the next one. Use this function
## to clean up the state.
func exit() -> void:
	pass
#endregion
