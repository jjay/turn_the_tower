
extends Area2D

# member variables here, example:
# var a=2
# var b="textvar"
onready var game = get_node("/root/Game")
onready var container = get_node("Container")
onready var preview = get_node("Preview")

export (int, FLAGS) var unit_collision_layers
export (int, FLAGS) var unit_collision_mask
export (String, "red", "blue") var side

var hovered_card

func _ready():
	add_to_group(side + "_cell")
	
func _input_event(viewport, event, shape_idx):
	if container.get_child_count() != 0:
		return
	if event.type == InputEvent.MOUSE_BUTTON && event.is_pressed():
		game.table.emit_signal("cell_pressed", self)

func set_unit(unit):
	if container.get_child_count() != 0:
		container.remove_child(container.get_child(0))
	if unit != null:
		print("set mask " + str(unit_collision_layers) + ", " + str(unit_collision_mask))
		unit.set_collision_mask(unit_collision_layers)
		unit.set_layer_mask(unit_collision_mask)
		container.add_child(unit)

func get_unit():
	if container.get_child_count() != 0:
		return container.get_child(0)
	return null

func start_hover(card):
	hovered_card = card
	var path = "res://units/" + card.unit_name + ".tscn"
	var unit = load(path).instance()
	unit.show_hit_zone = unit.shoot_bullets
	unit.shoot_bullets = false
	unit.set_unit_name(card.unit_name)
	unit.set_side(side)
	
	preview.add_child(unit)
	var base
	if side == "red":
		base = game.table.get_node("BlueBase")
	else:
		base = game.table.get_node("RedBase")
	if base != null:
		unit.look_at(base.get_global_pos())
	
	print("Hovering " + str(card.get_path()) + ", " + str(base))

func stop_hover(card):
	hovered_card = null
	while preview.get_child_count() > 0:
		print("Removing preview child")
		preview.remove_child(preview.get_child(0))
		
	print("Stop hovering " + str(get_path()))