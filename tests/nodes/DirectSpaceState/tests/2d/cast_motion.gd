extends PhysicsUnitTest2D

var simulation_duration := 10

func test_description() -> String:
	return """Checks all the [PhysicsShapeQueryParameters2D] of [cast_motion]
	"""
	
func test_name() -> String:
	return "CollisionShape2D | testing [cast_motion] from [get_world_2d().direct_space_state]"
	
func start() -> void:

	# Add Area on the LEFT
	var area := add_area(CENTER_LEFT)
	
	# Add Body on the RIGHT
	var body := add_body(CENTER_RIGHT)
	body.set_collision_layer_value(2, true)
	body.set_collision_mask_value(2, true)
	var body2 := add_body(BOTTOM_RIGHT)
	
	var d_space := get_world_2d().direct_space_state
	var shape_rid = PhysicsServer2D.circle_shape_create()
	var radius = .5
	PhysicsServer2D.shape_set_data(shape_rid, radius)

	var checks_point = func(p_target, p_monitor: GenericManualMonitor):
		if p_monitor.frame != 2: # avoid a bug in first frame
			return
		
		if true: # limit the scope
			p_monitor.add_test("Can collide with Body")
			var body_query := PhysicsShapeQueryParameters2D.new()
			body_query.collide_with_bodies = true
			body_query.shape_rid = shape_rid
			body_query.motion = Vector2(CENTER_RIGHT / 0.016)
			var result = d_space.cast_motion(body_query)
			p_monitor.add_test_result(is_between(result, 0.014, 0.016))
			
		if true: # limit the scope
			p_monitor.add_test("Can not collide with Body")
			var body_query := PhysicsShapeQueryParameters2D.new()
			body_query.collide_with_bodies = false
			body_query.shape_rid = shape_rid
			body_query.motion = Vector2(CENTER_RIGHT / 0.016)
			var result = d_space.cast_motion(body_query)
			p_monitor.add_test_result(is_eq(result, [1,1]))

		if true:
			p_monitor.add_test("Can collide with Area")
			var area_query := PhysicsShapeQueryParameters2D.new()
			area_query.shape_rid = shape_rid
			area_query.motion = Vector2(CENTER_LEFT / 0.016)
			area_query.collide_with_areas = true
			var result = d_space.cast_motion(area_query)
			p_monitor.add_test_result(is_between(result, 0.014, 0.016)) # Godot has 0.012 ??
		
		if true:
			p_monitor.add_test("Can not collide with Area")
			var area_query := PhysicsShapeQueryParameters2D.new()
			area_query.shape_rid = shape_rid
			area_query.motion = Vector2(CENTER_LEFT / 0.016)
			area_query.collide_with_areas = false
			var result = d_space.cast_motion(area_query)
			p_monitor.add_test_result(is_eq(result, [1,1]))

		# Can exclude a RID
		if true:
			p_monitor.add_test("Can exclude a Body by RID")
			var exclude_rid_query := PhysicsShapeQueryParameters2D.new()
			exclude_rid_query.collide_with_bodies = true
			exclude_rid_query.shape_rid = shape_rid
			exclude_rid_query.motion = Vector2(CENTER_RIGHT / 0.016)
			exclude_rid_query.exclude = [body.get_rid()]
			var result = d_space.cast_motion(exclude_rid_query)
			p_monitor.add_test_result(is_eq(result, [1,1]))

		if true:
			p_monitor.add_test("Can exclude an Area by RID")
			var area_query := PhysicsShapeQueryParameters2D.new()
			area_query.shape_rid = shape_rid
			area_query.collide_with_areas = true
			area_query.exclude = [area.get_rid()]
			area_query.motion = Vector2(CENTER_LEFT / 0.016)
			var result = d_space.cast_motion(area_query)
			p_monitor.add_test_result(is_eq(result, [1,1]))

		if true:
			p_monitor.add_test("Can exclude multiple RID")
			var exclude_rid_query := PhysicsShapeQueryParameters2D.new()
			exclude_rid_query.transform = Transform2D(0, TOP_RIGHT)
			exclude_rid_query.collide_with_bodies = true
			exclude_rid_query.shape_rid = shape_rid
			exclude_rid_query.motion = Vector2(BOTTOM_CENTER.x / 0.016, 0)
			exclude_rid_query.exclude = [body.get_rid(), body2.get_rid()]
			var result = d_space.cast_motion(exclude_rid_query)
			p_monitor.add_test_result(is_eq(result, [1,1]))

		if true:
			p_monitor.add_test("Don't report collision in the wrong collision layer")
			var area_query := PhysicsShapeQueryParameters2D.new()
			area_query.shape_rid = shape_rid
			area_query.motion = Vector2(CENTER_LEFT / 0.016)
			area_query.collide_with_areas = true
			area_query.collision_mask = pow(2, 2-1) # second layer
			var result = d_space.cast_motion(area_query)
			p_monitor.add_test_result(is_eq(result, [1,1]))

		if true:
			p_monitor.add_test("Report collision in good collision layer")
			var body_query := PhysicsShapeQueryParameters2D.new()
			body_query.shape_rid = shape_rid
			body_query.motion = Vector2(CENTER_RIGHT / 0.016)
			body_query.collide_with_bodies = true
			body_query.collision_mask = pow(2, 2-1) # second layer
			var result = d_space.cast_motion(body_query)
			p_monitor.add_test_result(is_between(result, 0.014, 0.016))
		
		PhysicsServer2D.free_rid(shape_rid)
		p_monitor.monitor_completed()

	var check_max_stability_monitor := create_generic_manual_monitor(self, checks_point, simulation_duration)

func add_body(p_position: Vector2, p_add_child := true) -> StaticBody2D:
	var body := StaticBody2D.new()
	var body_shape := get_default_collision_shape(PhysicsTest2D.TestCollisionShape.RECTANGLE, 4)
	body.add_child(body_shape)
	body.position = p_position
	if p_add_child:
		add_child(body)
	return body
	
func add_area(p_position: Vector2, p_add_child := true) -> Area2D:
	var area := Area2D.new()
	area.add_child(get_default_collision_shape(PhysicsTest2D.TestCollisionShape.RECTANGLE, 4))
	area.position = p_position
	if p_add_child:
		add_child(area)
	return area

func is_between(v: PackedFloat32Array, min: float, max: float, epsilon :=0.00001):
	return (min - epsilon) <= v[0] and  v[0] <= (max + epsilon) and (min - epsilon) <= v[1] and v[1] <= (max + epsilon)

func is_eq(v: PackedFloat32Array, value: Array):
	return v[0] == value[0] and v[1] == value[1]
