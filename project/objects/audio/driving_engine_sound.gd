extends Node2D

# Allowed range for the audio stream player
export var pitch_min = 0.60 # Audio pitch at minimum scale (0)
export var pitch_max = 1.20 # Audio pitch at maximum scale (100)

# Other scripts will want to set this value
var pitch_scale = 0 setget set_pitch_scale, get_pitch_scale

# Called when the node enters the scene tree for the first time.
func _ready():
	$audioplayer_engine.playing = true
	$audioplayer_engine.pitch_scale = pitch_min

func get_pitch_scale():
	return pitch_scale

func set_pitch_scale(_pitch_scale):
	# We need to convert the input value (0 -> 100)
	var in_min = 0
	var in_max = 100
	
	# Clamp the value to the input range
	pitch_scale = max(in_min, min(in_max, _pitch_scale))
	var new_value = (pitch_min) + ((pitch_max - pitch_min) * (pitch_scale - in_min)/(in_max - in_min))
	
	# Instruct the audio player to change pitch
	$audioplayer_engine.pitch_scale = new_value