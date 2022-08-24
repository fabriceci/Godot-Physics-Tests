extends PhysicsUnitTest2D

var speed := 1500
var simulation_duration := 2.0

func test_description() -> String:
	return """Checks that the surface is detected (wall, ground, ceiling), if the body maintains pressure,
	we should have 2 surfaces detected in the corners and one otherwise.
	"""

func test_name() -> String:
	return "CharacterBody2D | testing surface detection when the body constantly push against the surface"

func start() -> void:
	add_collision_boundaries(150)
	
	# checks all collision type
	var test_lambda = func(step, target, monitor):
			if step == 0: return target.get_slide_collision_count() == 0
			elif step == 1: return target.is_on_wall_only()
			elif step == 2: return target.is_on_wall() and target.is_on_ceiling()
			elif step == 3: return target.is_on_ceiling_only()
			elif step == 4: return target.is_on_wall() and target.is_on_ceiling()
			elif step == 5: return target.is_on_wall_only()
			elif step == 6: return target.is_on_wall() and target.is_on_floor()
			elif step == 7: return target.is_on_floor_only()
	
	var cbk_lambda = func(step: int, target: CharacterBody2D, is_transition: bool, p_monitor: Monitor):
		if step == 0: target.velocity = Vector2(speed, 0) # right
		elif step < 2: target.velocity = Vector2(speed, -speed) # up right
		elif step < 4: target.velocity = Vector2(-speed, -speed) # up left
		elif step < 6: target.velocity = Vector2(-speed, speed) # down left
		elif step == 6: target.velocity = Vector2(speed, speed) # down right
	
	var cpt_layer := 1
	for shape_type in PhysicsTest2D.TestCollisionShape.values():
		# Create character
		var character = CharacterBody2D.new()
		character.script = load("res://tests/nodes/CharacterBody/scripts/2d/character_body_2d_move_and_slide.gd")
		character.motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
		character.position = CENTER
		character.collision_layer = 0
		character.collision_mask = 0
		character.set_collision_layer_value(cpt_layer, true)
		character.set_collision_mask_value(cpt_layer, true)
		
		var body_col: Node2D = get_default_collision_shape(shape_type, 2)
		character.add_child(body_col)
		
		add_child(character)

		var contact_monitor := create_generic_monitor(character, test_lambda, cbk_lambda, simulation_duration)
		contact_monitor.test_name = "%s detects collisions correctly" % [shape_name(shape_type)]
		
		cpt_layer += 1
