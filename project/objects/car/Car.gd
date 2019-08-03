extends Area2D

export(NodePath) var road_graph = null
onready var _road_graph = get_node(road_graph)

#The current direction to go
export(NodePath) var target_graph_node = null
onready var _target_graph_node = get_node(target_graph_node)

#Where we're going to next after we reach the end
var next_graph_node = null
var turn_direction = null #False for Left, True for Right, Null for Forward/NA
var turn_distance_start = 20000 #How far away to pick a new direction
var min_turn_threshold = 0.5 #Radians of turn to need a signal

#How fast a car goes
export(float) var speed = 100
var _close_enough_threshold = 10

#Animating the blinker
var blink_on = false

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#Process along with physics for the sake of collision
	set_physics_process(true)

func _physics_process(delta):
	
	#Move towards the target
	var movement_vector = (_target_graph_node.global_position - global_position).normalized() * speed
	movement_vector *= delta
	position += movement_vector
	
	#Are we 'close enough'?
	if global_position.distance_squared_to(_target_graph_node.global_position) <= _close_enough_threshold:
		global_position = _target_graph_node.global_position
		next_destination()
	
	#Should we pick a new destination?
	if next_graph_node == null and global_position.distance_squared_to(_target_graph_node.global_position) <= turn_distance_start:
		#Pick a new destination
		pick_next_destination()
	
	#Point towards it
	var towards_rotation = _target_graph_node.global_position.angle_to_point(global_position)
	rotation = towards_rotation

func next_destination():
	#Start going to the next one and lose our previous 'next'
	_target_graph_node = next_graph_node
	
	#No current turn
	next_graph_node = null
	turn_direction = null
	$BlinkerTimer.stop()

func pick_next_destination():
	#Ask for a new connection
	var new_connection = _road_graph._get_random_connection(_target_graph_node)
	next_graph_node = new_connection[1]
	
	#Are we turning?
	var next_angle = _target_graph_node.global_position.angle_to_point(global_position)
	if abs(next_angle) > min_turn_threshold:
		#Which way?
		if sign(next_angle):
			turn_direction = false
		else:
			turn_direction = true
	
	#Turn on a blinker
	$BlinkerTimer.start()


func _on_BlinkerTimer_timeout():
	
	#Toggle our blink
	blink_on = !blink_on
	var turn_word = "left" if turn_direction else "right"
	if turn_direction == null: turn_word = 'straight, no blink please'
	print("BLINK ", blink_on, " ", turn_word)
	
