extends PhysicsPerformanceTest2D

@export var shape1: PhysicsTest2D.TestCollisionShape = PhysicsTest2D.TestCollisionShape.RECTANGLE
@export var shape2: PhysicsTest2D.TestCollisionShape = PhysicsTest2D.TestCollisionShape.RECTANGLE
@export var minimum_fps := 10

var timer : Timer
var bodies = []
var current_step := 0
var label_number : Label
var swap := false # change order bodies fall

func test_name() -> String:
	return "Maximum number of bodies before FPS are less than %d (%s vs %s)" % [minimum_fps, PhysicsTest2D.shape_name(shape1), PhysicsTest2D.shape_name(shape2)]

func start() -> void:
	label_number = Label.new()
	label_number.position = TOP_LEFT + Vector2(20,60)
	label_number.set("theme_override_font_sizes/font_size", 18)
	add_child(label_number)
	
	# ground
	add_child(PhysicsTest2D.get_static_body_with_collision_shape(Rect2(BOTTOM_LEFT - Vector2(1000, 100), Vector2(Global.WINDOW_SIZE.x + 1000, 100)), TestCollisionShape.RECTANGLE, true))

	timer = Timer.new()
	timer.wait_time = 0.2
	timer.process_callback =Timer.TIMER_PROCESS_PHYSICS
	timer.timeout.connect(spawn_body)
	add_child(timer)
	timer.start()
	super() # launch the test

func _physics_process(delta: float) -> void:
	label_number.text = "Bodies: " + str(bodies.size())

	if get_fps() <= minimum_fps:
			timer.stop()
			register_result("Maximum bodies", bodies.size())
			test_completed()

func clean() -> void:
	for body in bodies:
		remove_child(body)
		
func spawn_body() -> void:
	var offset = (Global.WINDOW_SIZE.x - 100) / 19
	swap = not swap
	for i in range(20):
		var shape := shape1 if swap else shape2
		var body = _get_rigid_body(TOP_LEFT + Vector2(50 + i * offset, 0), shape)
		bodies.append(body)
		add_child(body)
	
func _get_rigid_body(p_position: Vector2, p_shape: PhysicsTest2D.TestCollisionShape) -> RigidBody2D:
	var body = RigidBody2D.new()
	var shape = PhysicsTest2D.get_default_collision_shape(p_shape)
	body.add_child(shape)
	body.position = p_position
	return body
