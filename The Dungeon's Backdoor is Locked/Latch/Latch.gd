extends Spatial


export var player_path : NodePath
onready var player = get_node_or_null(player_path)

var velocity = Vector3.ZERO
var fast_speed = 8.0
var slow_speed = 2.0
var very_fast_speed = 15.0

export var flailing = false
var flail_out = true
var flail_center
var interacting = false
export(NodePath) var interact_with_path
var interact_with = null

# Called when the node enters the scene tree for the first time.
func _ready():
	flail_center = transform.origin
	if interact_with_path != null:
		interact_with = get_node(interact_with_path)

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
		var target = player
		var dist_scale = 1.0
		if interacting:
			target = interact_with
			dist_scale = 0.2
		if target != null:
			var disp = target.transform.origin - transform.origin
			if distance_to(target) < 7 * dist_scale:
				go_slow()
				speed = sigmoid(distance_to(target), fast_speed, 4.0, 5.0)
				if interacting and $InteractTimer.is_stopped():
					$InteractTimer.start()
			elif distance_to(target) < 25 * dist_scale:
				go_fast()
				speed = fast_speed
			else:
				go_very_fast()
				speed = very_fast_speed
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
	
func go_very_fast():
	$Front.play("FrontVeryFast")
	$Back.play("BackVeryFast")

func stop_flailing():
	flailing = false
	
func interact():
	interacting = true

func _on_InteractTimer_timeout():
	interact_with.latch_interact()
	interacting = false
