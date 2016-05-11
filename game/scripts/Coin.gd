
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

onready var foreground = get_node("Foreground")


func set_empty(value):
	if value:
		foreground.set_opacity(0)
	else:
		foreground.set_opacity(1)


