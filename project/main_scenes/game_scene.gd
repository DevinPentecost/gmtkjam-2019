extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$intro_message.play_next_clip()
	pass # Replace with function body.

func _on_slider_speed_value_changed(value):
	$driving_engine_sound.pitch_scale = value

func _on_intro_message_clip_playback_complete():
	# Just play the next clip
	$intro_message.play_next_clip()
