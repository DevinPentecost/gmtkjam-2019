extends Area2D

signal pin_reached

#Tweening stuff
var height_offset = 100.0
var tween_time = 1.0
var target_position = Vector2(0, 0)
var _showing = false

# Called when the node enters the scene tree for the first time.
func _ready():
	#Set up screen notifiers on the pin
	var _screen_notifier = VisibilityNotifier2D.new()
	add_child(_screen_notifier)
	_screen_notifier.connect("screen_entered", self, "screen_entered")
	_screen_notifier.connect("screen_exited", self, "screen_exited")

func screen_entered():
	if _showing:
		print("im on the screen, remove pointer")

func screen_exited():
	if _showing:
		print("im off the screen, show pointer")

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
