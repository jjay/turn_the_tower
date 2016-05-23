
extends "BaseBullet.gd"

signal hit_targets(targets)

var layer_mask
# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	var anim = get_node("AnimationPlayer")
	anim.play("shoot")
	print("Created laser")
	yield(anim, "finished")
	get_parent().remove_child(self)
	
	
func _fixed_process(delta):
	var state = get_world_2d().get_direct_space_state()
	var from = get_global_pos()
	var to = from + Vector2(0, 1000).rotated(get_rot())
	var exclude = []
	var explosion = preload("res://fx/explosion.tscn")
	while true:
		var result = state.intersect_ray(from, to, exclude, layer_mask, Physics2DDirectSpaceState.TYPE_MASK_AREA)
		if result.empty():
			break
		var target = result["collider"]
		target.take_damage(damage)
		exclude.append(target)
		
		var e = explosion.instance()
		get_parent().add_child(e)
		e.set_global_pos(result["position"])
		#print("Hitting " + str(result["collider"]))
		

	set_fixed_process(false)
	
	
func make_damage():
	print("Make damage with laser")
	set_fixed_process(true)

func setup(parent, unit):
	.setup(parent, unit)
	layer_mask = unit.get_collision_mask()
	
	


