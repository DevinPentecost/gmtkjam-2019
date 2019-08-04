extends Area2D
class_name Car

#Roads and destination
var _road_graph = null
var current_connection = null

#Where we're going to next after we reach the end
var next_connection = null
var next_graph_node = null
var turn_direction = null #False for Left, True for Right, Null for Forward/NA
var turn_distance_start = 40000 #How far away to pick a new direction (Squared)
var min_turn_threshold = 0.5 #Radians of turn to need a signal

var target_path = null

#How fast a car goes
export(float) var speed = 300
var _close_enough_threshold = 30

#Animating the blinker
var blink_on = false

#Flashing for invluln
var flashing = false

var sprite_nw = preload("res://objects/car/player_nw.png")
var sprite_ne = preload("res://objects/car/player_ne.png")
var sprite_sw = preload("res://objects/car/player_sw.png")
var sprite_se = preload("res://objects/car/player_se.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#Process along with physics for the sake of collision
	set_physics_process(true)

func _physics_process(delta):
	if current_connection == null:
		return
	
	var pos = global_position
	var pos2 = current_connection.get_destination_node().global_position
	var next_frame_position = (pos2-pos).normalized()*abs(speed) + pos
	
	#Should we pick a new destination?
	if next_graph_node == null and global_position.distance_squared_to(current_connection.get_destination_node().global_position) <= turn_distance_start:
		#Pick a new destination
		pick_next_destination()
	
	#Are we 'close enough'?
	var hit_along_path = Geometry.segment_intersects_circle(pos, next_frame_position, pos2, _close_enough_threshold)
	
	if hit_along_path >= 0:
		# we would hit this during this frame...
		global_position = current_connection.get_destination_node().global_position
		next_destination()
		position = position.linear_interpolate(next_frame_position, hit_along_path)
	
	#Move towards the target
	var movement_vector = (current_connection.get_destination_node().global_position - global_position).normalized() * (speed * (1.0-hit_along_path))
	movement_vector *= delta
	position += movement_vector
	
	#Point towards it
	var towards_rotation = current_connection.get_destination_node().global_position.angle_to_point(global_position)
	rotation = towards_rotation
	current_direction = current_connection.get_destination_node().global_position.direction_to(global_position)
	
	match current_connection.direction:
		0: $Sprite.texture = sprite_nw
		1: $Sprite.texture = sprite_ne
		2: $Sprite.texture = sprite_sw
		3: $Sprite.texture = sprite_se
		

func next_destination():
	#Start going to the next one and lose our previous 'next'
	current_connection = next_connection
	
	#No current turn
	next_graph_node = null
	turn_direction = null
	_show_blinker(null)
	$BlinkerTimer.stop()

func pick_next_destination():
	#Ask for a new connection
	target_path = _road_graph.get_random_connection(current_connection.get_destination_node())
	next_connection = target_path[0]
	set_next_destination(target_path[1])
	

func set_next_destination(destination_node):
	
	#Assign it
	next_graph_node = destination_node
	
	#Are we turning?
	var next_angle = current_connection.get_destination_node().global_position.angle_to_point(global_position)
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
	_show_blinker(turn_direction, blink_on)
	
func _show_blinker(blinker, on=false):
	if blinker == null:
		$Sprite/LeftBlinker.visible = false
		$Sprite/RightBlinker.visible = false
	
	var target_blinker = $Sprite/LeftBlinker if not blinker else $Sprite/RightBlinker
	#target_blinker.visible = on


func _on_Car_area_entered(area):
	
	#So what did we hit?
	if area.is_in_group("car"):
		#Ouchie!
		take_hit(area)

func take_hit(area):
	#Start flashing, we're just a regular car
	if area.is_in_group("player"):
		flash()
	
func flash():
	#Start flashing
	if flashing:
		return
	flashing = true
	
	for flash in 6:
		$Sprite.visible = !$Sprite.visible
		$FlashTimer.start()
		yield($FlashTimer, "timeout")
	
	#Done
	flashing = false
