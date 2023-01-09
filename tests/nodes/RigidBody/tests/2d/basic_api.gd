extends PhysicsUnitTest2D

var simulation_duration := 10.0
var TOLERANCE := 1.0

func test_description() -> String:
	return """Checks if the basic API"""
	
func test_name() -> String:
	return "RigidBody2D | testing the API"

func test_start() -> void:
	
	add_collision_boundaries()
	var body := create_rigid_body(1)
	body.global_position = CENTER
	var right_constant_force = Vector2(200, 0)
	
	var maximum_bodies_supported = func(p_target: RigidBody2D, p_monitor: GenericManualMonitor):
		if p_monitor.frame == 1:
			# Setup the force
			p_target.add_constant_force(right_constant_force)
		# Apply the force 15 frames
		if p_monitor.frame == 15:
			if true:
				var travel = Vector2(p_target.position - CENTER)
				var expected = 0.5 *  right_constant_force * pow(((1.0/60.0) * 15), 2)  # x(t) = (1/2)at2 + v0t + x0
				p_monitor.add_test("Constant force is applied")
				var success:= Utils2D.vec_equals(travel, expected, TOLERANCE)
				if not success:
					p_monitor.add_test_error("Constant force is not applied correctly: expected %v, get %v" % [expected, travel])
				p_monitor.add_test_result(success)
			
			if true:
				p_monitor.add_test("Constant force can be retrieved")
				var success := p_target.constant_force == right_constant_force
				if not success:
					p_monitor.add_test_error("Constant force is not retrieved correctly: expected %v, get %v" % [right_constant_force, p_target.constant_force])
				p_monitor.add_test_result(success)
			
		
		if p_monitor.frame == 16:
			p_monitor.data["freeze_position"] = p_target.global_position
			p_target.freeze = true
		
		if p_monitor.frame == 24:
			p_monitor.add_test("Body can be freezed")
			var success: bool = p_target.global_position == p_monitor.data["freeze_position"]
			p_monitor.add_test_result(success)
			reset_body(p_target)
		
		if p_monitor.frame == 25:
			p_target.constant_torque = 500
		
		# 10 frames
		if p_monitor.frame == 45:
			p_monitor.add_test("Constant torque is applied")
			var intertia := PhysicsServer2D.body_get_param(p_target.get_rid(), PhysicsServer2D.BODY_PARAM_INERTIA)
			var expected = 0.5 *  (500 / intertia) * pow(((1.0/60.0) * 20.0), 2.0)  # x(t) = (1/2)at2 + v0t + x0
			var result = p_target.rotation
			var success:= Utils2D.f_equals(result, expected, 0.1)
			p_monitor.add_test_result(success)
		
		if p_monitor.frame == 46:
			p_monitor.add_test("Constant torque can be retrieved")
			var success := p_target.constant_torque == 500
			if not success:
				p_monitor.add_test_error("Constant torque is not retrieved correctly: expected %f, get %f" % [50, p_target.constant_torque])
			p_monitor.add_test_result(success)
		
			
		if p_monitor.frame == 50:
			p_monitor.monitor_completed()

	var check_max_stability_monitor := create_generic_manual_monitor(body, maximum_bodies_supported, simulation_duration)
	check_max_stability_monitor.test_name = "Check the RigidBody2D force API"

func reset_body(p_body: RigidBody2D) -> void:
	p_body.freeze = false
	p_body.constant_force = Vector2.ZERO
	p_body.constant_torque = 0.0
	p_body.linear_velocity = Vector2.ZERO
	p_body.angular_velocity = 0.0
	p_body.global_position = CENTER

func create_rigid_body(p_layer := 1, p_report_contact := 20) -> RigidBody2D:
	var player := RigidBody2D.new()
	player.add_child(PhysicsTest2D.get_default_collision_shape(TestCollisionShape.RECTANGLE))
	
	# Remove damping, gravity & friction
	player.gravity_scale = 0
	player.linear_damp = 0
	player.angular_damp = 0
	player.linear_damp_mode = RigidBody2D.DAMP_MODE_COMBINE
	player.linear_damp_mode = RigidBody2D.DAMP_MODE_COMBINE
	var physics_material = PhysicsMaterial.new()
	physics_material.friction = 0
	player.physics_material_override = physics_material
	
	# Report contact
	player.contact_monitor = true
	player.max_contacts_reported = p_report_contact
	
	player.collision_mask = 0
	player.collision_layer = 0
	player.set_collision_mask_value(p_layer, true)
	player.position = CENTER
	add_child(player)
	return player
