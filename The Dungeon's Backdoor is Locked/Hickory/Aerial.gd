extends "res://StateMachine/StateMachineState.gd"


func weightedSum(a1, w1, a2, w2):
	return a1 * w1 + a2 * w2

func start():
	pass
	
func physics_process(delta):
	var movement = myEnt.player_movement()
	var target_xz_vel = myEnt.player_movement() * myEnt.aerial_speed
	myEnt.velocity.x = weightedSum(myEnt.velocity.x, 0.9, target_xz_vel.x, 0.1)
	myEnt.velocity.z = weightedSum(myEnt.velocity.z, 0.9, target_xz_vel.z, 0.1)
	myEnt.turn_forward(0.3)
	if myEnt.is_on_floor():
		if movement == Vector3.ZERO:
			SM.set_state("Idle")
		else:
			SM.set_state("Moving")
	myEnt.anim_air(clamp((myEnt.velocity.y + 30) / 10, 0.3, 1.0))
	myEnt.ground_or_air = weightedSum(myEnt.ground_or_air, 0.8, 1, 0.2)
	myEnt.anim_ground_or_air(myEnt.ground_or_air)
	
func end():
	if SM.state_name == "Idle":
		myEnt.play_animation("Idle", 0.7)
