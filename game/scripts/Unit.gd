
extends Area2D

signal targets_in_polygon_found(targets)
signal aim_requested(source)
signal aimed(target)
signal target_selected(target)
signal ready

export var shoot_bullets = true
export (float) var bullet_speed = 10
export (float) var damage = 1
export (float) var total_health = 10
export (float) var life_time = 10
export (float) var die_delay = 0
export (float) var hit_rate = 1
export var cost = 3
export var wait_for_game = false
export var aiming_speed = PI
export (String, FILE, "*.tscn") var bullet_prefab
export (String, "nearest_first", "nearest_last", "aggressive_first", "aggresive_last") var target_selection_order = "nearest_first"
export (String, "red", "blue") var unit_side = "red"


onready var Yield = get_node("/root/yield")
onready var game = get_node("/root/Game")
onready var sprite = get_node("Visual/Sprite")
onready var hit_zone = get_node("Visual/HitZone")
onready var hit_timer = get_node("HitTimer")
onready var health_bar = get_node("Visual/HealthBar")
onready var animation = get_node ("Visual/Sprite/AnimationPlayer")
onready var aim_process = get_node("AimProcess")

var show_hit_zone = false
var aiming = false
var health

# public
var owner
var card
var lifes = 0
var rotated = false
var unit_name = "default"
var aiming_target
var selected_target


func _ready():
	add_to_group(unit_side + "_unit")

	health = total_health
	health_bar.set_total_life(total_health)
	health_bar.set_missed_life(0)
	health_bar.set_damage_value(0)
	hit_timer.set_wait_time(hit_rate)
	aim_process.add_user_signal("tween_cancel")
	
	if shoot_bullets:
		animation.play("@UnitAbleToRotate")
	else:
		animation.play("@UnitIdle")

	update_texture()
	
	if wait_for_game:
		yield(game, "ready")
		
	#if side == "blue":
	#	base_name = "RedBase"
	#else:
	#	base_name = "BlueBase"
	
	look_at(game.table.get_node(enemy_side().capitalize() + "Base").get_global_pos())

	call_deferred("die_process")
	if shoot_bullets:
		select_target()
		call_deferred("shoot_process")

	game.table.connect("card_played", self, "on_unit_enter")
	game.table.connect("unit_removed", self, "on_unit_exit")
	emit_signal("ready")

func set_side(side):
	unit_side = side

func set_unit_name(name):
	unit_name = name

func update_texture():
	var tex = load("res://units/textures/" + unit_name + "_" + unit_side + ".atex")
	sprite.set_texture(tex)

func animate_creation():
	var tween = Tween.new()
	add_child(tween)
	tween.start()
	var sprite = get_node("Visual/Sprite")
	var from = sprite.get_scale()
	var to = sprite.get_scale() * 1.4
	var time = 0.5
	tween.interpolate_property(sprite, "transform/scale", from, to, time, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	yield(tween, "tween_complete")
	tween.interpolate_property(sprite, "transform/scale", to, from, time, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		


func take_damage(damage):
	health -= damage
	health_bar.add_missed_life(damage)
	if health <= 0:
		call_deferred("remove")

func remove(emit_removed=true):
	var index = get_cell().get_index()
	var p = get_parent()
	p.remove_child(self)
	if emit_removed:
    	game.table.emit_signal("unit_removed", index) 

func get_cell():
	return get_parent().get_parent()

func get_table_pos():
	return get_cell().get_pos()
	

func enemy_side():
	if unit_side == "red":
		return "blue"
	else:
		return "red"
	

func sort_targets(a, b):
	var tb = get_table_pos()
	return tb.distance_squared_to(a.get_table_pos()) < tb.distance_squared_to(b.get_table_pos())

func on_unit_enter(side, name, cell_idx):
	var cell = game.table.cells.get_child(cell_idx)
	if side == unit_side:
		return
	select_target()

func on_unit_exit(cell_idx):
	var cell = game.table.cells.get_child(cell_idx)
	if cell.side == unit_side:
		return
	select_target()
	
func select_target():
	if !is_inside_tree():
		return
		
	var targets = get_tree().get_nodes_in_group(enemy_side() + "_unit")
	targets.sort_custom(self, target_selection_order)
	if selected_target != targets[0]:
		selected_target = targets[0]
		request_aiming()

func request_aiming():
	aiming_target = selected_target	
	var tween_ease = Tween.EASE_IN_OUT
	if aim_process.is_active():
		aim_process.emit_signal("tween_cancel")
		aim_process.remove_all()
		tween_ease = Tween.EASE_OUT
	
	var rot = get_rot() + 2*PI
	var trot = (selected_target.get_table_pos() - get_table_pos()).angle()
	while rot > trot:
		trot += 2*PI
	
	if trot - rot > PI:
		trot -= 2*PI
	
	
	var time = abs(trot-rot) / aiming_speed
	if time < 0.05:
		aiming_target = null
		return
		
	print("[AIMING] start curr_rot: " + str(rot) + ", req_rot:" + str(trot) + ", time: " + str(time))

	aim_process.interpolate_property(self, "transform/rot", rad2deg(rot), rad2deg(trot), time, Tween.TRANS_SINE, tween_ease)
	aim_process.start()
	var async_result = Yield.first(aim_process, "tween_complete", "tween_cancel")
	var res = yield(async_result, "complete")
	print("[AIMING] aim complete with " + res)
	if "tween_complete" == res:
		aiming_target = null
		emit_signal("aimed", selected_target)

func has_valid_target():
	return selected_target != null && selected_target.is_inside_tree()

func shoot_process():
	hit_timer.start()
	while is_inside_tree():
		if has_valid_target() && !aiming_target:
			var projectile = load(bullet_prefab).instance()
			projectile.setup(game.table, self)
		elif !has_valid_target():
			select_target()
		yield(hit_timer, "timeout")

func die_process():
	var timer = Timer.new()
	add_child(timer)
	timer.set_wait_time(1)
	timer.set_one_shot(false)
	timer.start()
	while true:
		yield(timer, "timeout")
		take_damage(total_health/life_time)
	
func nearest_first(a, b):
	var p = get_table_pos()
	return p.distance_squared_to(a.get_table_pos()) < p.distance_squared_to(b.get_table_pos())
	
func nearest_last(a, b):
	return nearest_first(b, a)