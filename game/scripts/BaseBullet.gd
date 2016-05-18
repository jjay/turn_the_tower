extends Area2D

export (float) var start_speed
export (float) var max_speed
export (float) var acceleration

var damage
var targets
var speed


onready var explosion = get_node("Explosion")
onready var view = get_node("View")

func _ready():
	speed = min(start_speed, max_speed)

func _process(delta):
	speed = clamp(acceleration * delta + speed, 0, max_speed)
	var new_dir = Vector2(0, 1).rotated(get_rot()) * delta * speed
	translate(new_dir)

func setup_targets(parent, unit, new_targets):
	set_process(true)
	targets = new_targets
	damage = unit.damage
	set_collision_mask(unit.get_collision_mask())
	set_pos(unit.get_table_pos())
	look_at(targets[0].get_table_pos())
	parent.add_child(self)
	
	
func destroy():
	set_process(false)
	view.hide()
	explosion.explode()
	yield(explosion, "exploded")
	get_parent().remove_child(self)
	

