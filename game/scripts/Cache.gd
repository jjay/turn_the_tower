
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

signal coins_changed(new_value)

export var start_coins = 4

onready var timer = get_node("Timer")
onready var coins = get_node("Coins")

var current_coins = 0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	current_coins = start_coins
	redraw_coins()
	yield(get_node("/root/Game"), "ready")
	timer.connect("timeout", self, "add_coin")
	timer.start()

func add_coin():
	if current_coins == 10:
		return
		 
	current_coins += 1
	redraw_coins()
	emit_signal("coins_changed", current_coins)

func remove_coins(value):
	if current_coins <= value:
		current_coins = 0
	else:
		current_coins -= value
	redraw_coins()
	emit_signal("coins_changed", current_coins)
	
func redraw_coins():
	var i = 1
	for coin in coins.get_children():
		coin.set_empty(i > current_coins)
		i += 1


