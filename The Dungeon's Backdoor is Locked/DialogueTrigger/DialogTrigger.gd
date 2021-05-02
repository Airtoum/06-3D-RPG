extends Area


onready var Dialog = $"."

export(String, MULTILINE) var raw_dialog

var dialog = []


# Called when the node enters the scene tree for the first time.
func _ready():
	var dialog_array = raw_dialog.split("\n")
	for line in dialog_array:
		if line.begins_with(">>>icon"):
			dialog.append([ "icon" , int( line.right(7) ) ])
		else:
			dialog.append([ "text" , line ])


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_DialogTrigger_body_entered(body):
	if body.is_in_group("Player"):
		Dialog.show_dialog(dialog)
