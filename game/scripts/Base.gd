
extends "Unit.gd"
export (Color) var base_color

func _ready():
	sprite.set_modulate(base_color)
func remove():
	game.set_loser(unit_side)

func get_table_pos():
	return get_pos()

func update_texture():
	pass