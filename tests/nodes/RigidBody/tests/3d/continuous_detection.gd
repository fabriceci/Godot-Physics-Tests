extends PhysicsUnitTest3D

var speed := 25000
var simulation_duration := 1

func test_description() -> String:
	return """Checks if the Continuous Collision Detection (CCD) is working, it must ensure that moving
	objects does not go through objects (tunnelling).
	"""
	
func test_name() -> String:
	return "RigidBody | testing Continuous Collision Detection (CCD)"

func start() -> void:
	# TO DO: Instanciate scene nodes in code
	var vertical_mov_wall = $VerticalStaticBody3D
	var horizontal_mov_wall = $HorizontalStaticBody3D
		
	var x_lambda = func(p_target: RigidBody3D, p_monitor):
		if p_target.continuous_cd == false:
			return p_target.position.x > horizontal_mov_wall.position.x # bad
		else:
			return p_target.position.x <= horizontal_mov_wall.position.x # good

	var y_lambda = func(p_target:RigidBody3D , p_monitor):
		if p_target.continuous_cd == false:
			return p_target.position.y < vertical_mov_wall.position.y # bad
		else:
			return p_target.position.y >= vertical_mov_wall.position.y # good
			
	$HorizontalRigidBody3D.apply_central_impulse(Vector3(speed, 0, 0))
	$VerticalRigidBody3D.apply_central_impulse(Vector3(0, -speed, 0))
	
	var x_shape_ccd_monitor = create_generic_expiration_monitor($HorizontalRigidBody3D, x_lambda, null, simulation_duration)
	x_shape_ccd_monitor.test_name = "Rigid moving in x with CCD Cast shape does not pass through the wall"
	
	var y_shape_ccd_monitor = create_generic_expiration_monitor($VerticalRigidBody3D, y_lambda, null, simulation_duration)
	y_shape_ccd_monitor.test_name = "Rigid moving in y with CCD Cast shape does not pass through the wall"
	
	process_mode = Node.PROCESS_MODE_DISABLED # to be able to see something
	await get_tree().create_timer(.1).timeout
	process_mode = Node.PROCESS_MODE_INHERIT
