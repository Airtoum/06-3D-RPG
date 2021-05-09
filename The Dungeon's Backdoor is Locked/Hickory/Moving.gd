extends "res://StateMachine/StateMachineState.gd"


func weightedSum(a1, w1, a2, w2):
	return a1 * w1 + a2 * w2

func start():
	pass
	
func physics_process(delta):
	var movement = myEnt.player_movement()
	var target_xz_vel = Vector3.ZERO
	if not myEnt.is_on_wall():
		target_xz_vel = movement * myEnt.ground_speed
	myEnt.velocity.x = weightedSum(myEnt.velocity.x, 0.9, target_xz_vel.x, 0.1)
	myEnt.velocity.z = weightedSum(myEnt.velocity.z, 0.9, target_xz_vel.z, 0.1)
	myEnt.turn_forward(1.0)
	if movement == Vector3.ZERO:
		SM.set_state("Idle")
	if Input.is_action_just_pressed("jump") and myEnt.is_was_on_floor() and myEnt.active:
		myEnt.velocity.y += myEnt.jump_speed
		SM.set_state("Aerial")
	if not myEnt.is_was_on_floor():
		SM.set_state("Aerial")
	myEnt.anim_ground(Vector2(myEnt.velocity.x, myEnt.velocity.z).length() / myEnt.ground_speed)
	myEnt.ground_or_air = weightedSum(myEnt.ground_or_air, 0.8, 0, 0.2)
	myEnt.anim_ground_or_air(myEnt.ground_or_air)
	
func end():
	pass
