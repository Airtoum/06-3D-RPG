extends Control

var command_index = 0
var current_commands = []

var icon_array = [
	"res://icon.png"
]


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	if get_node_or_null("/root/Dialogue") != null:
		show_dialog([
			["Icon", 0], 
			["Text", "Let's all go to the malt shop!"], 
			["Text", "Watch us swooce right in!"]
			])
		print("yo")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func show_dialog(commands):
	command_index = 0
	current_commands = commands
	process_commands()
	
func _input(event):
	if event.is_action_pressed("jump"):
		process_commands()
	
func process_commands():
	visible = true
	var pause = false
	while not pause and command_index < current_commands.size():
		var cmd = current_commands[command_index]
		match cmd[0]:
			"Icon":
				$Border/Icon.texture = load(icon_array[cmd[1]])
			"Text":
				$Border/Text.text = cmd[1]
				pause = true
		command_index += 1
	if command_index >= current_commands.size() and not pause:
		clear_commands()

func clear_commands():
	command_index = 0
	current_commands = []
	visible = false
