extends Area2D

signal pin_reached
signal pin_can_see
signal pin_cant_see

export var debug = false

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
		emit_signal("pin_can_see")

func screen_exited():
	if _showing:
		emit_signal("pin_cant_see")


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
	if debug:
		draw_line(Vector2(0,0), to_local(_float_point), Color(255, 0, 0), 1)
		# testing canvas edges
		draw_rect(_local_rect(_get_camera_rect()).grow(-3), Color(255, 0, 0), false)

func _get_rect_intersection(somerect, somepoint):
	# returns point along border of somerect that is closest to somepoint.
	# if the point is inside the rect, returns null
	
	if somerect.has_point(somepoint):
		return null
	
	var center = somerect.position.linear_interpolate(somerect.end, 0.5)
	var topleft = somerect.position
	var bottomright = somerect.end
	var topright = topleft
	topright.x = bottomright.x
	var bottomleft = bottomright
	bottomleft.x = topleft.x
	
	var x = Geometry.segment_intersects_segment_2d(center, somepoint, topleft, topright)
	if x != null:
		return x
	x = Geometry.segment_intersects_segment_2d(center, somepoint, topright, bottomright)
	if x != null:
		return x
	x = Geometry.segment_intersects_segment_2d(center, somepoint, bottomright, bottomleft)
	if x != null:
		return x
	x = Geometry.segment_intersects_segment_2d(center, somepoint, bottomleft, topleft)
	if x != null:
		return x
	printerr("it's really broken")
	return null

func _get_camera_rect():
	# returns in global positioned rect!!
	var vtrans = get_canvas_transform()
	var top_left = -vtrans.get_origin() / vtrans.get_scale()
	var vsize = get_viewport_rect().size
	return Rect2(top_left, vsize/vtrans.get_scale())

func _local_rect(grect):
	return Rect2(to_local(grect.position), grect.size)


func _process(delta):
	var camrect =  _get_camera_rect().grow(-3)
	var testpoint = _get_rect_intersection(camrect, global_position)
	if testpoint:
		_float_point = testpoint
		_pointer.visible = true
	else:
		_pointer.visible = false
	
	_pointer.global_position = _float_point
	#_pointer.set_rotation(_pointer.global_position.angle_to_point(global_position))
	# just use the same sprite
	var normal_sprite = find_node('Sprite')
	_pointer.texture = normal_sprite.texture
	_pointer.scale = normal_sprite.scale
	_pointer.scale = normal_sprite.scale

	update()
	
