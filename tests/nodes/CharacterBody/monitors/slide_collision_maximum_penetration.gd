extends Monitor

@export var tolerance := 1.0

var penetrated := false
var target: CharacterBody2D

func is_test_passed() -> bool:
	return not penetrated

func monitor_name() -> String:
	return "Maximum penetration <= %f" % [tolerance]

func _physics_process(_delta: float) -> void:
	if not penetrated:
		for i in target.get_slide_collision_count():
			var col = target.get_slide_collision(i)
			var shape_a = col.get_local_shape()
			var shape_b = col.get_collider_shape()
			if shape_a is CollisionShape2D and shape_b is CollisionShape2D:
				#print('TEST: ', shape_a.global_position, ' ', shape_a.shape, ' ', shape_b.global_position, ' ', shape_b.shape)
				pass
			else:
				#print('TEST: other shapes')
				pass
			# TODO: overlap test. can use engine???
	if penetrated:
		text = 'penetrated'
	else:
		text = 'not penetrated'
