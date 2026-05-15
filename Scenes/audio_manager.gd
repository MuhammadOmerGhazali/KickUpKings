extends Node

class_name AudioManager

@export_group("Music")
@export var bgm_track: AudioStream

@export_group("One Shots")
@export var kick_sfx: AudioStream
@export var click_sfx: AudioStream
@export var game_over_sfx: AudioStream
@export var highscore_sfx: AudioStream
@export var coin_collected_sfx: AudioStream

@export_group("Settings")
@export_range(0.0, 0.5) var pitch_range: float = 0.1 # Variation amount (0.1 = +/- 10%)

var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var sfx_playback: AudioStreamPlaybackPolyphonic

func _ready():
	# 1. Background Music Setup
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.bus = "Music"
	music_player.stream = bgm_track
	
	# 2. Polyphonic SFX Setup
	sfx_player = AudioStreamPlayer.new()
	sfx_player.stream = AudioStreamPolyphonic.new()
	sfx_player.bus = "SFX"
	add_child(sfx_player)
	
	# Start the player so it's "active"
	sfx_player.play() 
	
	# Wait for the engine to finish its current setup cycle
	await get_tree().process_frame
	
	# Now the playback instance will be valid
	sfx_playback = sfx_player.get_stream_playback()

# --- Internal Helper ---

func _play_with_random_pitch(clip: AudioStream):
	if not sfx_playback: return
	
	# Calculate a random pitch scale
	# If pitch_range is 0.1, this returns a value between 0.9 and 1.1
	var random_pitch = randf_range(1.0 - pitch_range, 1.0 + pitch_range)
	
	# play_stream(stream, offset, volume_db, pitch_scale)
	sfx_playback.play_stream(clip, 0, 0, random_pitch)

# --- Public Functions ---

func play_music():
	if not music_player.playing: music_player.play()

func stop_music():
	music_player.stop()

func play_kick():
	_play_with_random_pitch(kick_sfx)

func play_click():
	_play_with_random_pitch(click_sfx)

func play_game_over():
	_play_with_random_pitch(game_over_sfx)

func play_highscore():
	_play_with_random_pitch(highscore_sfx)

func play_coin_collected():
	_play_with_random_pitch(coin_collected_sfx)
