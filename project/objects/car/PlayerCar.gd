extends Car

# Called when the node enters the scene tree for the first time.
func _ready():
	
	set_process_unhandled_key_input(true)

func pick_next_destination():
	
	#Try going straight
	var connection = _road_graph.get_connection_for_direction(current_direction, _target_graph_node, null, 1)
	
	#Did we find a good path for the desired direction?
	if connection:
		var destination = connection[1]
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
	var connection = _road_graph.get_connection_for_direction(current_direction, _target_graph_node, direction, threshold)
	
	#Did we find a good path for the desired direction?
	if connection:
		var destination = connection[1]
		set_next_destination(destination)
	