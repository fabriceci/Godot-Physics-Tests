extends PhysicsUnitTest2D

var simulation_duration := 10

func test_description() -> String:
	return """Checks all the [PhysicsPointQueryParameters2D] of [intersect_point]
	"""
	
func test_name() -> String:
	return "CollisionShape2D | testing [intersect_point] from [get_world_2d().direct_space_state]"
	
func start() -> void:

	# Add Area on the LEFT
	var area := add_area(CENTER_LEFT)
	
	# Add Body on the RIGHT
	var body := add_body(CENTER_RIGHT)
	
	# Add two body in the center
	var area_center := add_area(CENTER)
	var body_center := add_body(CENTER)
	var area_center2 := add_area(CENTER)
	var body_center2 := add_body(CENTER)
	
	# Add Canvas Layer
	var canvas := CanvasLayer.new()
	canvas.layer = 2
	canvas.add_child(add_area(TOP_CENTER, false))
	add_child(canvas)
	
	var d_space := get_world_2d().direct_space_state
	var checks_point = func(p_target, p_monitor: GenericManualMonitor):
		if p_monitor.frame != 2: # avoid a bug in first frame
			return
		
		if true: # limit the scope
			p_monitor.add_test("Don't collide at 1px left from the body")
			var body_query := PhysicsPointQueryParameters2D.new()
			body_query.position = CENTER_RIGHT - (Vector2(51,0)) # Rectangle is 100px wide
			body_query.collide_with_bodies = true
			var collide = true if d_space.intersect_point(body_query) else false
			p_monitor.add_test_result(not collide)

		if true:
			p_monitor.add_test("Can collide with Body at the left border")
			var body_query := PhysicsPointQueryParameters2D.new()
			body_query.position = CENTER_RIGHT - (Vector2(50,0))
			body_query.collide_with_bodies = true
			var collide = true if d_space.intersect_point(body_query) else false
			p_monitor.add_test_result(collide)

		if true:
			p_monitor.add_test("Can not collide with Body")
			var body_query := PhysicsPointQueryParameters2D.new()
			body_query.position = CENTER_RIGHT
			body_query.collide_with_bodies = false
			var collide = true if d_space.intersect_point(body_query) else false
			p_monitor.add_test_result(not collide)

		if true:
			p_monitor.add_test("Can collide with Area")
			var area_query := PhysicsPointQueryParameters2D.new()
			area_query.position = CENTER_LEFT
			area_query.collide_with_areas = true
			var collide = true if d_space.intersect_point(area_query) else false
			p_monitor.add_test_result(collide)

		if true:
			p_monitor.add_test("Can not collide with Area")
			var area_query := PhysicsPointQueryParameters2D.new()
			area_query.position = CENTER_LEFT
			area_query.collide_with_areas = false
			var collide = true if d_space.intersect_point(area_query) else false
			p_monitor.add_test_result(not collide)

		# Can exclude a RID
		if true:
			p_monitor.add_test("Can exclude a Body by RID")
			var exclude_rid_query := PhysicsPointQueryParameters2D.new()
			exclude_rid_query.position = CENTER_RIGHT
			exclude_rid_query.collide_with_bodies = true
			exclude_rid_query.exclude = [body.get_rid()]
			var collide = true if d_space.intersect_point(exclude_rid_query) else false
			p_monitor.add_test_result(not collide)

		if true:
			p_monitor.add_test("Can exclude an Area by RID")
			var exclude_rid_query := PhysicsPointQueryParameters2D.new()
			exclude_rid_query.position = CENTER_LEFT
			exclude_rid_query.collide_with_areas = true
			exclude_rid_query.exclude = [area.get_rid()]
			var collide = true if d_space.intersect_point(exclude_rid_query) else false
			p_monitor.add_test_result(not collide)
			
		# Canvas Layer
		if true:
			p_monitor.add_test("Should not detect a collision when query the canvas instance")
			var area_query := PhysicsPointQueryParameters2D.new()
			area_query.position = CENTER_LEFT
			area_query.collide_with_areas = true
			area_query.canvas_instance_id = canvas.get_instance_id()
			var collide = true if d_space.intersect_point(area_query) else false
			p_monitor.add_test_result(not collide)
			
		if true:
			p_monitor.add_test("Should not detect a collision when query the canvas instance")
			var area_query := PhysicsPointQueryParameters2D.new()
			area_query.position = TOP_CENTER
			area_query.collide_with_areas = true
			area_query.canvas_instance_id = canvas.get_instance_id()
			
			var collide = true if d_space.intersect_point(area_query) else false
			p_monitor.add_test_result(collide)
			
		if true:
			p_monitor.add_test("Can detect multiple collision")
			var area_query := PhysicsPointQueryParameters2D.new()
			area_query.position = CENTER
			area_query.collide_with_bodies = true
			area_query.collide_with_areas = true
			var result := d_space.intersect_point(area_query)
			p_monitor.add_test_result(result.size() == 4)
			
			
		if true:
			p_monitor.add_test("Can limit multiple collision")
			var area_query := PhysicsPointQueryParameters2D.new()
			area_query.position = CENTER
			area_query.collide_with_bodies = true
			area_query.collide_with_areas = true
			var result := d_space.intersect_point(area_query, 2)
			p_monitor.add_test_result(result.size() == 2)
			
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
	
