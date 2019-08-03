extends Node

signal passenger_collected(passenger)
signal passenger_dropped_off(passenger)
signal passenger_impatient(passenger)

export(NodePath) var landmarks = null
onready var _landmarks = get_node(landmarks)

onready var _source_pin = $SourcePin
onready var _destination_pin = $DestinationPin

var source_landmark = null
var destination_landmark = null

onready var _passenger = $Passenger

func _ready():
	
	#Get started
	_refresh_passenger()

func _refresh_passenger():
	#Pick a new set of places to go
	source_landmark = _landmarks.get_random_source()
	destination_landmark = _landmarks.get_random_destination()
	
	#Move the source
	_source_pin.move_to_landmark(source_landmark)
	_source_pin.set_showing(true)
	
	#Hide destination
	_destination_pin.set_showing(false)
	
	#Time to generate a new passenger
	_passenger.refresh(source_landmark, destination_landmark)

func _on_DestinationPin_pin_reached():
	
	#Let people know
	emit_signal("passenger_dropped_off", _passenger)
	
	_refresh_passenger()

func _on_SourcePin_pin_reached():
	
	#Let people know
	emit_signal("passenger_collected", _passenger)
	
	#Show the new destination
	_destination_pin.move_to_landmark(destination_landmark)
	_destination_pin.set_showing(true)
	
	#Hide the source
	_source_pin.set_showing(false)


func _on_Passenger_passenger_impatient():
	#Pass it along
	emit_signal("passenger_impatient", _passenger)
