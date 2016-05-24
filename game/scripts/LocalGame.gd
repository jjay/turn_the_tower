
extends Node

signal ready

onready var table = get_node("Table")
onready var gui = get_node("GUI")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	emit_signal("ready")


var have_loser = false
func set_loser(side):
	remove_child(get_node("Table"))
	remove_child(get_node("BlueHand"))
	remove_child(get_node("RedHand"))
	if have_loser:
		return
	have_loser = true
	gui.show()
	gui.set_text(side.capitalize() + " player LOSE!")
	#table.stop_game()
	gui.show_button()
	yield(gui.button, "pressed")
	var root = get_parent()
	root.remove_child(self)
	
	var new_game = preload("res://SelectGame.tscn").instance()
	root.add_child(new_game)