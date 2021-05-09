extends RigidBody


var collisions = 0
var max_bounces = 3


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_FireOrb_body_entered(body):
	# ignore collisions that happen very close to each other temporally
	if not $TimeSinceBounce.is_stopped():
		return
	collisions += 1
	$TimeSinceBounce.start()
	#print(collisions)
	if body.has_method("ouch") and not body.is_in_group("Player"):
		body.ouch(1)
	if collisions >= max_bounces:
		die()

func ouch(damage):
	die()
	
func die():
	mode = RigidBody.MODE_STATIC
	$CollisionShape.disabled = true
	queue_free()
