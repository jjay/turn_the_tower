
extends Node

# member variables here, example:
# var a=2
# var b="textvar"

#signal first(name, args)


	
func first(obj, s1, s2):		
	var y = FirstTrigger.new()
	add_child(y)
	y._s1 = s1
	y._s2 = s2
	y._connect_varying(s1, obj, "_first_s1")
	y._connect_varying(s2, obj, "_first_s2")
	return y



class FirstTrigger:
	extends Node
	signal complete(signame)
	var _s1
	var _s2
	func _ready():
		connect("complete", self, "remove")
		
	func remove(sig):
		disconnect("complete", self, "remove")
		get_parent().remove_child(self)
		
	func _connect_varying(signame, obj, prefix):
		var signals = obj.get_signal_list()
		var _signal
		for s in signals:
			if s["name"] == signame:
				_signal = s
				break
				
		if _signal == null:
			return "SIGNAL_NOT_FOUND"
	
		obj.connect(signame, self, prefix + "_" + str(_signal["args"].size()))
		return false
		
	func _first_s1_0():
		emit_signal("complete", _s1)#, [])
	
	func _first_s1_1(a1):
		emit_signal("complete", _s1)#, [a1])
	
	func _first_s1_2(a1, a2):
		emit_signal("complete", _s1)#, [a1, a2])
	
	func _first_s1_3(a1, a2, a3):
		emit_signal("complete", _s1)#, [a1, a2, a3])
	
	func _first_s1_4(a1, a2, a3, a4):
		emit_signal("complete", _s1)#, [a1, a2, a3, a4])
	
	func _first_s2_0():
		emit_signal("complete", _s2)#, [])
	
	func _first_s2_1(a1):
		emit_signal("complete", _s2)#, [a1])
	
	func _first_s2_2(a1, a2):
		emit_signal("complete", _s2)#, [a1, a2])
	
	func _first_s2_3(a1, a2, a3):
		emit_signal("first_triggered", _s2)#, [a1, a2, a3])
	
	func _first_s2_4(a1, a2, a3, a4):
		emit_signal("first_triggered", _s2)#, [a1, a2, a3, a4])

