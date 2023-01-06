extends PhysicsUnitTest3D

var speed := 25000
var simulation_duration := 0.1

func test_description() -> String:
	return """Checks if the Continuous Collision Detection (CCD) is working, it must ensure that moving
	objects does not go through objects (tunnelling).
	"""
	
func test_name() -> String:
	return "RigidBody | testing Continuous Collision Detection (CCD)"

var detect_x_collision := false
var detect_y_collision := false

func test_start() -> void:
	# TO DO: Instanciate scene nodes in code
	var vertical_mov_wall = $VerticalStaticBody3D
	var horizontal_mov_wall = $HorizontalStaticBody3D
		
	var x_lambda = func(p_target: RigidBody3D, p_monitor: GenericExpirationMonitor):
		return p_target.position.x <= horizontal_mov_wall.position.x # good

	var y_lambda = func(p_target: RigidBody3D , p_monitor: GenericExpirationMonitor):
		return p_target.position.y >= vertical_mov_wall.position.y # good
	
	var collide_x_lambda = func(p_target: RigidBody3D, p_monitor: GenericExpirationMonitor):
		return detect_x_collision

	var collide_y_lambda = func(p_target: RigidBody3D, p_monitor: GenericExpirationMonitor):
		return detect_y_collision
	#var horizontal_rigid_body = create_rigid_body(true)
	#var vertical_rigid_body = create_rigid_body(false)
	$HorizontalRigidBody3D.body_entered.connect(x_collide.bind($HorizontalRigidBody3D))
	$VerticalRigidBody3D.body_entered.connect(y_collide.bind($VerticalRigidBody3D))
	
	$HorizontalRigidBody3D.apply_central_impulse(Vector3(speed, 0, 0))
	$VerticalRigidBody3D.apply_central_impulse(Vector3(0, -speed, 0))
	
	var x_shape_ccd_monitor = create_generic_expiration_monitor($HorizontalRigidBody3D, x_lambda, null, simulation_duration)
	x_shape_ccd_monitor.test_name = "Rigid moving in x with CCD Cast shape does not pass through the wall"
	
	var y_shape_ccd_monitor = create_generic_expiration_monitor($VerticalRigidBody3D, y_lambda, null, simulation_duration)
	y_shape_ccd_monitor.test_name = "Rigid moving in y with CCD Cast shape does not pass through the wall"
	
	var x_collision_monitor = create_generic_expiration_monitor($HorizontalRigidBody3D, collide_x_lambda, null, simulation_duration)
	x_collision_monitor.test_name = "Rigid moving in x with CCD detects collision"

	var y_collision_monitor = create_generic_expiration_monitor($VerticalRigidBody3D, collide_y_lambda, null, simulation_duration)
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
