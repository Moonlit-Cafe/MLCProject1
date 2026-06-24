## Contains general functions to be used throughout the project, as well as
## centralizes core data relating to gameplay and debugging.
extends Node

#region Declarations
@onready var events : GlobalEvents = $GlobalEvents ## The game's main SignalBus
@onready var logs : LogSystem = $LogSystem ## The game's logging system for debugging
#endregion

#region Events
func _ready() -> void:
	_signal_init()

## Sets up the connections for all signals prevalent to Global.
func _signal_init() -> void:
	events.game_end.connect(_on_game_ended)
#endregion

#region Signal Callbacks
## Called when the [signal GlobalEvents.game_end] is emitted, terminating the game.
func _on_game_ended() -> void:
	get_tree().quit()
#endregion
