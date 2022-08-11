class_name PhysicsTest2D
extends Node2D

signal completed

var TOP_LEFT := Vector2(-512,-300)
var BOTTOM_LEFT := Vector2(-512,300)
var TOP_RIGHT := Vector2(512,-300)
var BOTTOM_RIGHT := Vector2(512,300)

var output := ""

@export_flags_2d_physics var collision_layer: int

enum TestCollisionShape {
	CAPSULE = PhysicsServer2D.SHAPE_CAPSULE,
	CONCAVE_POLYGON = PhysicsServer2D.SHAPE_CONCAVE_POLYGON,
	CONVEX_POLYGON = PhysicsServer2D.SHAPE_CONVEX_POLYGON,
	COLLISION_POLYGON_2D = 100,
	RECTANGLE = PhysicsServer2D.SHAPE_RECTANGLE,
	WORLD_BOUNDARY = PhysicsServer2D.SHAPE_WORLD_BOUNDARY
}

func _ready() -> void:
	if get_tree().get_root() == get_parent(): # autostart is the scene is alone
		start()

func test_name() -> String:
	@warning_ignore(assert_always_false)
	assert(false, "ERROR: You must give implement test_name()");
	return ""

func start() -> void:
	# Setup a Camera and Part
	var has_camera := false
	for child in get_children():
		if child is Camera2D:
			has_camera = true
	if not has_camera:
		var camera := Camera2D.new()
		camera.current = true
		add_child(camera)
	
	output += "[indent] • %s[/indent]\n" % [test_name()]

func test_description() -> String:
	return ""

func add_walls_and_ground(p_width:= 20):
	# Left Wall
	add_child(get_static_body_with_collision_shape(Rect2(TOP_LEFT, Vector2(p_width, 600))))
	# Right Wall
	add_child(get_static_body_with_collision_shape(Rect2(TOP_RIGHT - Vector2(p_width,0), Vector2(p_width, 600))))
	# Ground
	add_child(get_static_body_with_collision_shape(Rect2(BOTTOM_LEFT - Vector2(0,p_width), Vector2(1024, p_width))))

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

static func get_default_shape_definition(p_shape_type : TestCollisionShape, p_scale := 1):
	if p_shape_type == PhysicsServer2D.SHAPE_RECTANGLE:
		return Rect2(0, 0, 25, 25)
	if p_shape_type == PhysicsServer2D.SHAPE_CIRCLE:
		return Vector2(25,25) * p_scale
	if p_shape_type == PhysicsServer2D.SHAPE_CAPSULE:
		return Vector2(10,40) * p_scale
	if p_shape_type == PhysicsServer2D.SHAPE_CONVEX_POLYGON or p_shape_type == PhysicsServer2D.SHAPE_CONCAVE_POLYGON or p_shape_type == TestCollisionShape.COLLISION_POLYGON_2D:
		return PackedVector2Array([Vector2(0,0) * p_scale, Vector2(0,20) * p_scale, Vector2(20,20) * p_scale, Vector2(20,0) * p_scale, Vector2(0, 0) * p_scale]) 
	@warning_ignore(assert_always_false)
	assert(false, "No default shape for this shape type")

static func shape_name(p_shape_type : TestCollisionShape) -> String:
	return TestCollisionShape.keys()[p_shape_type]
