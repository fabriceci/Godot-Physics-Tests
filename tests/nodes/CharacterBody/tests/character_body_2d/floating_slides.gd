extends PhysicsUnitTest2D

var speed := 750
var simulation_duration := 1.0
var tolerance := 0.001 # 1/1000 of speed

@onready var spawn_1 := $Spawn1
@onready var spawn_2 := $Spawn2
@onready var spawn_3 := $Spawn3
@onready var spawn_4 := $Spawn4

func test_description() -> String:
	return """Checks that bodies in FLOATING mode slide properly on walls.
	"""
	
func test_name() -> String:
	return "CharacterBody2D | testing FLOATING mode sliding"

func test_start() -> void:
	var callback_lambda = func(p_target: CharacterBody2D, p_monitor: GenericExpirationMonitor):
		pass

	var test_lambda: Callable = func(p_target: CharacterBody2D, p_monitor: GenericExpirationMonitor):
		return (not p_target.is_on_wall()) \
				and (p_target.velocity - p_monitor.data["target_v"]).length() < speed * tolerance
	
	var test_lambda_stop: Callable = func(p_target: CharacterBody2D, p_monitor: GenericExpirationMonitor):
		return p_target.is_on_wall() and p_target.velocity.is_zero_approx()
	
	var character_1 := create_character(spawn_1.position, 1)
	var monitor_1 := create_generic_expiration_monitor(character_1, test_lambda_stop, callback_lambda, simulation_duration)
	monitor_1.test_name = "The body stops when hitting perpendicularly"
	
	var character_2 := create_character(spawn_2.position, 2)
	var monitor_2 := create_generic_expiration_monitor(character_2, test_lambda, callback_lambda, simulation_duration)
	monitor_2.test_name = "The body slides correctly at 30 degrees"
	monitor_2.data["target_v"] = speed * Vector2(sin(PI/6),0.0).rotated(-PI/3)
	
	var character_3 := create_character(spawn_3.position, 3)
	var monitor_3 := create_generic_expiration_monitor(character_3, test_lambda, callback_lambda, simulation_duration)
	monitor_3.test_name = "The body slides correctly at 45 degrees"
	monitor_3.data["target_v"] = speed * Vector2(sin(PI/4),0.0).rotated(-PI/4)
	
	var character_4 := create_character(spawn_4.position, 4)
	var monitor_4 := create_generic_expiration_monitor(character_4, test_lambda, callback_lambda, simulation_duration)
	monitor_4.test_name = "The body slides correctly at 60 degrees"
	monitor_4.data["target_v"] = speed * Vector2(sin(PI/3),0.0).rotated(-PI/6)
	
func create_character(p_position: Vector2, p_layer : int, p_body_shape := PhysicsTest2D.TestCollisionShape.RECTANGLE) -> CharacterBody2D:
	var character = CharacterBody2D.new()
	character.script = load("res://tests/nodes/CharacterBody/scripts/2d/character_body_2d_move_and_slide.gd")
	character.position = p_position
	character.velocity = Vector2(speed, 0.0)
	character.collision_layer = 0
	character.collision_mask = 0
	character.set_collision_layer_value(p_layer, true)
	character.set_collision_mask_value(p_layer, true)
	character.motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	character.wall_min_slide_angle = 0 # covered by another test
	var body_col: Node2D = PhysicsTest2D.get_default_collision_shape(p_body_shape, 2)
	character.add_child(body_col)
	add_child(character)
	return character
