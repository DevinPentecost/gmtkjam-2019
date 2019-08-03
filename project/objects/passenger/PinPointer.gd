extends Sprite

export(NodePath) var player
onready var _player = get_node(player) 
var target_pin = null

onready var viewport = get_viewport()
var showing = false

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target_pin and _player:
		
		#Just point from the player to it
		#TODO: This is a disaster
		var difference = target_pin.global_position - _player.global_position
		var angle = difference.angle()
		rotation = -angle
		global_position = _player.global_position + difference.normalized() * 100
		

func _show(show):
	showing = show
		
	#It's off screen
	$Tween.stop_all()
	var target_modulate = modulate
	target_modulate.a = 1.0 if show else 0.0
	$Tween.interpolate_property(self, "modulate", modulate, target_modulate, 1, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.start()
