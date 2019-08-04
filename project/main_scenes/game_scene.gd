extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$intro_message.play_next_clip()
	
	# As a test, just use the default message and portrait
	var dict0 = {}
	dict0["portrait_texture"] = load("res://2d_resources/dogs/dog2a.png")
	dict0["text_message"] = "I can't wait to get home and play with my family !!"
	$passenger_message.append_passenger_message(dict0)
	
	var dict1 = {}
	dict1["portrait_texture"] = load("res://2d_resources/dogs/dog2b.png")
	dict1["text_message"] = "This is taking too long..."
	$passenger_message.append_passenger_message(dict1)
	pass # Replace with function body.

func _on_slider_speed_value_changed(value):
	$driving_engine_sound.pitch_scale = value

func _on_intro_message_clip_playback_complete():
	# Just play the next clip
	$intro_message.play_next_clip()
