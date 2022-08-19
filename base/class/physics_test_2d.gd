class_name PhysicsTest2D
extends Node2D

signal completed

var CENTER := Global.WINDOW_SIZE/2
var CENTER_LEFT := Vector2(0, CENTER.y)
var CENTER_RIGHT := Vector2(Global.WINDOW_SIZE.x, 0)

var TOP_LEFT := Vector2(0,0)
var TOP_CENTER := Vector2(CENTER.x, 0)
var TOP_RIGHT := Vector2(Global.WINDOW_SIZE.x, 0)

var BOTTOM_LEFT := Vector2(0, Global.WINDOW_SIZE.y)
var BOTTOM_CENTER := Vector2(CENTER.x, Global.WINDOW_SIZE.y)
var BOTTOM_RIGHT := Vector2(Global.WINDOW_SIZE.x, Global.WINDOW_SIZE.y)

var output := ""

@export_flags_2d_physics var collision_layer: int

enum TestCollisionShape {
	CAPSULE = PhysicsServer2D.SHAPE_CAPSULE,
	CONCAVE_POLYGON = PhysicsServer2D.SHAPE_CONCAVE_POLYGON,
	CONVEX_POLYGON = PhysicsServer2D.SHAPE_CONVEX_POLYGON,
	COLLISION_POLYGON_2D,
	RECTANGLE = PhysicsServer2D.SHAPE_RECTANGLE,
	WORLD_BOUNDARY = PhysicsServer2D.SHAPE_WORLD_BOUNDARY,
	CIRCLE = PhysicsServer2D.SHAPE_CIRCLE
}

func _ready() -> void:
	if get_tree().get_root() == get_parent(): # autostart is the scene is alone
		start()

func test_name() -> String:
	@warning_ignore(assert_always_false)
	assert(false, "ERROR: You must give implement test_name()");
	return ""

func start() -> void:
	pass

func test_completed() -> void:
	Global.NB_TESTS_COMPLETED += 1
	output += "[indent] %d. [b]%s[/b][/indent]\n" % [Global.NB_TESTS_COMPLETED, test_name()]

func test_description() -> String:
	return ""

func add_collision_boundaries(p_width:= 20, p_add_ceiling := true, p_layers := [1,2,3,4,5,6,7,8,9,10,11,12]):
	var surfaces: Array[StaticBody2D]= []
	# Left wall
	surfaces.append(get_static_body_with_collision_shape(Rect2(TOP_LEFT, Vector2(p_width, Global.WINDOW_SIZE.y))))
	# Right wall
	surfaces.append(get_static_body_with_collision_shape(Rect2(TOP_RIGHT - Vector2(p_width,0), Vector2(p_width, Global.WINDOW_SIZE.y))))
	# Bottom Wall
	surfaces.append(get_static_body_with_collision_shape(Rect2(BOTTOM_LEFT - Vector2(0,p_width), Vector2(Global.WINDOW_SIZE.x, p_width))))
	if p_add_ceiling:
		surfaces.append(get_static_body_with_collision_shape(Rect2(TOP_LEFT, Vector2(1024, p_width))))
	
	for wall in surfaces:
		wall.collision_layer = 0
		wall.collision_mask = 0
		for layer in p_layers:
			wall.set_collision_layer_value(layer, true)
			wall.set_collision_mask_value(layer, true)
		add_child(wall)

static func get_static_body_with_collision_shape(p_shape_definition, p_shape_type := TestCollisionShape.RECTANGLE) -> StaticBody2D:
	var body = StaticBody2D.new()
	body.position = Vector2(0, 0)
	var body_col = get_collision_shape(p_shape_definition, p_shape_type)
	body.add_child(body_col)
	return body
	
