
extends Area2D

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	connect("body_enter", self, "destroy_body")

func destroy_body(body):
	print("Destroy body")
	body.get_parent().remove_child(body)


