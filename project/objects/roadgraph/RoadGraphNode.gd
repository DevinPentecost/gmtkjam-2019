tool
extends Area2D

signal selected(selected)

var grid_pos = null

#Selection
var selected = false setget set_selected
var _wait_for_release = false
var editor_selection = null

#Drawing variables
var draw_radius = 4
var draw_color = Color(1, 1, 1, 1)
var draw_selected_radius = 6
var draw_selected_color = Color(1, .5, .2, 1)


func set_selected(_selected):
	selected = _selected
	emit_signal("selected", selected)
	update()

func _enter_tree():
	#Check for selection
	return
	editor_selection = EditorInterface.get_editor_interface().get_selection()
	editor_selection.connect("selection_changed", self, "on_editor_selection_changed")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#Update the shape, or kill on non-editor
	if Engine.is_editor_hint():
		$CollisionShape2D.shape.radius = draw_radius
	else:
		$CollisionShape2D.queue_free()
	
	#Draw this node
	update()

func _draw():
	
	#If we're selected, draw a larger circle behind
	if selected:
		draw_circle(Vector2(0, 0), draw_selected_radius, draw_selected_color)
	
	#Draw a simple cirle
	draw_circle(Vector2(0, 0), draw_radius, draw_color)


func _on_RoadGraphNode_input_event(viewport, event, shape_idx):
	return
	#Was it clicked?
	if event is InputEventMouseButton and event.button_index == 1:
		
		#Were we already selected?
		print("EVENT")
		if not _wait_for_release and event.pressed:
			_wait_for_release = true
			set_selected(!selected)
		elif _wait_for_release and not event.pressed:
			_wait_for_release = false

func _on_editor_selection_changed():
	#Get everything selected
	var selected_nodes = editor_selection.get_selected_nodes()
	
	#Are we in there?
	if selected_nodes.has(self):
		set_selected(true)
	else:
		set_selected(false)
