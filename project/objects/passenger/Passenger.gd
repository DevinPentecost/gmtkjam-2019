extends Node

signal passenger_impatient

#Scoring variables
var base_score = 100.0
var current_score = base_score
var score_time_loss = 10.0 #Per second
var impatient = false

#To and from locations
var _source = null
var _destination = null

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	#Lose score over time
	current_score -= score_time_loss * delta
	
	#Are we impatient?
	if not impatient and current_score < 40:
		impatient = true
		emit_signal("passenger_impatient")
	

func refresh(source_landmark, destination_landmark):
	impatient = false
	_source = source_landmark
	_destination = destination_landmark
	
	#New score
	current_score = base_score
	
	#Adjust score based on distance?
	pass

func get_pickup_quote():
	return "Hi I would like to go to the " + _destination.landmark_name

func get_dropoff_quote():
	return "Thanks for dropping me off here is " + current_score

func get_impatient_quote():
	return "Please hurry and get me to " + _destination.landmark_name
