extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_button_leaderboard_pressed():
	OS.shell_open("http://chilidog.faith/lb/ld44")
	pass # Replace with function body.


func _on_button_start_pressed():
	get_tree().change_scene("res://main_scenes/game_scene.tscn")
	pass # Replace with function body.