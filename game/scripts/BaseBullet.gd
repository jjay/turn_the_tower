tool
extends Area2D

export (float) var start_speed = 0
export (float) var max_speed = 0
export (float) var acceleration = 0
export (float) var damage_radius = 0 setget set_damage_radius

var damage
var speed
var _last_aoe_pos

onready var aoe = get_node("AoeDamage")
onready var explosion = get_node("Explosion")
onready var view = get_node("View")


func _ready():
	if get_tree().is_editor_hint():
		_last_aoe_pos = aoe.get_pos()
		set_process(true)
		return
	speed = min(start_speed, max_speed)
	connect("area_enter", self, "make_damage")
	
func set_damage_radius(new_value):
	damage_radius = new_value
	update()
	

func _draw():
	if get_tree().is_editor_hint():
		draw_circle(aoe.get_pos(), damage_radius, Color("65ef4b30"));


func _process(delta):
	if get_tree().is_editor_hint() && _last_aoe_pos != aoe.get_pos():
		_last_aoe_pos = aoe.get_pos()
		update()
	else:
		speed = clamp(acceleration * delta + speed, 0, max_speed)
		var new_dir = Vector2(0, 1).rotated(get_rot()) * delta * speed
		translate(new_dir)

func setup(parent, unit):
	set_process(true)
	damage = unit.damage
	max_speed = unit.bullet_speed
	set_collision_mask(unit.get_collision_mask())
	set_pos(unit.get_table_pos())
	set_rot(unit.get_rot())
	parent.add_child(self)
	
func make_damage(unit):

	if damage_radius == 0:
		unit.take_damage(damage)		
	else: # find all enemy units in radius
		var sq_radius = pow(damage_radius + 25, 2)
		var pos = aoe.get_global_pos()
		for u in get_tree().get_nodes_in_group(unit.unit_side + "_unit"):
			if pos.distance_squared_to(unit.get_global_pos()) < sq_radius:
				u.take_damage(damage)
	destroy()
		
	
func destroy():
	if !is_inside_tree():
		return
	set_process(false)
	view.hide()
	explosion.explode()
	yield(explosion, "exploded")
	get_parent().remove_child(self)
	

