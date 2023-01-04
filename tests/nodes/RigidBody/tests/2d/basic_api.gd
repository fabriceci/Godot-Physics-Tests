extends PhysicsUnitTest2D

@export var body_shape: PhysicsTest2D.TestCollisionShape = TestCollisionShape.CIRCLE
var simulation_duration := 10.0

func test_description() -> String:
	return """Checks if the basic API"""
	
func test_name() -> String:
	return "RigidBody | testing the API"

func start() -> void:
	
	add_collision_boundaries()
	var body := create_rigid_body(1)
	body.global_position = CENTER
	
	var maximum_bodies_supported = func(p_target: RigidBody2D, p_monitor: GenericManualMonitor):
		if not p_monitor.first_iteration:
			return

		# Apply constant force
		var constant_force = Vector2(200, 0)
		p_target.add_constant_force(constant_force)
		#p_monitor.add_test("Constant force is applied")
		
		#await get_tree().create_timer(.5).timeout
		#var pos_diff = Vector2(CENTER - p_target.position)
		#if pos_diff == Vector2(-246, 0):
		#	p_monitor.add_test_result(true)
		#else:
		#	p_monitor.add_test_error("Constant force is not applied: expected %v, get %v" % [Vector2(-23, 0), pos_diff])
		#	p_monitor.add_test_result(false)
			
		# Retrieve constant force
		p_monitor.add_test("Constant force can be retrieved")
		if p_target.constant_force == Vector2(constant_force):
			p_monitor.add_test_result(true)
		else:
			p_monitor.add_test_error("Constant force is not retrieved correctly: expected %v, get %v" % [constant_force, p_target.constant_force])
			p_monitor.add_test_result(false)
		p_monitor.monitor_completed()

	var check_max_stability_monitor := create_generic_manual_monitor(body, maximum_bodies_supported, simulation_duration)
	check_max_stability_monitor.test_name = "Check the RigidBody2D force API"

func create_rigid_body(p_layer := 1, p_report_contact := 20) -> RigidBody2D:
	var player := RigidBody2D.new()
	player.add_child(get_default_collision_shape(body_shape))
	player.gravity_scale = 0
	player.contact_monitor = true
	player.max_contacts_reported = p_report_contact
	player.collision_mask = 0
	player.collision_layer = 0
	player.set_collision_mask_value(p_layer, true)
	add_child(player)
	return player
