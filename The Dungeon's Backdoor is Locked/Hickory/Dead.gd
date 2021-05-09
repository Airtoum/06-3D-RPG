extends "res://StateMachine/StateMachineState.gd"


var dead_timer = 0.0
var respawn_time = 4.0

func weightedSum(a1, w1, a2, w2):
	return a1 * w1 + a2 * w2

func start():
	pass
	
func physics_process(delta):
	var target_xz_vel = Vector3.ZERO
	myEnt.velocity.x = weightedSum(myEnt.velocity.x, 0.9, target_xz_vel.x, 0.1)
	myEnt.velocity.z = weightedSum(myEnt.velocity.z, 0.9, target_xz_vel.z, 0.1)
	myEnt.anim_dead(1)
	dead_timer += delta
	if dead_timer > respawn_time:
		get_tree().reload_current_scene()
		# I don't really like this solution to respawning, but it's quick and easy
		# What I would prefer would probably be reset to last checkpoint or something, but even then you'll have
		#    to skip through dialogue
	
func end():
	pass
