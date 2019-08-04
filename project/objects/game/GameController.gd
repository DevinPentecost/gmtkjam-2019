extends Node

signal time_up(final_score)

export(NodePath) var passenger_controller
onready var _passenger_controller = get_node(passenger_controller)

#Player time and scoring
var start_time = 180 #Seconds
var remaining_time = start_time
var score = 0

var game_over = false

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	#Lose some time
	remaining_time -= delta
	if remaining_time <= 0:
		remaining_time = 0
		out_of_time()
	
func out_of_time():
	print("WE RAN OUT OF TIME GAME OVER PAL")
	game_over = true
	set_process(false)
	emit_signal("time_up", score)


func _on_PassengerController_passenger_dropped_off(passenger):
	
	#Add the passenger's score
	score += passenger.current_score
	
	#Add some time
	remaining_time += passenger.bonus_time
