extends Control

var command_index = 0
var current_commands = []
var active = false

export(Array, Texture) var icon_array


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
#	show_dialog([
#		["Icon", 0], 
#		["Text", "Let's all go to the malt shop!"], 
#		["Text", "Watch us swooce right in!"]
#		])


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func show_dialog(commands):
	command_index = 0
	current_commands = commands
	process_commands()
	active = true
	
func _input(event):
	if active and event.is_action_pressed("jump"):
		process_commands()
	if active and event.is_action_pressed("skip_all"):
		clear_commands()
	
func process_commands():
	visible = true
	var pause = false
	while not pause and command_index < current_commands.size():
		var cmd = current_commands[command_index]
		print(cmd, pause)
		match cmd[0]:
			"icon":
				$Border/Icon.texture = icon_array[cmd[1]]
			"trig":
				cmd[2].call_deferred(cmd[1])
			"text":
				$Border/Text.text = cmd[1]
				pause = true
		command_index += 1
	if command_index >= current_commands.size() and not pause:
		clear_commands()

func clear_commands():
	command_index = 0
	current_commands = []
	visible = false
	$Reactivate.start()


func _on_Reactivate_timeout():
	active = false
