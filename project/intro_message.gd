extends Node2D

var num_clips = 6
var next_clip = 0
var clip_playing = false

signal clip_playback_complete
signal intro_playback_complete

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func play_next_clip():
	# Plays the next intro clip, if there is one available and nothing is currently playing
	if clip_playing == true:
		# Do nothing -- we don't want too much noise
		return
	
	match next_clip:
		0:
			$audio_welcome.playing = true
			clip_playing = true
		1:
			$audio_great_day.playing = true
			clip_playing = true
		2:
			$audio_out_and_about.playing = true
			clip_playing = true
		3:
			$audio_up_to_you.playing = true
			clip_playing = true
		4:
			$audio_your_guide.playing = true
			clip_playing = true
		5:
			$audio_lets_take_a_look.playing = true
			clip_playing = true
	
	# OK, that should be it!
	

func _on_audio_finished():
	clip_playing = false
	next_clip = next_clip + 1
	if next_clip == num_clips:
		emit_signal("intro_playback_complete")
	else:
		emit_signal("clip_playback_complete")
