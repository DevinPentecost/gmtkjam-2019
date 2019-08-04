tool
extends Node2D

signal selected

#Selection and what this connects
var selected = false setget set_selected
export(NodePath) var node_a = null setget set_node_a
var _node_a = null
export(NodePath) var node_b = null setget set_node_b
var _node_b = null
export(bool) var a_to_b = true

enum directions {
	NW,
	NE,
	SW,
	SE
}
var direction = directions.NW

#Drawing variables
var draw_width = 2
var draw_color = Color(1, 1, 1, 1)
var draw_selected_width = 3
var draw_selected_color = Color(1, .5, .2, 1)
var lerp_amount = 0.0
var lerp_speed = .5
var lerp_draw_radius = 3
var lerp_draw_color = Color(0, 0, 0, 1)

func set_selected(_selected):
	selected = _selected
	update()

func set_node_a(__node_a):
	node_a = __node_a
	_get_nodes()
	update()

func set_node_b(__node_b):
	node_b = __node_b
	_get_nodes()
	update()

func _get_nodes():
	if not is_inside_tree():
		return
	
	if node_a:
		_node_a = get_node(node_a)
	if node_b:
		_node_b = get_node(node_b)

# Called when the node enters the scene tree for the first time.
func _ready():
	
	_get_nodes()
	update()
	
	set_process(true)

func _process(delta):
	
	#Update the lerp
	lerp_amount += delta * lerp_speed
	if lerp_amount > 1:
		lerp_amount = 0
	update()

func _draw():
	
	#Do we have both nodes?
	if not _node_a or not _node_b:
		return
	
	#Figure out where to draw the line
	var node_a_position = _node_a.global_position
	var node_b_position = _node_b.global_position
	
	#Draw background?
	if selected:
		draw_line(node_a_position, node_b_position, draw_selected_color, draw_selected_width, true)
	
	#Draw the main line
	draw_line(node_a_position, node_b_position, draw_color, draw_width)
	
	#Draw the direction indicator
	var start_position = node_a_position if a_to_b else node_b_position
	var end_position = node_b_position if a_to_b else node_a_position
	var lerp_position = start_position.linear_interpolate(end_position, lerp_amount)
	draw_circle(lerp_position, lerp_draw_radius, lerp_draw_color)

func get_source_node():
	#Depends on which way we're facing
	return _node_a if a_to_b else _node_b

func get_destination_node():
	#Depends on which way we're going
	return _node_b if a_to_b else _node_a
