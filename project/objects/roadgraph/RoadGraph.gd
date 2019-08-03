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

func _get_random_connection(source_node):
	"""
	Returns a random path, which is a [RoadGraphConnection, RoadGraphNode] tuple
	"""
	
	#How many destinations?
	var paths = connection_map[source_node]
	
	#Get one at random
	var path_index = randi() % paths.size()
	var path = paths[path_index]
	return path
