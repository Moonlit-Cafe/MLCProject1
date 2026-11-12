## The Autoload in charge of all things sound, from OSTs to SFXs
extends Node

#region Declarations
enum BusID {
	MASTER,
	OST,
	SFX,
	UI,
	AMBIENT
}

@export var ost_pool : Array[OstHolder] = [] ## The entire collection of OSTs available to use in the game.
@export var sfx_pool : Dictionary[StringName, AudioStream] = {} ## The entire collection of SFXs
@export var ui_pool : Dictionary[StringName, AudioStream] = {} ## The entire collection of UI SFXs
@export var ambient_pool : Dictionary[StringName, AudioStream] = {} ## The entire collection of Ambient SFXs

@onready var main_music_player : AudioStreamPlayer = $OSTPlayers/MainPlayer ## The Primary player for OSTs
## The Secondary player for OSTs, used for crossfading.
@onready var secondary_music_player : AudioStreamPlayer = $OSTPlayers/SecondaryPlayer
@onready var sfx_player_1 : AudioStreamPlayer = $SoundPlayers/SFXPlayer
@onready var sfx_player_2 : AudioStreamPlayer = $SoundPlayers/SFXPlayer2
@onready var ui_player : AudioStreamPlayer = $SoundPlayers/UIPlayer
@onready var ambient_player : AudioStreamPlayer = $SoundPlayers/AmbientPlayer

var current_song : OstHolder ## The currently playing song via [OstHolder]
var crossfade := false ## If [member current_song] is currently cross fading to another.
var _loop_timer : Timer
#endregion

#region Events
func _ready() -> void:
	_connect_sound_signals()
	_loop_timer = Timer.new()
	_loop_timer.one_shot = true
	_loop_timer.timeout.connect(_on_loop_timeout)
	add_child(_loop_timer)

## Connects all the audio players so that when they're finished, they specifically pass on their own data
## to [method _on_player_finished] to remove the [AudioStream]
func _connect_sound_signals() -> void:
	sfx_player_1.finished.connect(_on_player_finished.bind(sfx_player_1))
	sfx_player_2.finished.connect(_on_player_finished.bind(sfx_player_2))
	ui_player.finished.connect(_on_player_finished.bind(ui_player))
	ambient_player.finished.connect(_on_player_finished.bind(ambient_player))

## Attempts to play a song by their [param id] at [param position] seconds within the song. [br]
## The [member current_song] can either be abruptly stopped, or if [param crossover] is true, then [br]
## the two songs will fade between each other.
func play_ost(id: StringName, position: float = 0, crossover: bool = false) -> void:
	var song : OstHolder = _find_ost(id)
	if song == null:
		push_error("@Audiomanager/Error: There's no song by the name %s in song_pool" % id)
		return
	current_song = song
	
	if crossover:
		_crossover(id)
	else:
		main_music_player.stream = current_song.ost_stream
		main_music_player.play(position)
		_start_loop_timer(position)

## Plays a short jingle either just on its own or by crossfading [member current_song] assuming [br]
## it is playing
func play_jingle(sfx_id: StringName) -> void:
	if main_music_player.playing:
		_crossover(sfx_id, true)
	else:
		play_sound(sfx_id)

func play_sound(id: StringName) -> void:
	var sound : Array = _find_sound(id)
	if sound.is_empty():
		return
	var player : AudioStreamPlayer = _get_player(sound.get(1))
	if not player:
		return
	player.stream = sound.get(0)
	player.play()

## Grabs an ost to be used in another AudioPlayer, for example: Spatial Sounds.
func grab_ost(id: StringName) -> OstHolder:
	for ost in ost_pool:
		if ost.ost_name == id:
			return ost
	
	push_warning("@AudioManager: There is no ost by that ID.")
	return null

## Grabs a sound to be used in another AudioPlayer, for example: Spatial Sounds.
func grab_sound(id: StringName) -> AudioStream:
	var sound : Array = _find_sound(id)
	if sound.is_empty():
		return null
	return sound.get(0)

