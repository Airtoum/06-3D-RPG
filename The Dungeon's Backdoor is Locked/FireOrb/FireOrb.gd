extends RigidBody


var collisions = 0
var max_bounces = 3
var true_gravity = 6.0
var start_gravity = 2.0


# Called when the node enters the scene tree for the first time.
func _ready():
	gravity_scale = start_gravity


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_FireOrb_body_entered(body):
	# do not ignore dealing damage if you just collided with something
	if body.has_method("ouch") and not body.is_in_group("Player"):
		body.ouch(1)
	if body.is_in_group("Burnable"):
		print(body)
		if body.has_method("die"):
			body.die()
		else:
			body.queue_free()
	# ignore collisions that happen very close to each other temporally
	if not $TimeSinceBounce.is_stopped():
		return
	collisions += 1
	$TimeSinceBounce.start()
	#print(collisions)
	gravity_scale = true_gravity
	
	if collisions >= max_bounces:
		die()

func ouch(damage):
	die()
	
func die():
	mode = RigidBody.MODE_STATIC
	$CollisionShape.disabled = true
	queue_free()
