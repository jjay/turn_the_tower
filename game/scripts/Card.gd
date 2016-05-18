
extends Area2D

onready var game = get_node("/root/Game")
onready var cost_label = get_node("Cost")
onready var sprite = get_node("Sprite")

#export var cost = 5

var cost = 0
var hand = null
var unit_name = "noname"
var owner = null
var can_play = false
var dragging = false
var hovering_cells = []
var hovering_cell = null

func _ready():
	var unit_path = "res://units/" + unit_name + ".tscn"
	print("Unit path: " + unit_path)
	var unit = load(unit_path).instance()
	cost = unit.cost
	cost_label.set_text(str(cost))
	update_playable(hand.money.current_coins)
	hand.money.connect("coins_changed", self, "update_playable")
	var texture = load("res://units/textures/" + unit_name + "_" + hand.side + ".atex")
	sprite.set_texture(texture)
	
	
func update_playable(current_coins):
	if current_coins >= cost:
		can_play = true
		set_opacity(1)
	else:
		can_play = false
		set_opacity(0.4)

func _input_event(viewport, event, shape_idx):
	if !can_play:
		return
	if dragging:
		return
	if event.type == InputEvent.MOUSE_BUTTON && event.is_pressed():
		set_dragging(true)
		hand.set_selected_card(self)

func _input(event):
	if !dragging:
		return
	if event.type == InputEvent.MOUSE_BUTTON && !event.is_pressed():
		set_dragging(false)
		return
	if event.type == InputEvent.MOUSE_MOTION:
		set_global_pos(event.pos)

func set_dragging(value):
	dragging = value
	set_process_input(value)
	if value:
		connect("area_enter", self, "on_area_enter")
		connect("area_exit", self, "on_area_exit")
	else:
		disconnect("area_enter", self, "on_area_enter")
		disconnect("area_exit", self, "on_area_exit")
	
	hovering_cells.clear()
	if hovering_cell != null:
		game.table.play_card(hovering_cell)
		hovering_cell.stop_hover(self)
		hovering_cell = null
	else:
		set_pos(Vector2(0, 0))
		hand.set_selected_card(null)
		

func on_area_enter(cell):
	if cell.side != hand.side:
		return
	if cell.get_unit() != null:
		return
	#print("Entering " + str(cell.get_path()))
	if hovering_cells.find(cell) != -1:
		return
	hovering_cells.append(cell)
	if hovering_cell == null:
		hovering_cell = cell
		cell.start_hover(self)
		hide()

func on_area_exit(cell):
	if cell.side != hand.side:
		show()
		return
	#print("Exiting " + str(cell.get_path()))
	hovering_cells.remove(hovering_cells.find(cell))
	if hovering_cell == cell:
		hovering_cell = null
		cell.stop_hover(self)
		
	if hovering_cell == null && hovering_cells.size() > 0:
		hovering_cell = hovering_cells[0]
		hovering_cell.start_hover(self)
	
	if hovering_cell == null:
		show()