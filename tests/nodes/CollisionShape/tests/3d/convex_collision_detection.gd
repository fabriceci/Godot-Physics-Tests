extends PhysicsUnitTest3D

var simulation_duration := 6
var test_failed := false

func test_description() -> String:
	return """Checks whether the collision detection of convex shapes is correct by comparing 
	the result given by the convex cube with the result given by a primitive cube.
	"""
	
func test_name() -> String:
	return "CollisionShape3D | testing convex collision detection"
	
var tested_body: CharacterBody3D
var reference_body: CharacterBody3D
var static_body: CharacterBody3D

var rot_cpt_x = 0.06

func start() -> void:
	tested_body = create_body(1, PhysicsTest3D.TestCollisionShape.CONVEX_POLYGON)
	reference_body = create_body(2, PhysicsTest3D.TestCollisionShape.BOX)
	
	tested_body.position = Vector3(-0.7, 0, 0)
	reference_body.position = tested_body.position
	
	static_body = create_body(1, PhysicsTest3D.TestCollisionShape.BOX)
	static_body.position = Vector3(0.7, 0, 0)
	static_body.set_collision_layer_value(2, true)
	static_body.set_collision_mask_value(2, true)
	static_body.rotation.z = deg_to_rad(45)
	
	var callback_lambda = func(p_target, p_monitor: Monitor):
		tested_body.rotation.x += rot_cpt_x
		reference_body.rotation.x += rot_cpt_x
		tested_body.rotation.y += rot_cpt_x / 2
		reference_body.rotation.y += rot_cpt_x / 2
		tested_body.rotation.z += rot_cpt_x / 3
		reference_body.rotation.z += rot_cpt_x / 3

		static_body.rotation.x += rot_cpt_x / 3
		static_body.rotation.z += rot_cpt_x / 2
		static_body.rotation.y += rot_cpt_x
		
		var t_collide = false
		var t_normal = Vector3.ZERO
		var r_collide = false
		var r_normal = Vector3.ZERO


		var ref_collide := reference_body.move_and_collide(Vector3.ZERO, true)
		if ref_collide:
			r_collide = true
			r_normal = ref_collide.get_normal()
		
		var tested_collide := tested_body.move_and_collide(Vector3.ZERO, true)
		if tested_collide:
			t_collide = true
			t_normal = ref_collide.get_normal()
		
		if t_collide != r_collide:
			test_failed = true
		if not r_normal.is_equal_approx(t_normal):
			test_failed = true
			
	var test_lambda: Callable = func(p_target, p_monitor):
		return not test_failed

	var collision_monitor = create_generic_expiration_monitor(self, test_lambda, callback_lambda, simulation_duration)
	collision_monitor.test_name = "Convex collisions are detected correctly"

func create_body(p_layer: int, p_shape: PhysicsTest3D.TestCollisionShape):
	var _body := CharacterBody3D.new()
	var _shape = get_default_collision_shape(p_shape)
	_body.add_child(_shape)
	for i in range(1, 17):
		_body.set_collision_layer_value(i, false)
		_body.set_collision_mask_value(i, false)
	_body.set_collision_layer_value(p_layer, true)
	_body.set_collision_mask_value(p_layer, true)
	add_child(_body)
	return _body
