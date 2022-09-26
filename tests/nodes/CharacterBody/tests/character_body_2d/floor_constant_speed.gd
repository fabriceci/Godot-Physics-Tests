extends PhysicsUnitTest2D

var speed = 750
var tolerance = 1.5

func test_description() -> String:
	return """Checks that the body speed is stable in slopes when [floor_constant_speed]
	is activated.
	"""
	
func test_name() -> String:
	return "CharacterBody2D | testing [floor_constant_speed], params: [speed:%s, tolerance:%.1f]" % [speed, tolerance]

func start() -> void:
	var test_lambda = func(step, target, p_monitor):
		if step == 0: return not target.is_on_floor()
		elif step == 1: return target.is_on_floor_only()
		elif step == 2: return target.is_on_wall()
		
	var cbk_lambda = func(step: int, p_target: CharacterBody2D, is_transition: bool, p_monitor: Monitor):
		if is_transition and step == 1:
			p_target.velocity.x = speed
			p_monitor.data["speed"] = 0.0
			p_monitor.data["cpt_speed"] = 0
		elif step >= 1 and p_target.is_on_floor_only():
			p_monitor.data["speed"] += p_target.get_real_velocity().length()
			p_monitor.data["cpt_speed"] += 1
		elif step == 2:
			var average: float = p_monitor.data["speed"] / p_monitor.data["cpt_speed"]
			p_monitor.test_name += " | average=%.2f" % [average]
			if average < (speed - tolerance) or average > (speed + tolerance):
				p_monitor.failed()
	
	for i in range(2):
		var spawn_position = $SpawnBottom.position if i==0 else $SpawnTop.position
		var type = "ascending" if i== 0 else "descenting"
		var cpt := 1
		for shape_type in PhysicsTest2D.TestCollisionShape.values():
			if shape_type == PhysicsTest2D.TestCollisionShape.WORLD_BOUNDARY or shape_type == PhysicsTest2D.TestCollisionShape.CONCAVE_SEGMENT:
				continue
			var body := create_character(cpt, spawn_position, shape_type)
			add_child(body)
			var monitor := create_generic_monitor(body, test_lambda, cbk_lambda)
			monitor.test_name = "speed is constant when %s with %s"  % [type, shape_name(shape_type)]
			cpt += 1

func create_character(p_layer: int, p_position: Vector2, p_body_shape := PhysicsTest2D.TestCollisionShape.CONCAVE_POLYGON) -> CharacterBody2D:
	var character = CharacterBody2D.new()
	character.script = load("res://tests/nodes/CharacterBody/scripts/2d/character_body_2d_move_and_slide_with_gravity.gd")
	character.floor_snap_length = 100
	character.position = p_position
	character.collision_layer = 0
	character.collision_mask = 0
	character.floor_constant_speed = true
	character.floor_max_angle = deg_to_rad(50)
	character.set_collision_layer_value(p_layer, true)
	character.set_collision_mask_value(p_layer, true)
	var body_col: Node2D = get_default_collision_shape(p_body_shape, 2)
	character.add_child(body_col)
	return character
