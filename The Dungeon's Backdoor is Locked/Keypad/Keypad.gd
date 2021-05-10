extends StaticBody


onready var global = get_node("/root/Global")
export(NodePath) var my_door_path
var my_door = null


# Called when the node enters the scene tree for the first time.
func _ready():
	if my_door_path != null:
		my_door = get_node(my_door_path)


func do_the_keypad():
	$Camera.current = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_Keypad_input_event(camera, event, click_position, click_normal, shape_idx):
	#print(event.as_text())
	if event is InputEventMouseButton and event.pressed and $Camera.current:
		print("click!")
		get_node("/root/Dialogue").show_dialog([
			["icon", 0],
			["text", "I don't have any hands..."],
			["trig", "post_keypad", global.player]
		])
		
func latch_interact():
	my_door.queue_free()
	get_node("/root/Dialogue").show_dialog([
			["icon", 8],
			["text", "Done!"]
		])
