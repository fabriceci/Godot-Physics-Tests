extends PhysicsUnitTest2D

@export var body_shape: PhysicsTest2D.TestCollisionShape = TestCollisionShape.RECTANGLE
var jump_force := -2000
var spawn_position := Vector2(280, 320)
var max_x_position := 145

func test_description() -> String:
	return """Testing [slide_on_ceiling], when ON, the body will slide on the ceiling (position.x will change),
	and when it's off, the body should not have his position.x be changed.
	"""

func test_name() -> String:
	return "CharacterBody2D | testing slide on ceiling [shape: %s]" % [shape_name(body_shape)]
	
func start() -> void:
	# C1 Jump in the ceiling and expect to move in x
	var character1 = create_character(1)
	character1.slide_on_ceiling = true
	character1.floor_max_angle = deg2rad(80)
	add_child(character1)
	
	var c1_test_lambda = func(step, target, monitor):
		if step == 0: return not target.is_on_floor()
		elif step == 1: return target.is_on_floor()
		elif step == 2: return not target.is_on_floor() and not target.is_on_ceiling()
		elif step == 3: return target.is_on_ceiling()
		elif step == 4: return target.position.x < 450
		elif step == 5: return target.position.x >= 450
	
	var cbk_lambda = func(p_step, p_target, p_is_transition := false, p_monitor = null):
		if p_is_transition and p_step == 1:
			p_target.velocity.y = jump_force

	var c1_monitor := create_generic_monitor(character1, c1_test_lambda, cbk_lambda)
	c1_monitor.test_name = "Slide enough to go through the platform"

	# C2 without slide on ceiling, the body should not move in x
	var character2 = create_character(2)
	character2.slide_on_ceiling = false
	character2.floor_max_angle = deg2rad(80)
	add_child(character2)

	var c2_test_lambda = func(step, target, monitor):
		if step == 0: return not target.is_on_floor()
		elif step == 1: return target.is_on_floor()
		elif step == 2: return not target.is_on_floor() and not target.is_on_ceiling()
		elif step == 3: return target.is_on_ceiling()
		elif step == 4: return is_equal_approx(target.position.x, spawn_position.x)

	var c2_monitor := create_generic_monitor(character2, c2_test_lambda, cbk_lambda)
	c2_monitor.test_name = "Without sliding, the x position of the body will not change"

func create_character(layer: int) -> CharacterBody2D:
	var character = CharacterBody2D.new()
	character.script = load("res://tests/nodes/CharacterBody/scripts/2d/character_body_2d_move_and_slide_with_gravity.gd")
	character.collision_layer = 0
	character.collision_mask = 0
	character.position = spawn_position
	character.set_collision_layer_value(layer, true)
	character.set_collision_mask_value(layer, true)
	var body_col: Node2D = get_default_collision_shape(body_shape, 2)
	character.add_child(body_col)
	return character
