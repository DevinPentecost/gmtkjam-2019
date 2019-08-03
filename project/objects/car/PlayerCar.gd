extends Car

#Player gradually speeds up
var min_speed = 75
var accelleration = 0.50
var max_speed = 250

#Camera zoom based on speed
var speed_camera_zoom = [Vector2(min_speed, max_speed), Vector2(0.75, 2.25)] #Speed vs camera lerps


# Called when the node enters the scene tree for the first time.
func _ready():
	
	set_process(true)
	
	set_process_unhandled_key_input(true)

func _process(delta):
	
	#Adjust the camera based on speed
	var zoom = range_lerp(speed, speed_camera_zoom[0].x, speed_camera_zoom[0].y, speed_camera_zoom[1].x, speed_camera_zoom[1].y) 
	$PlayerCamera.zoom = Vector2(zoom, zoom)
	
	#Adjust speed
	speed += accelleration * delta
	speed = min(speed, max_speed)
	
func pick_next_destination():
	
	#Try going straight
	target_path = _road_graph.get_connection_for_direction(global_position, _target_graph_node, null, 1)
	
	#Did we find a good path for the desired direction?
	if target_path:
		var destination = target_path[1]
		set_next_destination(destination)
	else:
		#Pick a random one (call super)
		.pick_next_destination()

func _unhandled_key_input(event):
	
	#Was a direction hit?
	if event.is_action_pressed("player_turn_left"):
		_set_next_direction(false)
	elif event.is_action_pressed("player_turn_straight"):
		_set_next_direction(null)
	elif event.is_action_pressed("player_turn_right"):
		_set_next_direction(true)

func _set_next_direction(direction, threshold=0.5):
	#Search for one
	target_path = _road_graph.get_connection_for_direction(global_position, _target_graph_node, direction, threshold)
	
	#Did we find a good path for the desired direction?
	if target_path:
		var destination = target_path[1]
		set_next_destination(destination)
	