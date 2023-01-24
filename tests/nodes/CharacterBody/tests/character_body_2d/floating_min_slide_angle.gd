extends PhysicsUnitTest2D

var speed := 750
var simulation_duration := 1

@onready var spawn_1 := $Spawn1 # max_x < 800
@onready var spawn_2 := $Spawn2 # max_x > 800

func test_description() -> String:
	return """Checks if [wall_min_slide_angle] is working properly. The body should not slide when
	meeting a wall at an angle less than [wall_min_slide_angle].
	"""
	
func test_name() -> String:
	return "CharacterBody2D | testing [wall_min_slide_angle]"

func test_start() -> void:
	var callback_lambda = func(p_target: CharacterBody2D, p_monitor: GenericExpirationMonitor):
		if p_target.position.x > p_monitor.data["maximum_x"]:
			p_monitor.data["maximum_x"] = p_target.position.x
	
	var character_lower := create_character(spawn_1.position)
	
	var test_lambda_lower: Callable = func(p_target: CharacterBody2D, p_monitor: GenericExpirationMonitor):
		return p_monitor.data["maximum_x"] < 525
	
	var monitor_angle_lower := create_generic_expiration_monitor(character_lower, test_lambda_lower, callback_lambda, simulation_duration)
	monitor_angle_lower.test_name = "The body stops when hitting at an angle less than [wall_min_slide_angle]"
	monitor_angle_lower.data["maximum_x"] = 0

	var character_higher := create_character(spawn_2.position)
	
	var test_lambda_higher: Callable = func(p_target: CharacterBody2D, p_monitor: GenericExpirationMonitor):
		return p_monitor.data["maximum_x"] > 525
	
	var monitor_angle_greater := create_generic_expiration_monitor(character_higher, test_lambda_higher, callback_lambda, simulation_duration)
	monitor_angle_greater.test_name = "The body slides when hitting at an angle greater than [wall_min_slide_angle]"
	monitor_angle_greater.data["maximum_x"] = 0
	
func create_character(p_position: Vector2, p_body_shape := PhysicsTest2D.TestCollisionShape.RECTANGLE) -> CharacterBody2D:
	var character = CharacterBody2D.new()
	character.script = load("res://tests/nodes/CharacterBody/scripts/2d/character_body_2d_move_and_slide.gd")
	character.position = p_position
	character.velocity = Vector2(speed, 0.0)
	character.motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	var body_col: Node2D = PhysicsTest2D.get_default_collision_shape(p_body_shape, 2)
	character.add_child(body_col)
	add_child(character)
	return character
