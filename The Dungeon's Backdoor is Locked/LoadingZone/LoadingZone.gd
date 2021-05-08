extends Area

export(PackedScene) var level


# Called when the node enters the scene tree for the first time.
func _ready():
	$EditCube.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

	

func _on_LoadingZone_body_entered(body):
	if body.is_in_group("Player"):
		get_tree().change_scene(level.resource_path)
