extends PhysicsUnitTest2D

var simulation_duration := 2 

func test_description() -> String:
	return """Checks that [Raycast2D] collisions work correctly with all parameters [exclude_parent],
	[hit_from_inside], [enabled]"""
	
func test_name() -> String:
	return "Raycast2D | testing collision"

func start() -> void:

	var ray_lambda = func(p_target, p_monitor: Monitor):
		# Child 0 is the Shape, from 1 it is Raycast2D 
		var is_concave_segment =  p_target.get_child(0) is CollisionShape2D and p_target.get_child(0).shape is ConcavePolygonShape2D
		var ray1 = p_target.get_child(1) # from up 
		if ray1.is_colliding():
			p_monitor.error_message = "Raycast not entabled should not collidee"
			return false
		var ray2 = p_target.get_child(2) # from up 
		if not ray2.is_colliding():
			p_monitor.error_message = "Raycast from up to bottom should collide"
			return false
		var ray3 = p_target.get_child(3) # from up excluded
		
		if not is_concave_segment: # inside is empty for concave segment, no sense
			if ray3.is_colliding():
				p_monitor.error_message = "Raycast from up to bottom with [exclude parent] ON should not collide"
				return false
			var ray4 = p_target.get_child(4) # inside
			if not ray4.is_colliding():
				p_monitor.error_message = "Raycast inside with [hit inside] ON should collide"
				return false
			var ray5 = p_target.get_child(5) # inside without hit inside
			if ray5.is_colliding():
				p_monitor.error_message = "Raycast inside with [hit inside] OFF should not collide"
				return false
			var ray6 = p_target.get_child(6) # from center to bottom
			if ray6.is_colliding():
				p_monitor.error_message = "Raycast from center to bottom with [hit inside] OFF should not collide"
				return false
		return true
	
	var offset := (Global.WINDOW_SIZE.x - 200) / (PhysicsTest2D.TestCollisionShape.values().size() -1)
	var cpt := 0
	for shape_type in PhysicsTest2D.TestCollisionShape.values():
		if shape_type == PhysicsTest2D.TestCollisionShape.WORLD_BOUNDARY or shape_type == PhysicsTest2D.TestCollisionShape.CONCAVE_SEGMENT:
			continue
		var body = create_rigid_body(Vector2(100 + offset * cpt, CENTER.y), shape_type)
		var monitor = create_generic_expiration_monitor(body, ray_lambda, null, simulation_duration)
		monitor.test_name = "Testing Raycast collision with %s" % [shape_name(shape_type)]
		cpt += 1
	
func create_rigid_body(p_position: Vector2, p_collision_shape: PhysicsTest2D.TestCollisionShape) -> RigidBody2D:
	var body := RigidBody2D.new()
	body.gravity_scale = 0
	body.add_child(get_default_collision_shape(p_collision_shape, 6))
	body.position = p_position
	add_child(body)
	
	create_raycast(body, Vector2(10, -200), 200, true, false, false) # up from center not enabled
	create_raycast(body, Vector2(-20, -200), 200) # up from center
	create_raycast(body, Vector2(20, -200), 200, false, true) # up from center but exclude parent
	create_raycast(body, Vector2(-20, 10), 10, true) # inside with hit
	create_raycast(body, Vector2(20, 10), 10) # inside without hit
	create_raycast(body, Vector2.ZERO, 200) # center from outside
	
	return body

func create_raycast(p_parent: RigidBody2D, p_position: Vector2, p_size: int, p_hit_from_inside := false, p_exclude_parent := false, enabled := true) -> RayCast2D:
	var ray := RayCast2D.new()
	ray.position = p_position
	ray.is_colliding()
	ray.enabled = enabled
	ray.exclude_parent = p_exclude_parent
	ray.target_position = Vector2(0, p_size)
	ray.hit_from_inside = p_hit_from_inside
	p_parent.add_child(ray)
	return ray
