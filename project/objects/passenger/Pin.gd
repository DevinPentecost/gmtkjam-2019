extends Area2D

signal pin_reached

export var debug = true

export(NodePath) var floating_radius_area
onready var _floating_radius_area = get_node(floating_radius_area)

#Tweening stuff
var height_offset = 100.0
var tween_time = 1.0
var target_position = Vector2(0, 0)
var _showing = false

onready var _pointer = find_node('FloatingSprite')
onready var _ray = RayCast2D.new()
onready var _float_point = global_position # must be global

# Called when the node enters the scene tree for the first time.
func _ready():
	#Set up screen notifiers on the pin
	var _screen_notifier = VisibilityNotifier2D.new()
	add_child(_screen_notifier)
	_screen_notifier.connect("screen_entered", self, "screen_entered")
	_screen_notifier.connect("screen_exited", self, "screen_exited")
	
	add_child(_ray)
	_ray.collide_with_areas = true
	_ray.collide_with_bodies = false
	_ray.exclude_parent = true
	
	_ray.set_collision_mask_bit(_floating_radius_area.collision_layer, true)

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
	if debug:
		draw_line(_ray.position, _ray.cast_to, Color(255, 0, 0), 1)
		draw_line(_ray.position, to_local(_float_point), Color(255, 209, 0), 1)

func _update_float_point(area):
	_ray.cast_to = _ray.to_local(area.global_position) # ray.cast_to is local
	_ray.force_raycast_update()
	if _ray.is_colliding():
		_float_point = _ray.get_collision_point()
	if debug:
		update()
	

func _process(delta):
	# cast to target area
	if _floating_radius_area:
		_update_float_point(_floating_radius_area)
