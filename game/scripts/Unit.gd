
extends Area2D

signal target_found(target)
signal ready

export var shoot_bullets = true
export (float) var bullet_speed = 10
export (float) var damage = 1
export (float) var total_health = 10
export (float) var life_time = 10
export (float) var die_delay = 0
export (float) var hit_rate = 1
export var wait_for_game = false
export (String, FILE, "*.tscn") var bullet_prefab


onready var game = get_node("/root/Game")
onready var sprite = get_node("Visual/Sprite")
onready var hit_zone = get_node("Visual/HitZone")
onready var hit_timer = get_node("HitTimer")
onready var health_bar = get_node("Visual/HealthBar")
onready var animation = get_node ("Visual/Sprite/AnimationPlayer")

var show_hit_zone = false
var dragging = false
var health

# public
var owner
var card
var lifes = 0
var rotated = false
var unit_name = "default"
var unit_side = "red"


func _ready():

	health = total_health
	health_bar.set_total_life(total_health)
	health_bar.set_missed_life(0)
	health_bar.set_damage_value(0)
	hit_timer.set_wait_time(hit_rate)
	
	if shoot_bullets:
		animation.play("@UnitAbleToRotate")
	else:
		animation.play("@UnitIdle")

	connect("area_enter", self, "bullet_hit")
	update_texture()
	
	if wait_for_game:
		yield(game, "ready")
	
	if show_hit_zone:
		hit_zone.show()
	
	call_deferred("die_process")
	if shoot_bullets:
		call_deferred("shoot_process")
	#animate_creation()
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
	
	

func _input_event(viewport, event, shape_idx):
	if dragging:
		return
	
	if rotated:
		return
	
	if event.type == InputEvent.MOUSE_BUTTON && event.is_pressed():
		set_dragging(true)
		return
		
func _input(event):
	if !dragging:
		return
	
	if event.type == InputEvent.MOUSE_MOTION:
		look_at(event.pos)
		game.table.emit_signal("unit_rotated", get_cell().get_index(), get_rot())
		rotated = true
	elif event.type == InputEvent.MOUSE_BUTTON && !event.is_pressed():
		if shoot_bullets:
			animation.play("@UnitIdle")
		set_dragging(false)

func bullet_hit(bullet):
	if bullet.targets.find(self) == -1:
		return
		
	print("take damage " + str(bullet) + ", " + str(bullet.get("damage")))
	var dmg = bullet.damage
	bullet.call_deferred("destroy")
	take_damage(dmg)

func take_damage(damage):
	health -= damage
	health_bar.add_missed_life(damage)
	if health <= 0:
		call_deferred("remove")

func remove():
	var p = get_parent()
	p.remove_child(self)
	print("Parent: " + str(p) + ", child count: " + str(p.get_child_count()))

func get_cell():
	return get_parent().get_parent()

func get_table_pos():
	return get_cell().get_pos()
	
func set_dragging(value):
	if value && !shoot_bullets:
		return
	dragging = value
	hit_zone.set_hidden(!value)
	set_process_input(value)
	if rotated && !value:
		game.table.emit_signal("rotation_complete", get_cell().get_index())

func _fixed_process(delta):
	var request = Physics2DShapeQueryParameters.new()
	if get_cell().side == "red":
		request.set_layer_mask(2)
	else:
		request.set_layer_mask(1)
	request.set_object_type_mask(Physics2DDirectSpaceState.TYPE_MASK_AREA)
	var shape = ConvexPolygonShape2D.new()
	var poly = get_node("Visual/HitZone")
	shape.set_points(poly.get_polygon())
	#var shape = CircleShape2D.new()
	#shape.set_radius(500)
	request.set_shape(shape)
	request.set_transform(poly.get_global_transform())
	var result = get_world_2d().get_direct_space_state().intersect_shape(request)
	var targets = []
	for result_item in result:
		if !(result_item["collider"] extends get_script()):
			continue
		targets.append(result_item["collider"])
		
		#var pos = result_item["collider"].get_table_pos()
		#if nearest == null:
		#	nearest = pos
		#elif get_table_pos().distance_to(pos) < get_table_pos().distance_to(nearest):
		#	nearest = pos
	targets.sort_custom(self, "sort_targets")

	set_fixed_process(false)
	emit_signal("target_found", targets)

func sort_targets(a, b):
	var tb = get_table_pos()
	return tb.distance_squared_to(a.get_table_pos()) < tb.distance_squared_to(b.get_table_pos())
	
func shoot_process():
	while true:
		yield(hit_timer, "timeout")
		if dragging:
			continue
		
		set_fixed_process(true)
		var targets = yield(self, "target_found")

		if targets.size() == 0:
			continue

		print(bullet_prefab)
		var bullet = load(bullet_prefab).instance()
		bullet.setup_targets(game, self, targets)
		

		#var direction = (targets[0].get_table_pos() - get_table_pos()).normalized()
		#bullet.set_collision_mask(get_collision_mask())
		#bullet.targets = targets
		#game.table.add_child(bullet)
		#bullet.set_pos(get_cell().get_pos())
		#bullet.set_rot(get_rot())
		#bullet.set_scale(Vector2(2,2))
		#bullet.damage = damage
		#var v = direction * bullet_speed
		#bullet.set_linear_velocity(v)
		#game.table.emit_signal("unit_shoot", get_cell().get_index(), v)
		

func die_process():
	var timer = Timer.new()
	add_child(timer)
	timer.set_wait_time(1)
	timer.set_one_shot(false)
	timer.start()
	while true:
		yield(timer, "timeout")
		print("taking " + str(total_health/life_time) + " dmg")
		take_damage(total_health/life_time)