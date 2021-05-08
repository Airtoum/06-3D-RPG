extends Spatial


var triggered = false


# Called when the node enters the scene tree for the first time.
func _ready():
	$Area/MeshInstance.visible = false
	$Darts.visible = false


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
	$Tween.interpolate_property($Darts, "transform:origin:x", pos, pos - 8, 0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
	$Tween.start()
	triggered = true


func _on_Tween_tween_all_completed():
	queue_free()
