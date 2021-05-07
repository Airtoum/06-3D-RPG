extends Area


onready var Dialog = $"/root/Dialogue"

export(String, MULTILINE) var raw_dialog
export(bool) var instant = false
export(bool) var only_once = true
export(NodePath) var receiver_path

var dialog = []
var receiver

# Called when the node enters the scene tree for the first time.
func _ready():
	$EditCube.visible = false
	if receiver_path != null:
		receiver = get_node_or_null(receiver_path)
	var dialog_array = raw_dialog.split("\n")
	for line in dialog_array:
		if line.begins_with(">>>icon"):
			dialog.append([ "icon" , int( line.right(8) ) ])
		elif line.begins_with(">>>trig"):
			dialog.append([ "trig" , line.right(8) , receiver ])
		else:
			dialog.append([ "text" , line ])


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_DialogTrigger_body_entered(body):
	if body.is_in_group("Player"):
		$DialogSound.play()
		if instant:
			Dialog.show_dialog(dialog)
		else:
			$WaitTimer.start()


func _on_WaitTimer_timeout():
	Dialog.show_dialog(dialog)
	if only_once and not $DialogSound.playing:
		queue_free()

func _on_DialogSound_finished():
	if only_once and $WaitTimer.is_stopped():
		queue_free()
