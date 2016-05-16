
extends Button

export(String, FILE, "*.tscn") var level

func _ready():
	connect("pressed", self, "change_level")
	
func change_level():
	var scene = load(level).instance()
	var root = get_node("/root")
	var select = root.get_node("SelectGame")
	root.remove_child(select)
	root.add_child(scene)



