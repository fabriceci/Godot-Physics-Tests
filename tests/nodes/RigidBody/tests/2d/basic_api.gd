extends PhysicsUnitTest2D

var simulation_duration := 10.0

func test_description() -> String:
	return """Checks the basic API for [RigidBody2D]
	"""
	
func test_name() -> String:
	return "RigidBody2D | testing the basic API"

var test_layer := 0

var dt := 1.0/60.0
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

func next_test_layer() -> int:
	test_layer += 1
	assert(test_layer <= 32)
	return test_layer
	
func test_start() -> void:
	
	if true:
		var body := create_rigid_body(next_test_layer(), TOP_LEFT)
		body.gravity_scale = 1

		var gravity_test = func(p_target: RigidBody2D, p_monitor: GenericManualMonitor):		
			# Apply the force 20 frames
			if p_monitor.frame == 20:
				var travel = p_target.position - TOP_LEFT
				var expected = 0.5 *  Vector2(0, gravity) * pow((dt * 20.0), 2)  # x(t) = (1/2)at2 + v0t + x0
				p_monitor.add_test("Gravity is applied properly")
				var success:= Utils2D.vec_equals(travel, expected, 4)
				if not success:
					p_monitor.add_test_error("Gravity is not applied properly, expected %v, get %v" % [expected, travel])
				p_monitor.add_test_result(success)
				p_monitor.monitor_completed()
		create_generic_manual_monitor(body, gravity_test, simulation_duration)
		
	if true:
		var body := create_rigid_body(next_test_layer())
		body.gravity_scale = 0
		body.global_position = TOP_CENTER

		var gravity_test = func(p_target: RigidBody2D, p_monitor: GenericManualMonitor):		
			# Apply the force 20 frames
			if p_monitor.frame == 20:
				p_monitor.add_test("Gravity scale works")
				var success:= Utils2D.vec_equals(p_target.position, TOP_CENTER)
				p_monitor.add_test_result(success)

				p_monitor.monitor_completed()
		create_generic_manual_monitor(body, gravity_test, simulation_duration)
		
	if true:
		var current_layer = next_test_layer()
		var body := create_rigid_body(current_layer, TOP_RIGHT)
		body.gravity_scale = 1
		var static_body := create_static_body(current_layer, TOP_RIGHT)
		static_body.position += Vector2(20, 50)

		var rotation_test = func(_p_target: PhysicsTest2D, _p_monitor: GenericExpirationMonitor):
			return body.rotation != 0

		var monitor = create_generic_expiration_monitor(self, rotation_test, null, 0.5)
		monitor.test_name = "Rotation works"

	if true:
		var current_layer = next_test_layer()
		var body := create_rigid_body(current_layer, CENTER_LEFT)
		body.gravity_scale = 1
		body.lock_rotation = true
		var static_body := create_static_body(current_layer, CENTER_LEFT)
		static_body.position += Vector2(20, 50)

		var lock_rotation_test = func(_p_target: PhysicsTest2D, _p_monitor: GenericExpirationMonitor):
			return body.rotation == 0

		var monitor = create_generic_expiration_monitor(self, lock_rotation_test, null, 0.5)
		monitor.test_name = "Lock_rotation works"

	if true:
		var current_layer = next_test_layer()
		var body_with_damping := create_rigid_body(current_layer, CENTER + Vector2(0, -60), false) # Damping
		var body_without_damping := create_rigid_body(current_layer, CENTER, true) # No Damping
		body_with_damping.add_constant_force(Vector2(200, 0))
		body_without_damping.add_constant_force(Vector2(200, 0))
		
		var damping_test = func(_p_target: PhysicsTest2D, _p_monitor: GenericExpirationMonitor):
			return body_with_damping.position.x < body_without_damping.position.x
			
		var monitor = create_generic_expiration_monitor(self, damping_test, null, 1)
		monitor.test_name = "Damping works"


	if true:
		var current_layer = next_test_layer()
		var body1 := create_rigid_body(current_layer, CENTER_RIGHT)
		body1.position += Vector2(-20, 0)
		body1.gravity_scale = 1
		body1.can_sleep = true

		var body2 := create_rigid_body(current_layer, CENTER_RIGHT)
		body2.position += Vector2(20, 0)
		body2.gravity_scale = 1
		body2.can_sleep = false

		var static_body := create_static_body(current_layer, CENTER_RIGHT, 3)
		static_body.position += Vector2(0, 100)

		var sleep_test = func(_p_target: PhysicsTest2D, _p_monitor: GenericExpirationMonitor):
			return body1.sleeping and not body2.sleeping

		var monitor = create_generic_expiration_monitor(self, sleep_test, null, 1)
		monitor.test_name = "Can sleep works"

	if true:
		var current_layer = next_test_layer()
		var next_layer = next_test_layer()
		var body1 := create_rigid_body(current_layer, BOTTOM_LEFT)
		body1.position += Vector2(-30, 0)
		body1.gravity_scale = 1

		var body2 := create_rigid_body(current_layer, BOTTOM_LEFT)
		body2.position += Vector2(-0, 0)
		body2.gravity_scale = 1
		body2.set_collision_mask_value(next_layer, true)

		var static_body := create_static_body(next_layer, BOTTOM_LEFT + Vector2(0, 80), 3)

		var mask_test = func(_p_target: PhysicsTest2D, _p_monitor: GenericExpirationMonitor):
			return body1.position.y > static_body.position.y and body2.position.y < static_body.position.y

		var monitor = create_generic_expiration_monitor(self, mask_test, null, 1)
		monitor.test_name = "Layers and masks works"

	if true:
		# Check constant central force API
		var body := create_rigid_body(next_test_layer(), BOTTOM_CENTER)

		var constant_central_force_test = func(p_target: RigidBody2D, p_monitor: GenericManualMonitor):
			if p_monitor.frame == 1:
				p_target.add_constant_central_force(Vector2(200, 0))
			# Apply the force 20 frames
			if p_monitor.frame == 21:
				var travel = p_target.position - BOTTOM_CENTER
				var expected = 0.5 *  Vector2(200, 0) * pow((dt * 20), 2)  # x(t) = (1/2)at2 + v0t + x0
				p_monitor.add_test("Constant force is applied")
				var success:= Utils2D.vec_equals(travel, expected, 1)
				if not success:
					p_monitor.add_test_error("Constant central force is not applied correctly: expected %v, get %v" % [expected, travel])
				p_monitor.add_test_result(success)

			if p_monitor.frame == 22:	
				p_monitor.add_test("Constant force can be retrieved")
				var success := p_target.constant_force == Vector2(200, 0)
				if not success:
					p_monitor.add_test_error("Constant central force is not retrieved correctly: expected %v, get %v" % [Vector2(200, 0), p_target.constant_force])
				p_monitor.add_test_result(success)

				p_monitor.monitor_completed()
		create_generic_manual_monitor(body, constant_central_force_test, simulation_duration)

	if true:
		# Check impulse force API
		var body := create_rigid_body(next_test_layer())
		body.global_position = BOTTOM_RIGHT + Vector2(0, 200)

		var force_impulse_test = func(p_target: RigidBody2D, p_monitor: GenericManualMonitor):
			if p_monitor.frame == 1:
				p_target.apply_central_impulse(Vector2(200, 0))
			# Apply the force 20 frames
			if p_monitor.frame == 21:
				var travel = p_target.position - (BOTTOM_RIGHT+Vector2(0, 200))
				var expected =  Vector2(200, 0) * dt * 20  # x(t) = at + v0t + x0
				p_monitor.add_test("Force impulse is applied")
				var success:= Utils2D.vec_equals(travel, expected, 0.001)
				if not success:
					p_monitor.add_test_error("Force impulse is not applied correctly: expected %v, get %v" % [expected, travel])
				p_monitor.add_test_result(success)

			if p_monitor.frame == 22:	
				p_monitor.add_test("Linear velocity can be retrieved")
				var success := p_target.linear_velocity == Vector2(200, 0)
				if not success:
					p_monitor.add_test_error("Linear velocity is not retrieved correctly: expected %v, get %v" % [Vector2(200, 0), p_target.constant_force])
				p_monitor.add_test_result(success)

				p_monitor.monitor_completed()
		create_generic_manual_monitor(body, force_impulse_test, simulation_duration)

