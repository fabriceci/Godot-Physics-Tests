extends PhysicsPerformanceTest3D

enum GroundType {
	BOX,
	CONCAVE
}

@export var shape1: PhysicsTest3D.TestCollisionShape = PhysicsTest3D.TestCollisionShape.CONVEX_POLYGON
@export var shape2: PhysicsTest3D.TestCollisionShape = PhysicsTest3D.TestCollisionShape.CONVEX_POLYGON
@export var minimum_fps := 10
@export var record_ := 1
@export var number_bodies_per_step := 5
@export var delay_for_new_bodies := 0.35
@export var ground: GroundType = GroundType.BOX
@export var step_recording := 50

var concave_polygon_ground = preload("res://base/mesh/concave_bac_3d.tres")

var timer : Timer
var bodies = []
var label_number : Label
var swap := false

var step_average: float = 0.0
var step_frame_cpt := 0
var step_next = 0

func _init() -> void:
	step_next = step_recording

func test_name() -> String:
	return "Maximum number of bodies before FPS are less than %d (%s vs %s)" % [minimum_fps, PhysicsTest3D.shape_name(shape1), PhysicsTest3D.shape_name(shape2)]

func start() -> void:

	$Camera.current = true
	
	label_number = Label.new()
	label_number.position = Vector2(20,60)
	label_number.set("theme_override_font_sizes/font_size", 18)
	add_child(label_number)
	
	# Ground
	var ground_body := StaticBody3D.new()
	ground_body.position = Vector3()
	if ground == GroundType.BOX:
		var ground_box_shape = get_collision_shape(Vector3(100, 1, 60))
		ground_body.add_child(ground_box_shape)
	else:
		var col_shape = CollisionShape3D.new()
		col_shape.shape = concave_polygon_ground
		ground_body.add_child(col_shape)
	add_child(ground_body)
	
	timer = Timer.new()
	timer.wait_time = delay_for_new_bodies
	timer.process_callback =Timer.TIMER_PROCESS_PHYSICS
	timer.timeout.connect(spawn_body)
	add_child(timer)
	timer.start()
	super() # launch the test

func _physics_process(delta: float) -> void:
	$Camera.current = true
	super(delta)
	if _warming:
		return

	if label_number:
		label_number.text = "Bodies: " + str(bodies.size())
	
	if step_recording != 0:
		step_frame_cpt += 1
		step_average += Engine.get_frames_per_second()
		
		if bodies.size() >= step_next:
			extra_text.append("• Step for %d bodies, AVG FPS: %2.f " % [bodies.size(), step_average / step_frame_cpt])
			step_average = 0
			step_next += step_recording
	
	if	get_fps() <= minimum_fps:
		timer.stop()
		register_result("Maximum bodies", bodies.size())
		test_completed()

func clean() -> void:
	for body in bodies:
		remove_child(body)
		
func spawn_body() -> void:
	if _warming:
		return
	swap = not swap
	for i in range(number_bodies_per_step):
		var shape := shape1 if swap else shape2
		var index = i + 1
		var even = index % 2 == 0
		var offset = index if even else -index
		var body = RigidBody3D.new()
		body.add_child(get_default_collision_shape(shape))
		body.position = Vector3(offset, 50, 0)
		bodies.append(body)
		add_child(body)
