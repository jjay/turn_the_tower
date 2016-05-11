
extends Node2D

onready var missed = get_node("Missed")
onready var damage = get_node("Damage")
onready var animation = get_node("Animation")

var _missed_life = 2.0
var _total_life = 5.0
var _damage_value = 7.0
	
func set_total_life(value):
	_total_life = value
	redraw()
	
func set_missed_life(value):
	_missed_life = min(value, _total_life)
	
	redraw()

func add_missed_life(value):
	_missed_life += value
	if _missed_life > _total_life:
		_missed_life = _total_life
	redraw()

func set_damage_value(value):
	_damage_value = value
	redraw()
	
func redraw():
	print("Redraw healthbar " + str(_total_life) + ", " + str(_missed_life) + ", " + str(_damage_value))
	var miss_border = 20
	if _missed_life > 0:
		missed.show()
		var miss_size = 40 * _missed_life / _total_life
		miss_border = 20 - miss_size
		var poly = missed.get_polygon()
		poly[0].x = miss_border
		poly[3].x = miss_border
		missed.set_polygon(poly)
	else:
		missed.hide()
			
	if _damage_value > 0:
		var poly = damage.get_polygon()
		var dmg = min(_total_life - _missed_life, _damage_value)
		var damage_border = miss_border - 40 * dmg / _total_life;
		poly[0].x = damage_border
		poly[1].x = miss_border
		poly[2].x = miss_border
		poly[3].x = damage_border
		damage.set_polygon(poly)
		animation.play("damage")
		damage.show()
	else:
		damage.hide()
		
	


