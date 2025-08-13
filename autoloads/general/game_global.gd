# Current feature worked on for Riley: Crafting, coding-in_progress

## The actual Global containing all of the game's core information.
extends Node

var rng : RandomNumberGenerator

#region Built-Ins
func _ready() -> void:
	# Loading up sounds and then deleting the sound_loader as it's no longer necessary
	var sound_loader = SoundLoader.new()
	sound_loader.load_audio()
	sound_loader = null
	rng = RandomNumberGenerator.new()
	rng.seed = rng.randi_range(0, 99999)
#endregion

#region Helpers
func delay(time: float) -> void:
	await get_tree().create_timer(time).timeout
#endregion
