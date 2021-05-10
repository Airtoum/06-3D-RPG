extends Spatial

export var reverse_darts = false

var triggered = false


# Called when the node enters the scene tree for the first time.
func _ready():
	$Area/MeshInstance.visible = false
	$Darts.visible = false
	if reverse_darts:
		$Darts/Dart.flip_h = true
		$Darts/Dart2.flip_h = true
		$Darts/Dart3.flip_h = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area_body_entered(body):
	if body is GridMap or triggered:
		return
	if body.has_method("ouch"):
		body.ouch(1)
	var pos = $Darts.transform.origin.x
	$Darts.visible = true
	if reverse_darts:
		$Tween.interpolate_property($Darts, "transform:origin:x", pos - 8, pos, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
	else:
		$Tween.interpolate_property($Darts, "transform:origin:x", pos, pos - 8, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
	$Tween.start()
	triggered = true


func _on_Tween_tween_all_completed():
	queue_free()
