tool
extends "res://nodes/villager/actions/Action.gd"

var target = null

export(NodePath) var polygon_path
onready var polygon: Polygon2D = get_node(polygon_path)

var move_target: Vector2 = Vector2(0, 0)
var previous_slide_vec: Vector2 = Vector2(0, 0)
var speed = 0

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
	# CPU intense later, must use triangulate_polygon instead of
	# triangulate_delaunay_2d as there are issues with some polygons that
	# have concave sections
	var triangle_indexes = Geometry.triangulate_polygon(polygon.polygon)
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
	move_target = new_target()	
	previous_slide_vec = Vector2(0, 0)
	speed = get_new_speed()

func new_target():
	# known issues here with concave polygons, this algorithm can pick
	# a target that, when moving in a straight line, will exit the patrol
	# area
	# TODO: investigate Navigation2D instead and navigation poly being
	# a child of patrol

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
	var velocity: Vector2 = direction.normalized() * speed
	var slide_vec: Vector2 = villager.move_and_slide(velocity)
	
	if _compare(slide_vec.angle_to(previous_slide_vec), PI):
		new_move_target()
	else:
		previous_slide_vec = slide_vec

# https://godotengine.org/qa/16522/problem-comparing-floats
func _compare(a, b, epsilon = 0.01):
	return abs(a - b) <= epsilon

func should_activate():
	if villager == null:
		return false
	var fatigue = villager.get_emotion_intensity(Villager.Emotion.FATIGUE)
	return fatigue < 1.0

func should_deactivate():
	if villager == null:
		return false
	var fatigue = villager.get_emotion_intensity(Villager.Emotion.FATIGUE)
	return fatigue > 9.0

func process(delta):
	villager.amend_emotion(Villager.Emotion.FATIGUE, delta)

func get_new_speed():
	# villager should run back to the patrol area if they are outside of it
	# they may be outside if they have run away from the werewolf
	if is_inside_patrol_area():
		return villager.get_walk_speed()
	else:
		return villager.get_run_speed()

# https://www.geeksforgeeks.org/how-to-check-if-a-given-point-lies-inside-a-polygon/
func is_inside_patrol_area():
	var points = polygon.polygon
	var num_points = len(points)
	var count = 0
	var extreme = Vector2(999999, villager.position.y)
	var p = villager.position
	for i in range(num_points):
		var next = (i + 1) % num_points
		if do_intersect(points[i], points[next], p, extreme):
			if orientation(points[i], p, points[next]) == 0:
				return on_segment(points[i], p, points[next])
			count += 1

	return count % 2 == 1

func do_intersect(p1, q1, p2, q2):
	# Find the four orientations needed for general and
	# special cases
	var o1 = orientation(p1, q1, p2)
	var o2 = orientation(p1, q1, q2)
	var o3 = orientation(p2, q2, p1)
	var o4 = orientation(p2, q2, q1)

	# General case
	if o1 != o2 && o3 != o4:
		return true

	# p1, q1 and p2 are colinear and p2 lies on segment p1q1
	if (o1 == 0 && on_segment(p1, p2, q1)): return true

	# p1, q1 and p2 are colinear and q2 lies on segment p1q1
	if (o2 == 0 && on_segment(p1, q2, q1)): return true

	# p2, q2 and p1 are colinear and p1 lies on segment p2q2
	if (o3 == 0 && on_segment(p2, p1, q2)): return true

	# p2, q2 and q1 are colinear and q1 lies on segment p2q2
	if (o4 == 0 && on_segment(p2, q1, q2)): return true

	return false

func orientation(p, q, r):
	var val = (q.y - p.y) * (r.x - q.x) - \
			  (q.x - p.x) * (r.y - q.y)

	if val == 0:
		return 0
	elif val > 0:
		return 1
	else:
		return 2

func on_segment(p, q, r):
	return (q.x <= max(p.x, r.x) && q.x >= min(p.x, r.x) && \
			q.y <= max(p.y, r.y) && q.y >= min(p.y, r.y))
