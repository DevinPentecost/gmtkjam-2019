extends Node2D

var passenger_message_array = []
var is_processing_message = false

onready var tween_vertical_pos = $texture_all_elements/tween_vertical_pos
onready var tween_text_visible = $texture_all_elements/texture_text_container/texture_text_border/richtext_message/tween_text_visible

var is_waiting_for_vertical = false
var is_waiting_for_text = false

func append_passenger_message(passenger_message):
	passenger_message_array.append(passenger_message)
	_process_next_message()
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process_next_message():
	# We are going to set up the tweens to do all the work for us!
	if is_processing_message == true or is_waiting_for_vertical == true or is_waiting_for_text == true:
		# Can't process if already processing!
		return
	
	# Do we have anything in the array to process?
	if passenger_message_array.size() == 0:
		return
	
	# OK, we want to apply the portrait and the message to the elements
	$texture_all_elements/texture_portrait_border/texture_portrait.texture = passenger_message_array[0]["portrait_texture"]
	$texture_all_elements/texture_text_container/texture_text_border/richtext_message.text = passenger_message_array[0]["text_message"]
	
	tween_vertical_pos.remove_all()
	tween_text_visible.remove_all()
	
	tween_vertical_pos.interpolate_property($texture_all_elements, 'rect_position', Vector2(0, 640), Vector2(0, 390), 1.33, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween_text_visible.interpolate_property($texture_all_elements/texture_text_container/texture_text_border/richtext_message, 'percent_visible', 0, 1, 2.66, Tween.TRANS_LINEAR, Tween.EASE_IN)
	
	tween_vertical_pos.set_active(true)
	tween_text_visible.set_active(true)
	
	is_processing_message = true
	is_waiting_for_vertical = true
	is_waiting_for_text = true
	

func _check_hide_message():
	# When both tweens are done we can set the timer to clear the screen
	if is_waiting_for_text == false and is_waiting_for_vertical == false:
		$timer_hide_delay.start(1.66)
	

func _on_tween_vertical_pos_tween_all_completed():
	is_waiting_for_vertical = false
	tween_vertical_pos.remove_all()
	
	# We might want to hide this message now!
	if is_processing_message == true:
		_check_hide_message()
	else:
		# Actually, maybe we want to queue up a new message?
		passenger_message_array.pop_front()
		_process_next_message()

func _on_tween_text_visible_tween_all_completed():
	is_waiting_for_text = false
	tween_text_visible.remove_all()
	_check_hide_message()

func _on_timer_hide_delay_timeout():
	# Time to start hiding!
	is_waiting_for_vertical = true
	is_processing_message = false
	
	tween_vertical_pos.interpolate_property($texture_all_elements, 'rect_position', Vector2(0, 390), Vector2(0, 640), 0.33, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween_vertical_pos.set_active(true)