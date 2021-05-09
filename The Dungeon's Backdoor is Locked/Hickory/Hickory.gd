extends KinematicBody

export var hickory_face : SpatialMaterial
onready var SM = $StateMachine
onready var FireOrb = load("res://FireOrb/FireOrb.tscn")
export var HitPointIcon : Texture
export var FireOrbIcon : Texture
onready var Slot = load("res://Hickory/Slot.tscn")

var mouse_sensitivity = (1.0 / 5.0) * (PI / 180) # 1 degree per 5 pixels
var velocity = Vector3.ZERO
var gravity = Vector3(0.0, -45.0, 0.0)
var target_angle = 0
var ground_speed = 13.0
var aerial_speed = 13.0
var jump_speed = 19.0
var ground_or_air = 0.0
onready var face_material = hickory_face.duplicate()
var health = 3
var was_on_floor = false
export var tome_of_fire_orb = false
var fire_orbs = 0

var active = true
var look_at_camera = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if tome_of_fire_orb:
		$FireOrbTimer.start()
	update_inventory()
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
		#velocity += gravity * delta
	else:
		velocity += gravity * delta
	#if is_on_wall():
	#	velocity = Vector3(0.0, velocity.y, 0.0)
	#print("is_on_wall: " + str(is_on_wall()) + " is_on_floor: " + str(is_on_floor()) + " velocity: " + str(velocity.y) + " get_floor_normal.y: " + str(get_floor_normal().y) + " y_position: " + str(transform.origin.y) +  " State: " + SM.state_name)
	was_on_floor = is_on_floor()
	velocity = move_and_slide(velocity, Vector3.UP, true, 4)
	shoot_fire_orb()
	
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
			anim_run_speed(3.4)
			result *= 2
		else:
			anim_run_speed(1.7)
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
		
func shoot_fire_orb():
	if active:
		if Input.is_action_just_pressed("fire") and fire_orbs > 0:
			var fire_orb = FireOrb.instance()
			fire_orb.transform.origin = $Model/FireOrbThrow.global_transform.origin
			fire_orb.rotation.y = rotation.y
			fire_orb.add_central_force(($Model/FireOrbThrow.global_transform.origin - global_transform.origin).normalized() * 4000.0)
			var spinniness = 27 * 0.4
			fire_orb.angular_velocity = spinniness * Vector3( 0 * rand_range(-PI, PI), 0 * rand_range(-PI, PI), 1 * rand_range(-PI, PI)).rotated(Vector3.UP, $Model.rotation.y)
			get_parent().get_node("Stuff").add_child(fire_orb)
			fire_orbs -= 1
			update_inventory()
		
func ouch(amount):
	$Damage.play()
	health -= amount
	if health <= 0:
		$Damage.pitch_scale = 0.8
		$Damage.play()
		die()
	update_inventory()
		
func die():
	anim_dead(1)
		
func anim_ground(value):
	$Model/AnimationTree.set("parameters/Idle_Run/blend_amount", value)

func anim_air(value):
	$Model/AnimationTree.set("parameters/Vertical/blend_amount", value)
	
func anim_ground_or_air(value):
	$Model/AnimationTree.set("parameters/Ground_Air/blend_amount", value)
	
func anim_dead(value):
	$Model/AnimationTree.set("parameters/Dead/blend_amount", value)
	
func anim_run_speed(value):
	$Model/AnimationTree.set("parameters/Run_Speed/scale", value)

func play_animation(anim, offset):
	$Model/AnimationPlayer.play(anim)
	$Model/AnimationPlayer.seek(offset, true)
	# this does nothing but it's too small a detail to worry about :(

func is_was_on_floor(): # this is necessary to absolve a stupid bug
	return is_on_floor() or was_on_floor

func update_inventory():
	var index = 0
	for h in range(0, health):
		inv_add_or_update(index, HitPointIcon)
		index += 1
	for f in range(0, fire_orbs):
		inv_add_or_update(index, FireOrbIcon)
		index += 1
	while index < $UI/Inventory.get_child_count():
		$UI/Inventory.remove_child($UI/Inventory.get_child($UI/Inventory.get_child_count() - 1))
		
func inv_add_or_update(i, texture):
	if $UI/Inventory.get_child_count() <= i:
		var slot = Slot.instance()
		slot.texture = texture
		slot.position.x = 50 * i
		$UI/Inventory.add_child(slot)
	else:
		$UI/Inventory.get_child(i).texture = texture
		
func get_tome_of_fire_orb():
	fire_orbs = 5
	tome_of_fire_orb = true
	update_inventory()
	$FireOrbTimer.start()

func _on_FireOrbTimer_timeout():
	if tome_of_fire_orb and fire_orbs < 5:
		fire_orbs += 1
		update_inventory()
