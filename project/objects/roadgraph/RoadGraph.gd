extends Node2D

var connection_map = {}

# Debug stuff
var obstacle_path = null
var player_path = null

# Called when the node enters the scene tree for the first time.
func _ready():
	_build_connections()

func _process(delta):
	# Every step we will check what the cars are trying to do
	# We will turn the node they selected a different color
	var new_obstacle_path = get_node("../Car").target_path
	var new_player_path = get_node("../PlayerCar").target_path
	
	if new_obstacle_path != obstacle_path:
		if obstacle_path != null:
			obstacle_path[0].modulate = Color(1, 1, 1, 1)
		obstacle_path = new_obstacle_path
		if obstacle_path != null:
			obstacle_path[0].modulate = Color(1, 0, 0, 1)
	if new_player_path != player_path:
		if player_path != null:
			player_path[0].modulate = Color(1, 1, 1, 1)
		player_path = new_player_path
		if player_path != null:
			player_path[0].modulate = Color(0, 1, 0, 1)
	
func _build_connections():
	
	#Go through each connection
	for connection_node in $RoadGraphConnections.get_children():
		
		#Is this connection 'complete'
		if connection_node._node_a and connection_node._node_b:
			
			#Is A the start or not?
			var source_node = connection_node._node_a
			var destination_node = connection_node._node_b
			if not connection_node.a_to_b:
					source_node = connection_node._node_b
					destination_node = connection_node._node_a
			
			#Now add it
			if not connection_map.has(source_node):
				connection_map[source_node] = []
			connection_map[source_node].append([connection_node, destination_node])

func get_random_connection(source_node):
	"""
	Returns a random path, which is a [RoadGraphConnection, RoadGraphNode] tuple
	"""
	
	#How many destinations?
	var paths = connection_map[source_node]
	
	#Get one at random
	var path_index = randi() % paths.size()
	var path = paths[path_index]
	return path

func get_connection_for_direction(current_direction, source_node, direction, threshold=0.2):
	"""
	Find the 'best' match, or null, for the given direction
	Compared against the current, normalized direction vector
	direction can be {false, null, true} for left, straight, right
	"""
	
	# Here's the plan
	# We're gonna pick a path no matter what. The player's input just helps us pick which one
	var available_paths = connection_map[source_node]
	
	# We know the current direction of the player -- lets determine the angle to continue on each of these paths
	var path_leftmost = null
	var path_rightmost = null
	var path_straightmost = null
	
	var angle_leftmost = 0
	var angle_rightmost = 0
	var angle_straightmost = 0
	
	print("New check")
	print("Current direction is " + String(current_direction.angle()))
	
	#Check all directions
	for path in available_paths:
		
		#What's the angle on this one?
		var path_connection = path[0]
		var path_source = path_connection.get_source_node()
		var path_destination = path_connection.get_destination_node()
		var path_direction = path_destination.position.direction_to(path_source.position)
		
		# We know the direction of this path. How does it compare to the current direction?
		var turn_angle = path_direction - current_direction
		
		var angle_to_path = turn_angle.angle()
		#angle_to_path = fmod(angle_to_path, PI)
		
		
		print("Angle options is " + String(angle_to_path))
		
		# Which bucket does this path fit in?
		
		# If a path is null lets just fill it
		if path_leftmost == null:
			path_leftmost = path
			angle_leftmost = angle_to_path
		if path_rightmost == null:
			path_rightmost = path
			angle_rightmost = angle_to_path
		if path_straightmost == null:
			path_straightmost = path
			angle_straightmost = angle_to_path
		
		# Is this our new rightmost?
		if angle_to_path > angle_rightmost:
			# This is the new rightmost
			path_straightmost = path_rightmost
			angle_straightmost = angle_rightmost
			path_rightmost = path
			angle_rightmost = angle_to_path
		
		# What about leftmost?
		if angle_to_path < angle_leftmost:
			# This is the new leftmost
			path_straightmost = path_leftmost
			angle_straightmost = angle_leftmost
			path_leftmost = path
			angle_leftmost = angle_to_path
		
	# Now all we have to do is select 
	match direction:
		null:
			print("CHOOSING STRAIGHT: " + String(angle_straightmost))
			return path_straightmost
		true:
			print("CHOOSING RIGHT: " + String(angle_rightmost))
			return path_rightmost
		false:
			print("CHOOSING LEFT: " + String(angle_leftmost))
			return path_leftmost