func _crossover(id: StringName, sfx_crossover := false) -> void:
	crossfade = true
	if !sfx_crossover:
		var next_song : OstHolder = _find_ost(id)
		if next_song == null:
			push_error("@Audiomanager/Error: There's no song by the name %s in song_pool" % id)
			crossfade = false
			return
		
		# Setup the new ost on Secondary
		secondary_music_player.stream = next_song.ost_stream
		secondary_music_player.volume_linear = 0
		secondary_music_player.play()
		
		# Create the crossover tween
		var tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
		tween.tween_property(main_music_player, "volume_linear", 0, 1.0)
		tween.parallel().tween_property(secondary_music_player, "volume_linear", 1, 1.0)
		
		await tween.finished
		# Move from Secondary to Main
		var resume_position : float = secondary_music_player.get_playback_position()
		main_music_player.stream = secondary_music_player.stream
		main_music_player.volume_linear = 1
		secondary_music_player.volume_linear = 0
		main_music_player.play(resume_position)
		secondary_music_player.stop()
		secondary_music_player.stream = null
		_start_loop_timer(resume_position)
	else:
		# Fade out stream on Main, play our SFX, then fade back in
		var fade_out = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
		fade_out.tween_property(main_music_player, "volume_linear", 0, 5.0)
		await fade_out.finished
		play_sound(id)
		
		var fade_in = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
		fade_in.tween_property(main_music_player, "volume_linear", 1, 5.0)
		await fade_in.finished
	
	crossfade = false
#endregion

#region Processes
func _start_loop_timer(from_position: float = -1.0) -> void:
	if _loop_timer == null:
		return
	_loop_timer.stop()
	if current_song == null or not current_song.can_loop or current_song.ost_stream == null:
		return
	
	var loop_end : float = current_song.ost_stream.get_length()
	if current_song.loop_vector.y != -1:
		loop_end = current_song.loop_vector.y
	
	var position : float = main_music_player.get_playback_position() if from_position < 0.0 else from_position
	_loop_timer.start(maxf(loop_end - position, 0.001))

func _on_loop_timeout() -> void:
	if current_song == null or not current_song.can_loop:
		return
		
	if crossfade:
		_loop_timer.start(0.1)
		return
	play_ost(current_song.ost_name, current_song.loop_vector.x)
#endregion

#region Helpers
## Finds the ost with the id [param id].
func _find_ost(id: StringName) -> OstHolder:
	for ost in ost_pool:
		if ost.ost_name == id:
			return ost
	
	return null

## Attempts to find a sound based on its [param id], returns an array of [br]
## [[enum BusID], [AudioStream]]
func _find_sound(id: StringName) -> Array:
	var bus : BusID
	var sound : AudioStream
	if sfx_pool.has(id):
		bus = BusID.SFX
		sound = sfx_pool.get(id)
	elif ui_pool.has(id):
		bus = BusID.UI
		sound = ui_pool.get(id)
	elif ambient_pool.has(id):
		bus = BusID.AMBIENT
		sound = ambient_pool.get(id)
	else:
		Global.logs.post_warning(self, "There is no sound by the name %s in any pool." % id)
		return []
	
	return [sound, bus]

## Based on [param bus], will grab a corresponding and [b]open[/b] player.
func _get_player(bus: BusID) -> AudioStreamPlayer:
	match(bus):
		BusID.SFX:
			if sfx_player_1.stream == null:
				return sfx_player_1
			elif sfx_player_2.stream == null:
				return sfx_player_2
			else:
				push_warning("@AudioManager: Both SFX players are in use, cannot return player")
				return null
		BusID.UI:
			if ui_player.stream == null:
				return ui_player
			else:
				push_warning("@AudioManager: UI Player is currently in use, cannot return player")
		BusID.AMBIENT:
			if ambient_player.stream == null:
				return ambient_player
			else:
				push_warning("@AudioManager: Ambient Player is currently in use, cannot return player")
		_:
			push_warning("@AudioManager: The bus given, is not a correct bus type")
			return null
	
	return null
#endregion

#region Signal Callbacks
## When a player's audio is finished (specifically for sound), will then ensure the is stopped and then
## removes the [AudioStream] from the player.
func _on_player_finished(player: AudioStreamPlayer) -> void:
	player.stop()
	player.stream = null
#endregion
