extends Node2D

const RoadGraphNode = preload("res://objects/roadgraph/RoadGraphNode.tscn")
const RoadGraphConnection = preload("res://objects/roadgraph/RoadGraphConnection.tscn")

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
	return
	"""
	for car in get_tree().get_nodes_in_group('car'):
		var car_path = car.target_path
		if new_obstacle_path != obstacle_path:
			if obstacle_path != null:
				obstacle_path[0].modulate = Color(1, 1, 1, 1)
			obstacle_path = new_obstacle_path
			obstacle_path[0].modulate = Color(1, 0, 0, 1)
		if new_player_path != player_path:
			if player_path != null:
				player_path[0].modulate = Color(1, 1, 1, 1)
			player_path = new_player_path
			player_path[0].modulate = Color(0, 1, 0, 1)
	"""

func build_from_game_map(game_map):
	
	#We have a set of tile indices that represent intersections
	var intersection_tiles = [1, 2, 3, 4, 5, 13, 14, 15, 16]
	var nw_road = 10
	var ne_road = 9
	var sw_road = 12
	var se_road = 11
	
	#Let's build points first for every intersection
	var intersection_cells = {} #Position (Vec2 x y)
	for intersection_tile in intersection_tiles:
		
		#Get the indices for all of these
		for cell_position in game_map.get_used_cells_by_id(intersection_tile):
			
			#Make a new point at this place
			var new_node = RoadGraphNode.instance()
			
			#Isometric so this gets tricky
			var final_position = game_map.map_to_world(cell_position) / 4
			final_position.y += 64
			new_node.position = final_position
			$RoadGraphNodes.add_child(new_node)
			
			#Store it for later
			intersection_cells[cell_position] = new_node
	
	#Now go through each intersection
	for intersection_cell in intersection_cells:
		
		#Check each direction
		for direction in [[-1, 0], [0, 1], [0, -1], [1, 0]]:
			
			#Take a single step that direction
			var directionv = Vector2(direction[0], direction[1])
			var step_position = intersection_cell + directionv
			var step_tile = game_map.get_cellv(step_position)
			var valid_direction = false
			match direction:
				[-1, 0]:
					#NW
					valid_direction = step_tile == nw_road
				[0, -1]:
					#NE
					valid_direction = step_tile == ne_road
				[0, 1]:
					#SW
					valid_direction = step_tile == sw_road
				[1, 0]:
					#SE
					valid_direction = step_tile == se_road
			
			#Was this a good direction to go?
			if valid_direction:
				var connecting_intersection_position = intersection_cell + (directionv * 5)
				var target_cell = intersection_cells.get(connecting_intersection_position)
				if target_cell:
					
					#We can make a connection
					var new_connection = RoadGraphConnection.instance()
					new_connection._node_a = intersection_cells[intersection_cell]
					new_connection._node_b = target_cell
					$RoadGraphConnections.add_child(new_connection)
					
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
	
	