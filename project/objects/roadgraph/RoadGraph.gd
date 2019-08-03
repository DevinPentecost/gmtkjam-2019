extends Node2D

var connection_map = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	_build_connections()
	
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
	
	#Check all directions
	var paths = connection_map[source_node]
	for path in paths:
		
		#What's the angle on this one?
		var connection = path[0]
		var source = connection.get_source_node()
		var destination = connection.get_destination_node()
		var connection_direction = destination.position.direction_to(source.position)
		
		#What way are we trying to go?
		var turn_angle = connection_direction - current_direction
		match direction:
			false:
				if abs(turn_angle.angle() - 1) < threshold:
					print("PICK LEFT")
					return path
			null:
				if abs(turn_angle.angle()) < threshold:
					print("PICK STRAIGHT")
					return path
			true:
				if abs(turn_angle.angle() + 1) < threshold:
					print("PICK RIGHT")
					return path
	
	#Didn't find one that's good enough
	return null
	
	