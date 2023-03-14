extends PhysicsUnitTest3D

var speed := 25000
var simulation_duration := 0.1

func test_description() -> String:
	return """Checks if the Continuous Collision Detection (CCD) is working, it must ensure that moving
	objects does not go through objects (tunnelling).
	"""
	
func test_name() -> String:
	return "RigidBody3D | testing Continuous Collision Detection (CCD)"

var detect_x_collision := false
var detect_y_collision := false

func test_start() -> void:
	var vertical_wall = get_static_body_with_collision_shape(Vector3(5000, 0.1, 5000), PhysicsTest3D.TestCollisionShape.BOX)
	vertical_wall.position = Vector3(8, -5, 0)
	add_child(vertical_wall)

	var horizontal_wall = get_static_body_with_collision_shape(Vector3(0.1, 5000, 5000), PhysicsTest3D.TestCollisionShape.BOX)
	horizontal_wall.position = Vector3(0, 2, 0)
	add_child(horizontal_wall)

	var horizontal_rigid_body = create_rigid_body(true)
	var vertical_rigid_body = create_rigid_body(false)

	var x_lambda = func(p_target: RigidBody3D, _p_monitor: GenericExpirationMonitor):
		return p_target.position.x <= horizontal_wall.position.x # good

	var y_lambda = func(p_target: RigidBody3D , _p_monitor: GenericExpirationMonitor):
		return p_target.position.y >= vertical_wall.position.y # good

	var collide_x_lambda = func(_p_target: RigidBody3D, _p_monitor: GenericExpirationMonitor):
		return detect_x_collision

	var collide_y_lambda = func(_p_target: RigidBody3D, _p_monitor: GenericExpirationMonitor):
		return detect_y_collision

	horizontal_rigid_body.body_entered.connect(x_collide.bind(horizontal_rigid_body))
	vertical_rigid_body.body_entered.connect(y_collide.bind(vertical_rigid_body))
	
	var x_shape_ccd_monitor := create_generic_expiration_monitor(horizontal_rigid_body, x_lambda, null, simulation_duration)
	x_shape_ccd_monitor.test_name = "Rigid moving in x with CCD does not pass through the wall"
	x_shape_ccd_monitor.expected_to_fail = true
	
	var y_shape_ccd_monitor := create_generic_expiration_monitor(vertical_rigid_body, y_lambda, null, simulation_duration)
	y_shape_ccd_monitor.test_name = "Rigid moving in y with CCD does not pass through the wall"
	
	var x_collision_monitor := create_generic_expiration_monitor(horizontal_rigid_body, collide_x_lambda, null, simulation_duration)
	x_collision_monitor.test_name = "Rigid moving in x with CCD detects collision"

	var y_collision_monitor := create_generic_expiration_monitor(vertical_rigid_body, collide_y_lambda, null, simulation_duration)
	y_collision_monitor.test_name = "Rigid moving in y with CCD detects collision"

	process_mode = Node.PROCESS_MODE_DISABLED # to be able to see something
	await get_tree().create_timer(.1).timeout
	process_mode = Node.PROCESS_MODE_INHERIT

func create_rigid_body(p_horizontal := true) -> RigidBody3D:
	var player = RigidBody3D.new()
	player.add_child(get_default_collision_shape(PhysicsTest3D.TestCollisionShape.BOX))
	player.gravity_scale = 0
	player.continuous_cd = true
	player.contact_monitor = true
	player.max_contacts_reported = 2
	if p_horizontal:
		player.rotation = Vector3(0, 45, 45) # Case where the movement vector was not properly being transformed into local space, see #69934
		player.position = Vector3(-10, 2, 0)
	else:
		player.rotation = Vector3(45, 0, 0)
		player.position = Vector3(8, 8, 0)
	var force = Vector3(speed, 0, 0) if p_horizontal else Vector3(0, -speed, 0)
	player.apply_central_impulse(force)
	add_child(player)
	return player

func x_collide(_body, _player):
	detect_x_collision = true
	
func y_collide(_body, _player):
	detect_y_collision = true
