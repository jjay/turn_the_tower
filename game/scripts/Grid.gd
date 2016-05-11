
extends Node2D

export var node_size = Vector2(128, 128)
var grid = []
var grid_size = Vector2(0, 0)
var reserved_nodes = {}



func _ready():
	var max_x = 0
	var max_y = 0
	for node in get_children():
		var x = floor(node.get_pos().x / node_size.x)
		var y = floor(node.get_pos().y / node_size.y)
		if x > max_x:
			max_x = x
		if y > max_y:
			max_y = y
		grid.resize(max(grid.size(), x+1))
		if grid[x] == null:
			grid[x] = []
		grid[x].resize(max(grid[x].size(), y+1))
		grid[x][y] = node
	grid_size = Vector2(max_x + 1, max_y + 1)
	print("Level scaned: " + str(grid_size.x) + "x" + str(grid_size.y))
	
func get_grid_pos(local_pos):
	return Vector2(\
		floor(local_pos.x / node_size.x),\
		floor(local_pos.y/ node_size.y)\
	)	

func get_local_pos(grid_pos):
	return Vector2(\
		(0.5 + grid_pos.x) * node_size.x,\
		(0.5 + grid_pos.y) * node_size.y\
	)

func find_possible_moves(pos, steps, type):
	print("Finding posible moves for " + str(pos) + ", " + str(steps) + ", " + str(type))
	var first = PathFindNode.new()
	first.pos = get_grid_pos(pos)
	first.len = 0
	var open = [first]
	var result = []
	var closed = {}
	
	while open.size():
		var current = open[0]
		open.pop_front()
		if closed.has(str(current.pos)):
			continue
		result.append(current.pos)
		closed[str(current.pos)] = true
		for ix in [-1, 0, 1]:
			for iy in [-1, 0, 1]:
				if ix == 0 && iy == 0 || ix != 0 && iy != 0:
					continue
				if current.len >= steps:
					continue
				var next = PathFindNode.new()
				next.len = current.len + 1
				next.pos = Vector2(current.pos.x + ix, current.pos.y + iy)
				if is_grid_node_reserved(next.pos, str(type)):
					continue
				
				open.append(next)
				
	return result
	
func is_grid_node_reserved(grid_pos, type):
	if grid_pos.x < 0 || grid_pos.y < 0 || grid_pos.x >= grid_size.x || grid_pos.y >= grid_size.y:
		return true
	
	var str_grid_pos = str(grid_pos)
	if reserved_nodes.has(str_grid_pos) && reserved_nodes[str_grid_pos]:
		return true
				
	var tile_type = str(grid[grid_pos.x][grid_pos.y].path_type)
	if type == "Tank" || type == "Soldier":
		if tile_type == "Water":
			return true
	
	return false

func reserve_node(pos):
	reserved_nodes[str(get_grid_pos(pos))] = true

func free_node(pos):
	reserved_nodes[str(get_grid_pos(pos))] = false

func reserve_grid_node(pos):
	reserved_nodes[str(pos)] = true

func free_grid_node(pos):
	reserved_nodes[str(pos)] = false

class PathFindNode:
	var len = 0
	var pos = Vector2(0, 0)