#	if true:
#		var body := create_rigid_body(next_test_layer())
#		body.global_position = CENTER + Vector2(0, 200)
#
#		var force_impulse_test = func(p_target: RigidBody2D, p_monitor: GenericManualMonitor):
#			if p_monitor.frame == 1:
#				p_target.apply_impulse(Vector2(2000, 0), Vector2(0, 5))
#			# Apply the force 20 frames
#			if p_monitor.frame == 21:
#				var travel = p_target.position - (CENTER+Vector2(0, 200))
#				var expected =  Vector2(2000, 0) * dt * 20  # x(t) = at + v0t + x0
#				p_monitor.add_test("Force impulse at specific position is applied")
#				var success:= Utils2D.vec_equals(travel, expected, 0.001)
#				if not success:
#					p_monitor.add_test_error("Force impulse at specific position is not applied correctly: expected %v, get %v, rotation %f"  % [expected.x, travel.x, p_target.rotation])
#				p_monitor.add_test_result(success)
#				p_monitor.monitor_completed()
#		create_generic_manual_monitor(body, force_impulse_test, simulation_duration)
		
	# TO DO: check with the right formula
	if true:
		var body := create_rigid_body(next_test_layer())
		body.global_position = CENTER + Vector2(0, 200)

		var force_position_test = func(p_target: RigidBody2D, p_monitor: GenericManualMonitor):
			if p_monitor.frame == 1:
				p_target.add_constant_force(Vector2(200, 0), Vector2(0, 5))
			# Apply the force 20 frames
			if p_monitor.frame == 21:
				var travel = p_target.position - BOTTOM_CENTER
				var expected = 0.5 *  Vector2(200, 0) * pow((dt * 20), 2)  # x(t) = (1/2)at2 + v0t + x0
				p_monitor.add_test("Constant force at specific position is applied")
				var success:= Utils2D.f_equals(travel.x, expected.x, 1) and p_target.rotation != 0
				if not success:
					p_monitor.add_test_error("Constant force at specific position is not applied correctly: expected %v, get %v, rotation %f" % [expected.x, travel.x, p_target.rotation])
				p_monitor.add_test_result(success)
				p_monitor.monitor_completed()

		create_generic_manual_monitor(body, force_position_test, simulation_duration)
		
	if true:
		# Constant Torque
		var body := create_rigid_body(next_test_layer())
		body.global_position = CENTER - Vector2(100, 0)

		var constant_torque_test = func(p_target: RigidBody2D, p_monitor: GenericManualMonitor):
			if p_monitor.frame == 1:
				p_target.add_constant_torque(500)
			# Apply the force 20 frames
			if p_monitor.frame == 21:
				p_monitor.add_test("Constant torque is applied")
				var inertia := PhysicsServer2D.body_get_param(p_target.get_rid(), PhysicsServer2D.BODY_PARAM_INERTIA)
				var expected = 0.5 *  (500.0 / inertia) * pow((dt * 20.0), 2.0)  # x(t) = (1/2)at2 + v0t + x0
				var result = p_target.rotation
				var success:= Utils2D.f_equals(result, expected, 0.02)
				if not success:
					p_monitor.add_test_error("Constant torque is not applied correctly: expected %v, get %v" % [expected, result])
				p_monitor.add_test_result(success)

			if p_monitor.frame == 21:
				p_monitor.add_test("Constant torque can be retrieved")
				var success := p_target.constant_torque == 500
				if not success:
					p_monitor.add_test_error("Constant torque is not retrieved correctly: expected %f, get %f" % [50, p_target.constant_torque])
				p_monitor.add_test_result(success)

				p_monitor.monitor_completed()

		create_generic_manual_monitor(body, constant_torque_test, simulation_duration)
		
	if true:
		# Impulse Torque
		var body := create_rigid_body(next_test_layer())
		body.global_position = CENTER - Vector2(100, 0)

		var impulse_torque_test = func(p_target: RigidBody2D, p_monitor: GenericManualMonitor):
			if p_monitor.frame == 2:
				p_target.apply_torque_impulse(500)

			# Apply the force 20 frames
			if p_monitor.frame == 22:
				var inertia := PhysicsServer2D.body_get_param(p_target.get_rid(), PhysicsServer2D.BODY_PARAM_INERTIA)
				var angular_acc_expected =  (1.0/inertia) * 500.0 # θ(t) = (1/I)τ0t + θ0 
				if true:
					p_monitor.add_test("The impulse torque is applied to the angular velocity")
					var success_vel:= Utils2D.f_equals(p_target.angular_velocity, angular_acc_expected)
					if not success_vel:
						p_monitor.add_test_error("Impulse torque is not applied correctly to the angular velocity: expected %v, get %v" % [angular_acc_expected, p_target.angular_velocity])
					p_monitor.add_test_result(success_vel)

				if true:
					p_monitor.add_test("The impulse torque makes the body rotate correctly")
					var angular_rotation_expected = (angular_acc_expected * dt) * 20.0
					var success_rot:= Utils2D.f_equals(p_target.rotation, angular_rotation_expected)
					if not success_rot:
						p_monitor.add_test_error("The impulse torque is not applied correctly to the rotation: expected %v, get %v" % [angular_rotation_expected, p_target.rotation])
					p_monitor.add_test_result(success_rot)

				p_monitor.monitor_completed()

		create_generic_manual_monitor(body, impulse_torque_test, simulation_duration)

	if true:
		# Check freeze API
		var body := create_rigid_body(next_test_layer())
		body.freeze = true
		body.global_position = CENTER + Vector2(100, 0)
		var right_constant_force = Vector2(200, 0)

		var freeze_test = func(p_target: RigidBody2D, p_monitor: GenericManualMonitor):
			if p_monitor.frame == 1:
				# Setup the force
				p_target.add_constant_central_force(right_constant_force)
			if p_monitor.frame == 21:
				if true:
					p_monitor.add_test("Body can be freeze")
					var success: bool = p_target.global_position == CENTER + Vector2(100, 0)
					p_monitor.add_test_result(success)
					reset_body(p_target)

				p_monitor.monitor_completed()
		var body_freeze_monitor := create_generic_manual_monitor(body, freeze_test, simulation_duration)
		body_freeze_monitor.test_name = "Body can be freeze"
		