# Get CollisionShape2D or CollisionPolygon2D that fits in the rectangle.
static func get_collision_shape(p_shape_definition, p_shape_type := TestCollisionShape.RECTANGLE) -> Node2D:
	var col = null
	if p_shape_type == PhysicsServer2D.SHAPE_CAPSULE:
		assert(p_shape_definition is Vector2, "Shape definition for a Capsule must be a Vector2")
		col = CollisionShape2D.new()
		col.shape = CapsuleShape2D.new()
		col.shape.radius = p_shape_definition.x
		col.shape.height = p_shape_definition.y
	elif p_shape_type == PhysicsServer2D.SHAPE_CIRCLE:
		assert(p_shape_definition is float, "Shape definition for a Circle must be a float")
		col = CollisionShape2D.new()
		col.shape = CircleShape2D.new()
		col.shape.radius = p_shape_definition
	elif p_shape_type == PhysicsServer2D.SHAPE_CONCAVE_POLYGON:
		assert(p_shape_definition is PackedVector2Array, "Shape definition for a Concave Polygon must be a PackedVector2Array")
		col.shape = ConcavePolygonShape2D.new()
		col.shape.segments = p_shape_definition
	elif p_shape_type == PhysicsServer2D.SHAPE_CONVEX_POLYGON:
		assert(p_shape_definition is PackedVector2Array, "Shape definition for a Concave Polygon must be a PackedVector2Array")
		col.shape = ConvexPolygonShape2D.new()
		col.shape.segments = p_shape_definition
	elif p_shape_type == TestCollisionShape.COLLISION_POLYGON_2D:
		assert(p_shape_definition is PackedVector2Array, "Shape definition for a Concave Polygon must be a PackedVector2Array")
		col = CollisionPolygon2D.new()
		col.polygon = p_shape_definition
		col.build_mode = CollisionPolygon2D.BUILD_SOLIDS
	elif p_shape_type == PhysicsServer2D.SHAPE_RECTANGLE:
		assert(p_shape_definition is Rect2, "Shape definition for a Rectangle must be a Rect2")
		col = CollisionShape2D.new()
		col.shape = RectangleShape2D.new()
		col.shape.size = p_shape_definition.size
		col.position = p_shape_definition.position + 0.5 * p_shape_definition.size # top left position
	return col

static func get_default_collision_shape(p_shape_type : TestCollisionShape, p_scale := 1):
	return get_collision_shape(get_default_shape_definition(p_shape_type, p_scale), p_shape_type)
	
static func get_default_shape_definition(p_shape_type : TestCollisionShape, p_scale := 1):
	if p_shape_type == PhysicsServer2D.SHAPE_RECTANGLE:
		return Rect2(0, 0, 25, 25)
	if p_shape_type == PhysicsServer2D.SHAPE_CIRCLE:
		return 10.0 * p_scale
	if p_shape_type == PhysicsServer2D.SHAPE_CAPSULE:
		return Vector2(5,20) * p_scale
	if p_shape_type == PhysicsServer2D.SHAPE_CONVEX_POLYGON or p_shape_type == PhysicsServer2D.SHAPE_CONCAVE_POLYGON or p_shape_type == TestCollisionShape.COLLISION_POLYGON_2D:
		return PackedVector2Array([Vector2(0,0) * p_scale, Vector2(0,20) * p_scale, Vector2(20,20) * p_scale, Vector2(20,0) * p_scale, Vector2(0, 0) * p_scale]) 
	@warning_ignore(assert_always_false)
	assert(false, "No default shape for this shape type")

static func shape_name(p_shape_type : TestCollisionShape) -> String:
	match p_shape_type:
		TestCollisionShape.CAPSULE: return "Capsule"
		TestCollisionShape.CONCAVE_POLYGON: return "Concave Polygon"
		TestCollisionShape.CONVEX_POLYGON: return "Convex Polygon"
		TestCollisionShape.COLLISION_POLYGON_2D: return "Collision Polygon 2D"
		TestCollisionShape.RECTANGLE: return "Rectangle"
		TestCollisionShape.WORLD_BOUNDARY: return "World Boundary"
		TestCollisionShape.CIRCLE: return "Circle"
		_:
			@warning_ignore(assert_always_false)
			assert(false, "TestCollisionShape %d name is not implemented")
			return "Not implemented"
