extends Area2D

onready var game = get_node("/root/Game")

onready var body = get_node("Body")
onready var text_label = get_node("Body/TextValue")
onready var button = get_node("Body/Button")


func _ready():
	set_process(true)

func set_text(text):
	text_label.set_text(text)
	

func hide_body():
	remove_child(body)
	set_pickable(false)

func show_body():
	add_child(body)
	set_pickable(true)
	
func show_button():
	button.show()

func hide_button():
	button.hide()
	

# just block any input
func _input_event(viewport, event, shape_idx):
	if event.is_action_pressed("select"):
		return

