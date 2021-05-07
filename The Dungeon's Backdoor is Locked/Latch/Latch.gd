extends Spatial


export var player_path : NodePath
onready var player = get_node_or_null(player_path)

var velocity = Vector3.ZERO
var fast_speed = 5.0
var slow_speed = 2.0

export var flailing = false
var flail_out = true
var flail_center

# Called when the node enters the scene tree for the first time.
func _ready():
	flail_center = transform.origin


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	var speed
	if flailing and not $Tween.is_active():
		velocity = Vector3.ZERO
		var flail_speed = 0.6
		if flail_out:
			var r = 6 # flail radius
			var flail_target = transform.origin + Vector3(rand_range(-r, r),rand_range(-r/2, r),rand_range(-r, r))
			var angle = rand_range(-PI, PI)
			$Tween.interpolate_property(self, "transform:origin", transform.origin, flail_target, flail_speed, Tween.TRANS_QUAD, Tween.EASE_OUT)
			$Tween.interpolate_property(self, "rotation:y", rotation.y, angle, flail_speed, Tween.TRANS_QUAD, Tween.EASE_OUT)
			flail_out = false
			$Tween.start()
		else:
			var angle = rand_range(-PI, PI)
			$Tween.interpolate_property(self, "transform:origin", transform.origin, flail_center, flail_speed, Tween.TRANS_QUAD, Tween.EASE_OUT)
			$Tween.interpolate_property(self, "rotation:y", rotation.y, angle, flail_speed, Tween.TRANS_QUAD, Tween.EASE_OUT)
			flail_out = true
			$Tween.start()
	elif not flailing:
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

func stop_flailing():
	flailing = false
