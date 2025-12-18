## Handles everything relating to normal sounds in the game.
extends Node

#region Declarations
#signal finished_sound(sfx)

@export var sfx_pool : Dictionary[StringName, AudioStream] = {} ## The entire collection of SFXs 
@export var ui_pool : Dictionary[StringName, AudioStream] = {} ## The entire collection of UI SFXs
@export var ambient_pool : Dictionary[StringName, AudioStream] = {} ## The entire collection of Ambient SFXs

var audio_players : Dictionary[Genum.BusID, Array] ## Reference to all the Available Audio Players based on their BUS
var audio_group_count : int = 4 ## How many Audio Players are generated per Bus

var playing : Array[StringName] ## What sounds are currently playing.
#endregion

#region Events
func _ready() -> void:
	_setup_audio_players()

func _setup_audio_players() -> void:
	for genum in Genum.BusID.values():
		for i in range(audio_group_count):
			var player := AudioStreamPlayer.new()
			add_child(player)
			var bus_name : StringName = GenumHelper.BUS_NAME.get(genum)
			player.name = "AudioPlayer%s_Bus%s" % [i, bus_name]
			player.bus = bus_name
			if audio_players.has(genum):
				audio_players.get(genum).append(player)
			else:
				audio_players.set(genum, [player])
			
			player.finished.connect(_on_player_finished)

## Plays a sound as long as it exists within any pool.
func play_sound(sound_name: StringName) -> void:
	var sound := _find_sound(sound_name)
	var player : AudioStreamPlayer
	if sound[1]:
		player = _find_open_player(sound[1])
	
	if player:
		player.stream = sound[0]
		player.play()
		playing.append(sound_name)

func _find_sound(sound_name: StringName) -> Array:
	var bus : Genum.BusID
	var sound : AudioStream
	if sfx_pool.has(sound_name):
		bus = Genum.BusID.SFX
		sound = sfx_pool.get(sound_name)
	elif ui_pool.has(sound_name):
		bus = Genum.BusID.UI
		sound = ui_pool.get(sound_name)
	elif ambient_pool.has(sound_name):
		bus = Genum.BusID.AMBIENT
		sound = ambient_pool.get(sound_name)
	
	return [sound, bus]

func _find_sound_stringname(stream: AudioStream) -> StringName:
	if stream in sfx_pool.values():
		return sfx_pool.find_key(stream)
	elif stream in ui_pool.values():
		return ui_pool.find_key(stream)
	elif stream in ambient_pool.values():
		return ambient_pool.find_key(stream)
	
	push_warning("There is no stream '%s' found in any sound pool." % stream)
	return &""

func _find_open_player(bus: Genum.BusID) -> AudioStreamPlayer:
	var player_list = audio_players.get(bus)
	for player in player_list:
		if not player.playing:
			return player
	
	push_warning("There is no open player...")
	return null 
#endregion

#region Signal Callbacks
func _on_player_finished() -> void:
	for bus in audio_players:
		for player in audio_players.get(bus):
			if player.stream and not player.playing:
				playing.erase(_find_sound_stringname(player.stream))
#endregion
