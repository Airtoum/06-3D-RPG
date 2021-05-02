extends Node

onready var SM = get_parent()
onready var myEnt = get_node("../..")

func _ready():
	yield(myEnt, "ready")
