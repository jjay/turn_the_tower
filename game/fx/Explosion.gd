
extends Node2D

signal exploded
export (float) var duration = 2
export var autoplay = true
export var autoremove = true
onready var animator = get_node("AnimationPlayer")

func _ready():
	var animation = animator.get_animation("explosion")
	print(str(duration), str(animation.get_length()), str(duration/animation.get_length()))
	animator.set_speed(animation.get_length()/duration)
	if autoplay:
		explode()
	
	yield(animator, "finished")
	emit_signal("exploded")
	
	if autoremove:
		get_parent().remove_child(self)
	
func explode():
	animator.play("explosion")