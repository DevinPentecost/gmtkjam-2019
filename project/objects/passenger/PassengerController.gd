extends Node

signal passenger_collected(passenger)
signal passenger_dropped_off(passenger)
signal passenger_impatient(passenger)

export(NodePath) var landmarks = null
onready var _landmarks = get_node(landmarks)

onready var _source_pin = $SourcePin
onready var _destination_pin = $DestinationPin
onready var _pin_pointer = $PinPointer

var source_landmark = null
var destination_landmark = null

onready var _passenger = $Passenger

var _message_gui = null

func _ready():
	randomize()
	
	#Get the message gui
	var message_gui = get_tree().get_nodes_in_group("message_gui")
	if message_gui.size() > 0:
		_message_gui = message_gui[0]
	
	# Get our first passenger!
	_refresh_passenger()
	_on_SourcePin_pin_reached()

func _refresh_passenger():
	#Pick a new set of places to go
	source_landmark = _landmarks.get_random_source()
	destination_landmark = _landmarks.get_random_destination()
	
	#Move the source
	_source_pin.move_to_landmark(source_landmark)
	_source_pin.set_showing(true)
	_pin_pointer.target_pin = _source_pin
	
	#Hide destination
	_destination_pin.set_showing(false)
	
	#Time to generate a new passenger
	_passenger.refresh(source_landmark, destination_landmark)

func _on_DestinationPin_pin_reached():
	
	#Let people know
	emit_signal("passenger_dropped_off", _passenger)
	if _message_gui:
		_message_gui.append_passenger_message(_passenger.get_dropoff_message())
		
	_refresh_passenger()

func _on_SourcePin_pin_reached():
	
	#Let people know
	emit_signal("passenger_collected", _passenger)
	_passenger.activate_passenger()
	
	if _message_gui:
		_message_gui.append_passenger_message(_passenger.get_pickup_message())
		_message_gui.play_pickup_callout(_passenger._destination.get_callout_info())
	
	#Show the new destination
	_destination_pin.move_to_landmark(destination_landmark)
	_destination_pin.set_showing(true)
	_pin_pointer.target_pin = _destination_pin
	
	#Hide the source
	_source_pin.set_showing(false)


func _on_Passenger_passenger_impatient():
	#Pass it along
	emit_signal("passenger_impatient", _passenger)
	
	#Tell the message gui to do stuff
	if _message_gui:
		_message_gui.append_passenger_message(_passenger.get_impatient_message())
	