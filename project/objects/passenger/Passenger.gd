extends Node

signal passenger_impatient

#Scoring variables
var base_score = 100.0
var current_score = base_score
var score_time_loss = 10.0 #Per second
var impatient = false
var bonus_time = 5.0
var picked_up = false

#To and from locations
var _source = null
var _destination = null

#Visuals
export(Array, Texture) var normal_textures = []
export(Array, Texture) var impatient_textures = []
var normal_texture = null
var impatient_texture = null

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not picked_up:
		return
	
	#Lose score over time
	current_score -= score_time_loss * delta
	current_score = max(current_score, 10)
	
	#Are we impatient?
	if not impatient and current_score < 40:
		impatient = true
		emit_signal("passenger_impatient")
	

func refresh(source_landmark, destination_landmark):
	impatient = false
	picked_up = false
	_source = source_landmark
	_destination = destination_landmark
	
	#New score
	current_score = base_score
	
	#Adjust score based on distance?
	
	#Pick new textures
	var texture_index = randi() % normal_textures.size()
	normal_texture = normal_textures[texture_index]
	impatient_texture = impatient_textures[texture_index]

func get_pickup_message():
	return {
		"portrait_texture": normal_texture,
		"text_message": "Hi I would like to go to the " + _destination.landmark_name
	}

func get_dropoff_message():
	return {
		"portrait_texture": normal_texture,
		"text_message": "Thanks for dropping me off here is " + str(current_score)
	}

func get_impatient_message():
	return {
		"portrait_texture": impatient_texture,
		"text_message": "Please hurry and get me to " + _destination.landmark_name
	}

