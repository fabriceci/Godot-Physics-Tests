extends PhysicsUnitTest2D

@export var body_shape: PhysicsTest2D.TestCollisionShape = TestCollisionShape.CIRCLE
var simulation_duration := 1.0
var speed := 50000

func test_description() -> String:
	return """Checks if the contact is corretly reported when [contact_monitor] is turn ON"""
	
func test_name() -> String:
	return "RigidBody | testing [contact_monitor]"
	
func start() -> void:
	var wall_top = get_static_body_with_collision_shape(Rect2(Vector2(0,0), Vector2(2, Global.WINDOW_SIZE.y/2)), PhysicsTest2D.TestCollisionShape.RECTANGLE, true)
	wall_top.position = CENTER + Vector2(100, 0)
	wall_top.rotate(deg_to_rad(45))
	wall_top.set_collision_layer_value(1, true)
	wall_top.set_collision_layer_value(2, true)
	
	var wall_bot = get_static_body_with_collision_shape(Rect2(Vector2(0,0), Vector2(2, Global.WINDOW_SIZE.y/2)), PhysicsTest2D.TestCollisionShape.RECTANGLE, true)
	wall_bot.position = CENTER + Vector2(100, 0)
	wall_bot.rotate(deg_to_rad(135))
	wall_bot.set_collision_layer_value(1, true)
	wall_bot.set_collision_layer_value(2, true)
	
	add_child(wall_bot)
	add_child(wall_top)

	var body = create_rigid_body(1)
	body.position = CENTER - Vector2(100, 0)
	var contact_lambda = func(p_step, p_target, p_monitor):
		if p_step == 0: return body.get_colliding_bodies().size() == 0 
		elif p_step == 1: return body.get_colliding_bodies().size() == 2
		elif p_step == 2: return body.linear_velocity.is_equal_approx(Vector2.ZERO) and not body.sleeping and body.get_colliding_bodies().size() == 0
		elif p_step == 3: return body.sleeping

	var contact_monitor := create_generic_step_monitor(self, contact_lambda, null, simulation_duration)
	contact_monitor.auto_steps_name[1] = "Collisions are reported"
	contact_monitor.auto_steps_name[2] = "No collision is reported when the body is not moving"
	contact_monitor.auto_steps_name[3] = "The body sleep"

	var body_no_contact := create_rigid_body(2, 0)
	body_no_contact.position = CENTER - Vector2(200, 0)

	var lambda_no_contact = func(step, target, monitor):
		if step == 0: return body_no_contact.linear_velocity.is_equal_approx(Vector2.ZERO) # Start without velocity
		elif step == 1: return body_no_contact.get_colliding_bodies().size() == 0 and not body_no_contact.linear_velocity.is_equal_approx(Vector2.ZERO) # Moving
		elif step == 2: return body_no_contact.get_colliding_bodies().size() == 0 and  body_no_contact.linear_velocity.is_equal_approx(Vector2.ZERO)  # After the wall hit

	var no_contact_monitor := create_generic_step_monitor(self, lambda_no_contact)
	no_contact_monitor.test_name = "No contact reported when [contacts_reported] is 0"

func create_rigid_body(p_layer := 1, p_report_contact := 20) -> RigidBody2D:
	var player := RigidBody2D.new()
	player.add_child(get_default_collision_shape(body_shape))
	player.gravity_scale = 0
	player.contact_monitor = true
	player.max_contacts_reported = p_report_contact
	player.collision_mask = 0
	player.collision_layer = 0
	player.set_collision_mask_value(p_layer, true)
	player.apply_force(Vector2(speed, 0))
	add_child(player)
	return player
