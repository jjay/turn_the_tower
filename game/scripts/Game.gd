
extends Node

signal ready
# member variables here, example:
# var a=2
# var b="textvar"
onready var hand = get_node("Hand")
onready var table = get_node("Table")
onready var cache = get_node("Cache")
onready var gui = get_node("GUI")
onready var local_player = get_node("LocalPlayer")
onready var remote_player = get_node("RemotePlayer")

func _ready():
	remote_player.connect("card_played", table, "put_unit")
	table.connect("card_played", remote_player, "put_unit")
	remote_player.connect("unit_rotated", table, "rotate_unit")
	table.connect("unit_rotated", remote_player, "rotate_unit")
	remote_player.connect("rotation_complete", table, "on_rotation_complete")
	table.connect("rotation_complete", remote_player, "on_rotation_complete")
		
	gui.show_body()
	gui.hide_button()
	gui.set_text("Connecting...")
	yield(remote_player, "connected")
	gui.set_text("Finding opponent")
	yield(remote_player, "found")
	gui.show_button()
	gui.set_text("Press to start!")
	yield(gui.button, "pressed")
	gui.hide_button()
	remote_player.send("ready")
	gui.set_text("Waiting for opponent")
	yield(remote_player, "ready")
	gui.hide()
	
	
	
	# Called every time the node is added to the scene.
	# Initialization here
	emit_signal("ready")
	
var have_loser = false
func set_loser(side):
	if have_loser:
		return
	have_loser = true
	gui.show()
	if side == "red":
		remote_player.send_win()
		gui.set_text("You LOOOSE!!!")
	else:
		remote_player.send_lose()
		gui.set_text("You win!")
	
	table.stop_game()
	gui.show_button()
	yield(gui.button, "pressed")
	var root = get_parent()
	root.remove_child(self)
	var new_game = preload("res://SelectGame.tscn").instance()
	root.add_child(new_game)

