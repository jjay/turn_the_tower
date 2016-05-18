
extends Node2D

signal card_selected(card)
signal card_played

const deck = ["soldier", "tank", "helicopter", "airplane", "ship", "wall", "submarine", "bigtank", "rocketlauncher", "spidertank"]

export (String, "red", "blue") var side = "red"

# member variables here, example:
# var a=2
# var b="textvar"
onready var game = get_node("/root/Game")
onready var tween = get_node("Tween")
onready var money = get_node("Cache")

var selected_card


func _ready():
	yield(game, "ready")
	game.table.connect("card_played", self, "_replace_selected")
	randomize()
	tween.start()
	for slot in get_node("Slots").get_children():
		generate_card(slot)

func generate_card(slot=null):
	var unit_name = deck[int(rand_range(0, deck.size()))]
	add_card(unit_name, slot)
	
func add_card(name, slot=null):
	if slot == null:
		for check_slot in get_node("Slots").get_children():
			if check_slot.get_child_count() == 0:
				slot = check_slot
				break
	
	var card = load("res://cards/" + name + ".tscn").instance()
	card.unit_name = name
	card.hand = self
	slot.add_child(card)

func _replace_selected(a,b,c):
	replace_selected()
func replace_selected():
	if selected_card == null:
		return
		
	
	resize(selected_card, 1)
	var slot = selected_card.get_parent()
	slot.remove_child(selected_card)
	selected_card = null
	generate_card(slot)

func set_selected_card(card):
	if selected_card != null:
		resize(selected_card, 1)

	selected_card = card
	if card != null:
		resize(card, 1.4)

func resize(card, scale, time=0.15):
	var prot = card.get_parent()
	scale = Vector2(scale, scale)
	tween.interpolate_property(prot, "transform/scale", prot.get_scale(), scale, time, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	




	
	
	


