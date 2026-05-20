# Current feature worked on for Riley: Crafting, coding-in_progress

## The actual Global containing all of the game's core information.
extends Node

#region Declarations
const _DEFAULT_DELAY = .5

@onready var events : GlobalEvents = $GameGlobalEvents
@onready var logging : LogSystem = $LogSystem
@onready var resources : ResourceManager = $ResourceManager

var rng : RandomNumberGenerator ## The main RNG for the game
#endregion

#region Events
func _ready() -> void:
	resources.init()
	# Loading up sounds and then deleting the sound_loader as it's no longer necessary
	rng = RandomNumberGenerator.new()
	rng.seed = rng.randi_range(0, 99999)
	rng.state = 0
	
	_signal_initialization()

func _signal_initialization() -> void:
	events.game_end.connect(_on_game_ended)
	pass
#endregion

#region Helpers
## Auto creates a way to delay time within a function
func delay(time: float = _DEFAULT_DELAY) -> void:
	await get_tree().create_timer(time).timeout

func get_random_i(from: int, to: int) -> int:
	return rng.randi_range(from, to)

func generate_sector() -> Array[EventPoint]:
	var sc := SectorGenerator.new()
	return sc.call("createSector")
#endregion

#region Signal Callbacks
func _on_game_ended() -> void:
	get_tree().quit()
#endregion
