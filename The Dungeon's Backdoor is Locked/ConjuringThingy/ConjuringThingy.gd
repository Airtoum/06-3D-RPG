extends Spatial

export(PackedScene) var object
var conjured = []
export var max_limit = 1
export var conjure_rate = 4.0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Cooldown.wait_time = conjure_rate


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#func _physics_process(delta):
#	pass


func _on_Cooldown_timeout():
	if conjured.size() < max_limit:
		var new_thing = object.instance()
		new_thing.conjurer = self
		new_thing.transform.origin = transform.origin
		get_parent().add_child(new_thing)
		conjured.append(new_thing)
		
func forget(who):
	conjured.erase(who)
