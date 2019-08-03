extends Node

func get_random_source():
	var source_index = randi() % $Sources.get_child_count()
	return $Sources.get_child(source_index)

func get_random_destination():
	var destination_index = randi() % $Destinations.get_child_count()
	return $Destinations.get_child(destination_index)
