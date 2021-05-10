extends Spatial

onready var GlobalNode = get_node("/root/Global")
export(float) var period = 5.0
export(float) var phase_radians = 0.0
export(float) var amplitude_degrees = 45.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	rotation.z = deg2rad(amplitude_degrees) * sin( 2.0 * PI * GlobalNode.time / period + phase_radians )


func _on_Area_body_entered(body):
	if body is GridMap:
		return
	if body.has_method("ouch"):
		body.ouch(1)
