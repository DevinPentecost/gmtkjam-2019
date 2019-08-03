extends Area2D
class_name Car

#Roads and destination
var _road_graph = null
var _target_graph_node = null

#Where we're going to next after we reach the end
var next_graph_node = null
var turn_direction = null #False for Left, True for Right, Null for Forward/NA
var turn_distance_start = 40000 #How far away to pick a new direction (Squared)
var min_turn_threshold = 0.5 #Radians of turn to need a signal

var target_path = null

#How fast a car goes
export(float) var speed = 300
var _close_enough_threshold = 30
var current_direction = null

#Animating the blinker
var blink_on = false

#Flashing for invluln
var flashing = false

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#Process along with physics for the sake of collision
	set_physics_process(true)

func _physics_process(delta):
	
	#Move towards the target
	var movement_vector = (_target_graph_node.global_position - global_position).normalized() * speed
	movement_vector *= delta
	position += movement_vector
	
	#Should we pick a new destination?
	if next_graph_node == null and global_position.distance_squared_to(_target_graph_node.global_position) <= turn_distance_start:
		#Pick a new destination
		pick_next_destination()
	
	#Are we 'close enough'?
	if global_position.distance_squared_to(_target_graph_node.global_position) <= _close_enough_threshold:
		global_position = _target_graph_node.global_position
		next_destination()
	
	#Point towards it
	var towards_rotation = _target_graph_node.global_position.angle_to_point(global_position)
	rotation = towards_rotation
	current_direction = _target_graph_node.global_position.direction_to(global_position)

func next_destination():
	#Start going to the next one and lose our previous 'next'
	_target_graph_node = next_graph_node
	
	#No current turn
	next_graph_node = null
	turn_direction = null
	_show_blinker(null)
	$BlinkerTimer.stop()

func pick_next_destination():
	#Ask for a new connection
	target_path = _road_graph.get_random_connection(_target_graph_node)
	set_next_destination(target_path[1])
	
	

func set_next_destination(destination_node):
	
	#Assign it
	next_graph_node = destination_node
	
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
	_show_blinker(turn_direction, blink_on)
	
func _show_blinker(blinker, on=false):
	if blinker == null:
		$Sprite/LeftBlinker.visible = false
		$Sprite/RightBlinker.visible = false
	
	var target_blinker = $Sprite/LeftBlinker if not blinker else $Sprite/RightBlinker
	target_blinker.visible = on


func _on_Car_area_entered(area):
	
	#So what did we hit?
	if area.is_in_group("player"):
		#Ouchie!
		take_hit()

func take_hit():
	#Start flashing, we're just a regular car
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
