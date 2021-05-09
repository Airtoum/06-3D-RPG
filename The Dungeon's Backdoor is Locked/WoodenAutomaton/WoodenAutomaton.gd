extends KinematicBody

export var player_path : NodePath
onready var player = get_node_or_null(player_path)

var gravity = Vector3(0.0, -45.0, 0.0)
var velocity = Vector3.ZERO
var health = 2
var wandering = true
var move = Vector3.ZERO
var wander_speed = 1.0
var chase_speed = 3.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _physics_process(delta):
	velocity += gravity * delta
	wandering = distance_to(player) > 20
	if wandering:
		if is_on_wall():
			move = Vector3.ZERO
			print("Redirecting!")
		if move == Vector3.ZERO and wandering:
			move = Vector3.FORWARD.rotated(Vector3.UP, rand_range(0.0, 2 * PI)) * wander_speed
	else:
		move = (player.transform.origin - transform.origin).normalized() * chase_speed
	rotation.y = atan2(-move.z, move.x) + PI/2
	velocity.x = move.x
	velocity.z = move.z
	velocity = move_and_slide(velocity, Vector3.UP, false)
	
func distance_to(spatial):
	return (transform.origin - spatial.transform.origin).length()	

func ouch(damage):
	health -= 1
	if health <= 0:
		die()
		
func die():
	queue_free()
