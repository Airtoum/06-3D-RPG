extends Spatial


export var player_path : NodePath
onready var player = get_node_or_null(player_path)

var velocity = Vector3.ZERO
var fast_speed = 5.0
var slow_speed = 2.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	var speed
	if player != null:
		var disp = player.transform.origin - transform.origin
		if distance_to(player) < 7:
			go_slow()
			speed = sigmoid(distance_to(player), fast_speed, 4.0, 5.0)
		else:
			go_fast()
			speed = fast_speed
		velocity = (disp).normalized() * speed
		rotation.y = Vector2(disp.x, -disp.z).angle() + 90
	transform.origin += velocity * delta

func distance_to(spatial):
	return (transform.origin - spatial.transform.origin).length()

func sigmoid(x, height, offset, steepness): #this isn't quite exactly what I want but that's just the mathmatical perfectionist in me
	return height / (  1 + pow( VisualScriptMathConstant.MATH_CONSTANT_E, (steepness * (offset - x)) )  )
	# graph I made of this https://www.desmos.com/calculator/lyxdixyn7g
	
func go_fast():
	$Front.play("FrontFast")
	$Back.play("BackFast")

func go_slow():
	$Front.play("Front")
	$Back.play("Back")
