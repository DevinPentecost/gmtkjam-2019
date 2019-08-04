extends Area2D

signal pin_reached

export var debug = true
export var compass_radius = 250.0
export(NodePath) var player
onready var _player = get_node(player)

#Tweening stuff
var height_offset = 100.0
var tween_time = 1.0
var target_position = Vector2(0, 0)
var _showing = false

onready var _pointer = find_node('FloatingSprite')
onready var _float_point = Vector2(0,0) # must be global

# Called when the node enters the scene tree for the first time.
func _ready():
	#Set up screen notifiers on the pin
	var _screen_notifier = VisibilityNotifier2D.new()
	add_child(_screen_notifier)
	_screen_notifier.connect("screen_entered", self, "screen_entered")
	_screen_notifier.connect("screen_exited", self, "screen_exited")
	
func screen_entered():
	print()
	if _showing:
		print("im on the screen, remove pointer")
		print(get_viewport_transform().origin)
	_pointer.visible = false

func screen_exited():
	if _showing:
		print("im off the screen, show pointer")
		print(get_viewport_transform().origin)
		_pointer.visible = true

func set_showing(showing=true):
	_showing = showing

	#Tween in/out and stuff
	var target_y = target_position.y if showing else target_position.y - height_offset
	var target_color = modulate
	target_color.a = 1.0 if showing else 0.0
	$Tween.interpolate_property(self, "global_position:y", global_position.y, target_y, tween_time, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.interpolate_property(self, "modulate", modulate, target_color, tween_time, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.start()

	#Enable/disabe the collision
	$CollisionShape2D.set_deferred("disabled", !showing)


func move_to_landmark(target_landmark):

	#Simply take it's position
	target_position = target_landmark.global_position
	global_position = target_landmark.global_position
	position.y -= height_offset

func _on_Pin_area_entered(area):
	#Did we connect with the player?
	if area.is_in_group("player"):
		#We must have reached the destination!
		emit_signal("pin_reached")

func _draw():
	if debug and _player:
		draw_line(Vector2(0,0), _float_point, Color(255, 0, 0), 1)
		
		
		# testing canvas edges
		draw_rect(_local_rect(_get_camera_rect()), Color(255, 0, 0), false)

func _get_camera_rect():
	# returns in global positioned rect!!
	var vtrans = get_canvas_transform()
	var top_left = -vtrans.get_origin() / vtrans.get_scale()
	var vsize = get_viewport_rect().size
	return Rect2(top_left, vsize/vtrans.get_scale())

func _local_rect(grect):
	return Rect2(to_local(grect.position), grect.size)

#func _get_camera_intersection(gpos):
	# check each border of the screen
#	Geometry.segment_intersects_segment_2d()

func _process(delta):
	var tpos = _player.global_position
	
	var dist = (to_local(tpos).length() - compass_radius)
	if dist > 0:
		_float_point = to_local(tpos).normalized() * dist
	else:
		_pointer.visible = false
		
	if debug and _player:
		update()
	
	_pointer.global_position = to_global(_float_point)
