tool
extends "res://nodes/villager/actions/Action.gd"

var target = null

export(NodePath) var polygon_path
onready var polygon: Polygon2D = get_node(polygon_path)

var move_target: Vector2 = Vector2(0, 0)
var previous_slide_vec: Vector2 = Vector2(0, 0)

func _get_configuration_warning():
	if get_node(polygon_path) == null:
		return "could not find patrol node, make sure patrol_node is set"
	return ""

# Holds the triangles for the polygon above, used to calculate
# a destination for the villager to move to when patrolling
class Triangle:
	var _a: Vector2
	var _b: Vector2
	var _c: Vector2
	var _area: float

	func _init(a, b, c):
		self._a = a
		self._b = b
		self._c = c
		self._area = self._calculate_area()

	# https://www.mathopenref.com/coordtrianglearea.html
	func _calculate_area():
		var a = self._a
		var b = self._b
		var c = self._c
		var numerator = (a[0] * (b[1] - c[1])) \
			+ (b[0] * (c[1] - a[1])) \
			+ (c[0] * (a[1] - b[1]))
		return abs(numerator / 2)
		
	func _to_string():
		return "(%s,%s,%s)" % [self._a, self._b, self._c]
	
var triangles = []
var total_area = 0.0

func _ready():
	# guard against _ready being called twice
	if len(triangles) > 0:
		return
	
	# do some processing on our polygon to make new_target less
	# CPU intense later
	var triangle_indexes = Geometry.triangulate_delaunay_2d(polygon.polygon)
	var num_triangles = len(triangle_indexes) / 3
	for i in range(0, num_triangles):
		var start_index = i * 3
		var triangle = Triangle.new(
			polygon.polygon[triangle_indexes[start_index + 0]],
			polygon.polygon[triangle_indexes[start_index + 1]],
			polygon.polygon[triangle_indexes[start_index + 2]]
		)
		triangles.append(triangle)
		total_area += triangle._area
	
func get_label():
	return "patrol"
	
func on_enter():
	.on_enter()
	new_move_target()
	
func new_move_target():
	var new = new_target()	
	move_target = new
	previous_slide_vec = Vector2(0, 0)

func new_target():
	var t =_random_triangle()
	
	# https://stackoverflow.com/questions/19654251/random-point-inside-triangle-inside-java
	var r1 = randf()
	var r2 = randf()
	
	var x = (1 - sqrt(r1)) * t._a.x + \
		(sqrt(r1) * (1 - r2)) * t._b.x + \
		(sqrt(r1) * r2) * t._c.x
	var y = (1 - sqrt(r1)) * t._a.y + \
		(sqrt(r1) * (1 - r2)) * t._b.y + \
		(sqrt(r1) * r2) * t._c.y
	
	return Vector2(x, y)

func _random_triangle():
	# weighted random triangle based off each triangles area
	# so triangles with larger area are more likely to be picked relative to
	# the others
	var r = randf() * total_area
	for triangle in triangles:
		r -= triangle._area
		if r <= 0.0:
			return triangle
	return triangles[-1]

func physics_process(delta):
	var direction: Vector2 = move_target - villager.position
	var velocity: Vector2 = direction.normalized() * villager.get_speed()
	var slide_vec: Vector2 = villager.move_and_slide(velocity)
	
	if _compare(slide_vec.angle_to(previous_slide_vec), PI):
		new_move_target()
	else:
		previous_slide_vec = slide_vec

# https://godotengine.org/qa/16522/problem-comparing-floats
func _compare(a, b, epsilon = 0.01):
	return abs(a - b) <= epsilon

func should_activate():
	var fatigue = villager.get_emotion_intensity(Villager.Emotion.FATIGUE)
	return fatigue < 1.0

func should_deactivate():
	var fatigue = villager.get_emotion_intensity(Villager.Emotion.FATIGUE)
	return fatigue > 9.0

func process(delta):
	villager.amend_emotion(Villager.Emotion.FATIGUE, delta)
