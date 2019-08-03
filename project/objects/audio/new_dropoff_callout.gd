extends Node2D

var callouts = {}
var playing = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var home = {}
	home["north"] = load("res://audio_resources/callouts/home_north.ogg")
	home["east"] =  load("res://audio_resources/callouts/home_east.ogg")
	home["south"] = load("res://audio_resources/callouts/home_south.ogg")
	home["west"] =  load("res://audio_resources/callouts/home_west.ogg")

	var groom = {}
	groom["north"] = load("res://audio_resources/callouts/groom_north.ogg")
	groom["east"] =  load("res://audio_resources/callouts/groom_east.ogg")
	groom["south"] = load("res://audio_resources/callouts/groom_south.ogg")
	groom["west"] =  load("res://audio_resources/callouts/groom_west.ogg")

	var park = {}
	park["north"] = load("res://audio_resources/callouts/park_north.ogg")
	park["east"] =  load("res://audio_resources/callouts/park_east.ogg")
	park["south"] = load("res://audio_resources/callouts/park_south.ogg")
	park["west"] =  load("res://audio_resources/callouts/park_west.ogg")

	var vet = {}
	vet["north"] = load("res://audio_resources/callouts/vet_north.ogg")
	vet["east"] =  load("res://audio_resources/callouts/vet_east.ogg")
	vet["south"] = load("res://audio_resources/callouts/vet_south.ogg")
	vet["west"] =  load("res://audio_resources/callouts/vet_west.ogg")

	callouts["home"] = home
	callouts["groom"] = groom
	callouts["park"] = park
	callouts["vet"] = vet

func play_pickup_callout(name, location):
	# Play a new sound if we can
	if playing == true:
		return
	
	# Load and start playing the sound
	$audio_callout.stream = callouts[name][location]
	$audio_callout.play()
	playing = true
	

func _on_audio_callout_finished():
	playing = false
