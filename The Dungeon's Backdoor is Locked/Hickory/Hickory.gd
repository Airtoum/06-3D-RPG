extends KinematicBody

export var hickory_face : SpatialMaterial
onready var SM = $StateMachine

var mouse_sensitivity = (1.0 / 5.0) * (PI / 180) # 1 degree per 5 pixels
var velocity = Vector3.ZERO
var gravity = Vector3(0.0, -45.0, 0.0)
var target_angle = 0
var ground_speed = 13.0
var aerial_speed = 13.0
var jump_speed = 19.0
var ground_or_air = 0.0
onready var face_material = hickory_face.duplicate()

var active = true
var look_at_camera = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$Model/Armature/Skeleton/HickoryBody.material_override = face_material
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		$PivotA.rotate_y(-event.relative.x * mouse_sensitivity)
		$PivotA/PivotB.rotate_x(event.relative.y * mouse_sensitivity * 0.4) 
		#looking vertically shouldn't be something the player should be worrying about too much

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Label.text = SM.state_name
	if look_at_camera:
		var uv1 = face_material.get("uv1_offset")
		var revolutions = ( -$Model.rotation_degrees.y / 360 + $PivotA.rotation_degrees.y / 360)
		face_material.set("uv1_offset", Vector3( revolutions + 0.5 - 0.042 , uv1.y, uv1.z))
	
func _physics_process(delta):
	active = not get_node("/root/Dialogue").active
	if is_on_floor():
		#do not slide down slopes https://godotengine.org/qa/16765/more-ideas-how-prevent-slope-slide-down-with-kinematicbody2d
		velocity += gravity.y * get_floor_normal() * delta
	else:
		velocity += gravity * delta
	velocity = move_and_slide(velocity, Vector3.UP, false)
	
func player_movement():
	if not active:
		return Vector3.ZERO
	#this is nasty but it works
	var acc = Vector2.ZERO
	if Input.is_action_pressed("up"):
		acc += Vector2(0,-1).rotated($PivotA.rotation_degrees.y * PI / 180)
	if Input.is_action_pressed("down"):
		acc += Vector2(0,1).rotated($PivotA.rotation_degrees.y * PI / 180)
	if Input.is_action_pressed("left"):
		acc += Vector2(1,0).rotated($PivotA.rotation_degrees.y * PI / 180)
	if Input.is_action_pressed("right"):
		acc += Vector2(-1,0).rotated($PivotA.rotation_degrees.y * PI / 180)
	if acc != Vector2.ZERO:
		var result = -acc.normalized()
		if Input.is_action_pressed("sprint"):
			result *= 2
		target_angle = result.angle() * 180 / PI - 90
		#$Model.rotation_degrees.y += 1
		#the model is where the player's rotation is going to be "stored"
		return Vector3(-result.x, 0.0, result.y)
	return Vector3.ZERO

func turn_forward(power):
	var diff_angle = target_angle - $Model.rotation_degrees.y
	var reverse_turn = 1.0
	if abs(diff_angle) > 180:
		reverse_turn = -1.0
	if diff_angle > 0:
		$Model.rotation_degrees.y += 10 * reverse_turn * power
	else:
		$Model.rotation_degrees.y -= 10 * reverse_turn * power
	if abs(diff_angle) <= 10 or abs(diff_angle) >= 350:
		$Model.rotation_degrees.y = target_angle
		
func anim_ground(value):
	$Model/AnimationTree.set("parameters/Idle_Run/blend_amount", value)

func anim_air(value):
	$Model/AnimationTree.set("parameters/Vertical/blend_amount", value)
	
func anim_ground_or_air(value):
	$Model/AnimationTree.set("parameters/Ground_Air/blend_amount", value)
	
func anim_dead(value):
	$Model/AnimationTree.set("parameters/Dead/blend_amount", value)

func play_animation(anim, offset):
	$Model/AnimationPlayer.play(anim)
	$Model/AnimationPlayer.seek(offset, true)
	# this does nothing but it's too small a detail to worry about :(
