extends Node

var time = 0.0

func _process(delta):
	if Input.is_action_pressed("quit"):
		get_tree().quit()

func _physics_process(delta):
	time += delta
