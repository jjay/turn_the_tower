
extends "Unit.gd"
export var side = "red"

func remove():
	game.set_loser(side)

func get_table_pos():
	return get_pos()
