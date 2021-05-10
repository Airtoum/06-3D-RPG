extends Area


onready var Dialog = $"/root/Dialogue"

export(String, MULTILINE) var raw_dialog
export(bool) var instant = false
export(bool) var only_once = true
export(bool) var silent = false
export(NodePath) var trigger_path
export(NodePath) var activate_path
export(bool) var needs_thing_exist = false
export(NodePath) var exist_thing_path
export(bool) var invert_exist_condition = false

var dialog = []
var receiver
var activatee
var exist_thing

# Called when the node enters the scene tree for the first time.
func _ready():
	$EditCube.visible = false
	if trigger_path != null:
		receiver = get_node_or_null(trigger_path)
	if activate_path != null:
		activatee = get_node_or_null(activate_path)
	if exist_thing_path != null:
		exist_thing = get_node_or_null(exist_thing_path)
	var dialog_array = raw_dialog.split("\n")
	for line in dialog_array:
		if line.begins_with(">>>icon"):
			dialog.append([ "icon" , int( line.right(8) ) ])
		elif line.begins_with(">>>trig"):
			dialog.append([ "trig" , line.right(8) , receiver ])
		elif line.begins_with(">>>actv"):
			dialog.append([ "trig" , line.right(8) , activatee ])
		else:
			dialog.append([ "text" , line ])


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_DialogTrigger_body_entered(body):
	if needs_thing_exist:
		exist_thing = get_node_or_null(exist_thing_path)
		if (exist_thing != null) == invert_exist_condition:
			return
	if body.is_in_group("Player") and body.health > 0:
		if not silent:
			$DialogSound.play()
		if instant:
			Dialog.show_dialog(dialog)
		else:
			$WaitTimer.start()
		if only_once and not $DialogSound.playing and $WaitTimer.is_stopped():
			queue_free()


func _on_WaitTimer_timeout():
	Dialog.show_dialog(dialog)
	if only_once and not $DialogSound.playing:
		queue_free()

func _on_DialogSound_finished():
	if only_once and $WaitTimer.is_stopped():
		queue_free()