func reset_body(p_body: RigidBody2D) -> void:
	p_body.freeze = false
	p_body.constant_force = Vector2.ZERO
	p_body.constant_torque = 0.0
	p_body.linear_velocity = Vector2.ZERO
	p_body.angular_velocity = 0.0
	p_body.global_position = CENTER

func create_static_body(p_layer := 1, p_position := CENTER, p_scale := 1) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.position = p_position
	body.add_child(PhysicsTest2D.get_default_collision_shape(TestCollisionShape.RECTANGLE, p_scale))
	body.collision_mask = 0
	body.collision_layer = 0
	body.set_collision_layer_value(p_layer, true)
	body.set_collision_mask_value(p_layer, true)
	add_child(body)
	return body

func create_rigid_body(p_layer := 1, p_position := CENTER, p_remove_damping := true, p_scale := 1) -> RigidBody2D:
	var body := RigidBody2D.new()
	body.position = p_position
	body.add_child(PhysicsTest2D.get_default_collision_shape(TestCollisionShape.RECTANGLE, p_scale))
	
	body.gravity_scale = 0

	if p_remove_damping:
		body.linear_damp = 0
		body.angular_damp = 0
		body.linear_damp_mode = RigidBody2D.DAMP_MODE_REPLACE
		body.angular_damp_mode = RigidBody2D.DAMP_MODE_REPLACE

	body.collision_mask = 0
	body.collision_layer = 0
	body.set_collision_layer_value(p_layer, true)
	body.set_collision_mask_value(p_layer, true)

	add_child(body)
	return body
