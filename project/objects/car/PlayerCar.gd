extends Car

#Player gradually speeds up
var min_speed = 0.85 * speed
var max_speed = 2.5 * speed
var accelleration = (max_speed - speed) / 60

var player_desired_direction = null
var left_pressed = false
var right_pressed = false
var up_pressed = false

#Camera zoom based on speed
var speed_camera_zoom = [Vector2(min_speed, max_speed), Vector2(1.25, 2.25)] #Speed vs camera lerps


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
	
	# Adjust audio
	var speed_percent = (100 * (speed - min_speed)) / (max_speed - min_speed)
	$driving_engine_sound.set_pitch_scale(speed_percent)
	
func pick_next_destination():
	
	# held keys get checked first
	_set_direction_by_key()
	target_path = _road_graph.get_connection_for_direction(current_connection, player_desired_direction)

	#Try going straight
	if not target_path:
		target_path = _road_graph.get_connection_for_direction(current_connection, null)
	
	#Did we find a good path for the desired direction?
	if target_path:
		var destination = target_path[1]
		set_next_destination(destination)
		next_connection = target_path[0]
	else:
		#Pick a random one (call super)
		.pick_next_destination()

func _unhandled_key_input(event):
	#Was a direction hit?
	if event.is_action_pressed("player_turn_left"):
		left_pressed = true
	else:
		left_pressed = false
	
	if event.is_action_pressed("player_turn_straight"):
		up_pressed = true
	else:
		up_pressed = false
	
	if event.is_action_pressed("player_turn_right"):
		right_pressed = true
	else:
		right_pressed = false
		
	_set_direction_by_key()

func _set_direction_by_key():
	# Always have a strict resolution order
	# when multiple keys are pressed
	if left_pressed:
		_set_next_direction(false)
		#print('turning left')
	elif right_pressed:
		_set_next_direction(true)
		#print('turning right')
	elif up_pressed:
		_set_next_direction(null)
		#print('going straight')

func _set_next_direction(direction):
	player_desired_direction = direction
	
	#Search for one
	target_path = _road_graph.get_connection_for_direction(current_connection, direction)
	
	#Did we find a good path for the desired direction?
	if target_path:
		var destination = target_path[1]
		set_next_destination(destination)
		next_connection = target_path[0]

func take_hit(area):
	
	#Slow down
	if not flashing:
		$Tween.interpolate_property(self, "accelleration", -100, accelleration, 2, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.start()
		
	#Start flashing, we're just a regular car
	flash()
	
	$AudioStreamPlayer.play()
	
