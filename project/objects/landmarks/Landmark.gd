extends Sprite

export(String) var landmark_name = "LANDMARK_NAME"

enum names {
	HOME,
	GROOM,
	PARK,
	VET
}
var name_map = {names.HOME: "home", names.GROOM: "groom", names.PARK: "park", names.VET: "vet"}
export(names) var callout_name = names.HOME

enum directions {
	NORTH,
	EAST,
	SOUTH,
	WEST
}
var direction_map = {directions.NORTH: "north", directions.EAST: "east", directions.SOUTH: "south", directions.WEST: "west"}
export(names) var callout_direction = directions.NORTH

func _ready():
	#Hide
	visible = false

func get_callout_info():
	return [
		name_map[callout_name],
		direction_map[callout_direction]
	]
