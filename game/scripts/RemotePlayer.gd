extends Node

signal connected
signal found
signal ready
signal started
signal card_played(side, name, cell)
signal unit_rotated(cell, rotation)
signal rotation_complete(cell)


export var server_host = "127.0.0.1"
export var server_port = 1234

var sock
var buff = ""

onready var game = get_node("/root/Game")

func set_active(value):
	pass
	
func _ready():
	sock = StreamPeerTCP.new()
	sock.connect(server_host, server_port)
	set_process(true)
	
func _process(delta):
	var bytes = sock.get_available_bytes()
	if bytes > 0:
		buff += sock.get_string(bytes)
	
	if buff.length() >= 2 && buff.substr(buff.length() - 2, 2) == "\n\n":
		for msg in buff.strip_edges().split("\n\n"):
			process_message(msg)
		buff = ""
		
func process_message(msg):
	var packet = {}
	packet.parse_json(msg)
	print("server>" + str(packet))
	if packet.has("err") && packet["err"] != null:
		print("Server error: " + packet["err"])
	else:
		var method = "_handle_" + packet["msg"]
		if has_method(method):
			callv(method, packet["args"])
		else:
			print("Can't handle method " + method + " (method not found)")

		
func send(msg, args=[]):
	var packet = { "msg": msg, "args": args }
	sock.put_utf8_string(packet.to_json() + "\n\n")

func send_to_opponent(msg, args=[]):
	var packet = { "msg": msg, "args": args, "broadcast": true }
	sock.put_utf8_string(packet.to_json() + "\n\n")
	
func _handle_info(player_id):
	emit_signal("connected")
	
func _handle_opponent_info(player_id):
	emit_signal("found")

func _handle_start_game(local_player_side):
	emit_signal("ready")
	
func send_ready():
	send("ready")
	
func put_unit(side, name, index):
	send_to_opponent("card_played", [name, 19 - index])

func _handle_card_played(name, index):
	emit_signal("card_played", "blue", name, index)

func rotate_unit(cell, rotation):
	send_to_opponent("unit_rotated", [19 - cell, rotation + PI])

func _handle_unit_rotated(cell, rotation):
	emit_signal("unit_rotated", cell, rotation)
		
func send_win():
	send_to_opponent("win")
func send_lose():
	send_to_opponent("lose")

func _handle_win():
	game.set_loser("blue")

func _handle_lose():
	game.set_loser("red")

func on_rotation_complete(cell):
	send_to_opponent("rotation_complete", [19-cell])
func _handle_rotation_complete(cell):
	emit_signal("rotation_complete", cell)