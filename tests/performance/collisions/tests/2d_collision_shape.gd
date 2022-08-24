extends PhysicsPerformanceTest2D

@export var maximum_body := 1000
@export var test_record_step := 10
@export var record_from_step := 5
@export var shape1: PhysicsTest2D.TestCollisionShape = PhysicsTest2D.TestCollisionShape.RECTANGLE
@export var shape2: PhysicsTest2D.TestCollisionShape = PhysicsTest2D.TestCollisionShape.RECTANGLE
@export var body_size := Vector2(25, 25)

var timer : Timer
var bodies = []
var next_step := 0
var step_size := 0
var current_step := 0
var label_number : Label

var result = {}

func test_name() -> String:
	return "2D shape collisions (%s vs %s)" % [ PhysicsTest2D.TestCollisionShape.keys()[shape1], PhysicsTest2D.TestCollisionShape.keys()[shape2]]

func start() -> void:
	@warning_ignore(integer_division)
	next_step = maximum_body/test_record_step
	step_size = next_step
	label_number = Label.new()
	label_number.position = TOP_LEFT + Vector2(20,50)
	label_number.set("theme_override_font_sizes/font_size", 18)
	add_child(label_number)
	
	add_collision_boundaries(20, false)

	timer = Timer.new()
	timer.wait_time = 0.2
	timer.process_callback =Timer.TIMER_PROCESS_PHYSICS
	timer.timeout.connect(spawn_body)
	add_child(timer)
	timer.start()
	super() # launch the test

func _physics_process(delta: float) -> void:
	super(delta)
	label_number.text = "Bodies: " + str(bodies.size())
	
	var fps = Engine.get_frames_per_second()
	
	if(bodies.size() >= maximum_body):
		timer.stop()
		result[str(bodies.size())] =  str(fps)

		for key in result:
			print_rich("[indent][indent] → %s bodies = %s FPS[/indent][/indent]" % [key, result[key]])
		
		test_completed()
	
	if bodies.size() >= next_step:
		current_step += 1
		if current_step >= record_from_step:
			result[str(bodies.size())] =  str(fps)
		next_step += step_size

func spawn_body() -> void:
	var offset = (Global.WINDOW_SIZE.x - 100) / 19
	for i in range(20):
		var body = _get_rigid_body(TOP_LEFT + Vector2(50 + i * offset, 0))
		bodies.append(body)
		add_child(body)
	
func _get_rigid_body(p_position: Vector2) -> RigidBody2D:
	var body = RigidBody2D.new()
	var shape = get_collision_shape(Rect2(Vector2(0, 0), body_size))
	body.add_child(shape)
	body.position = p_position
	return body
