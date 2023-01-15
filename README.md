# Unit tests for Godot Physics

This project aims to provide automated tests for Godot Physics Engine. This will help find regression on PR, fix a bug, test a physical engine (like an extension). Eventually the project will be added to the Godot Engine CI.

## General design

Avoid using nodes in the editor as much as possible, this has two advantages:

- it makes it easier to detect changes in the engine API
- it is easier to understand how a test works

If you need to use nodes, e.g. to draw a polygon, create a body, use only the basic editor fields (transformations, collision shape, etc.), if you need to modify the properties of objects, modify them in the code.

Note: when you start the project it runs all the tests, but **you can also run the scene that contains a unit test or the scene that contains all unit tests for a node or feature.**

## Files structure

### Main files

- `start.tscn`: the main scene that will run all regression tests
- `tests/nodes/[name]/`: folder containing the unit tests for specific nodes
- `tests/features/[name]/`: folder containing the unit tests for more complex physics features
- `tests/performance/[name]/`: small benchmarks of the engine performance, they must be run manually

### Unit test folder:

- `xxxx_[2d|3d].tscn` : contains all the unit tests for the feature/node. The root node of the scene is a `Node2D|3D`  with **a build in script** that extends `TestScene`. In this scene you will add an instance of all the unit tests, this can allow you to add multiple instances of the same unit test with different editor settings
- `tests/sub_folder/*.tscn`: a unit test scene, the root node of the scene is a`Node2D|3D` with a script that extends `PhysicsUnitTest2D|3D` and implements 3 methods:

  - `test_description()`: return a full description of the unit test
  - `test_name()`: return the name of the unit test
  - `test_start()`: the test code which generally means adding one or more monitors (sub-tests)
  
## Write a monitor

In the `test_start()` method of your `PhysicsUnitTest2D|3D` file, you need to add at least one monitor, there are 3 generic monitors provided by default to easily create a test, but you can create a custom one if you need to.

Don't hesitate to look at existing tests.

Note: to create a monitor you must provide a callback function (`Callable`), **be careful - the method signature of the `Callable` must include all parameters, even the ones you don't use**.

### The expiration monitor

This monitor will wait a certain `[duration]` then execute a `Callable` that will return `true` if the test succeeded, otherwise `false`.

**Example:**

```python
var lambda: Callable = func(p_target, p_monitor: GenericExpirationMonitor):
	return body.sleeping
 
var monitor = create_generic_expiration_monitor(self, lambda, null, simulation_duration)
monitor.test_name = "sub test name"
```

`create_generic_expiration_monitor` takes as parameter:

1. a node that will be the parent of the monitor and will be sent as `p_target` to the test callback
2. a test callback (`Callable`)
3. an optional physics callback (`Callable`) that will be called on each physics steps
4. the duration of the test

You can give details of the error by assigning a `String`to `p_monitor.error_message`.

### The manual monitor

This monitor is the most flexible, it allows you to decide when a test has passed or failed. You can define several sub-tests within a test.

`create_generic_manual_monitor` takes as parameter:

1. a node that will be the parent of the monitor and will be sent as `p_target` to the test callback
2. a test callback (`Callable`) where you will manually indicate whether the test has failed or not
3. the duration of the test
4. set the behavior when the monitor reach the end of the simulation/duration, by default the parameter `fail_on_expiration` is set the `false`, which means that is considered as failed.

**Example of single test**

```python
var test_cbk = func(p_target, p_monitor: GenericManualMonitor):
	if p_monitor.frame == 60: # wait until the 60th frame before running the test.
		if  body.rotation == 0:
			p_monitor.passed()
   		else:
			p_monitor.failed(“Rotation is not equal to 0”)

var check_max_stability_monitor = create_generic_manual_monitor(self, test_cbk, simulation_duration)
check_max_stability_monitor.test_name = "Testing stability"
```

You can give details of the error by passing a `String` to `p_monitor.failed`.

**Example of multi test**

```python
Example:
var test_cbk = func(p_target, p_monitor: GenericManualMonitor):
	if true: # limit the variables scope
		p_monitor.add_test("Don't collide at 1px left from the body")
		var body_query := PhysicsPointQueryParameters2D.new()
		var result := d_space.intersect_point(body_query)
		p_monitor.add_test_result(result.size() == 0)
	if true:
		p_monitor.add_test("Should detect one collision inside the canvas")
		var area_query := PhysicsPointQueryParameters2D.new()
		var result := d_space.intersect_point(area_query)
		if result.size() > 1:
			p_monitor.add_test_error("Found too many results.")
		p_monitor.add_test_result(result.size() == 1)
		
	p_monitor.monitor_completed()
```

- The tests need to be run in order.
- You can give details of the error by calling `p_monitor.add_test_error`, and even call it multiple times to add multiple errors.

### The auto step monitor

Most of the time it's better to use the manual monitor than this one. This monitor will test a succession of steps. The callback function will perform a series of tests depending on the step the test is in (`p_step`). As long as the test is false, the step remains the same, when the test is true, we move on to the next step, which must be false, and then we repeat until the end of the test.

**Example:**

```python
var test_lambda = func(p_step, p_target: CharacterBody2D, p_monitor: GenericStepMonitor):
	if p_step == 0: return p_target.get_slide_collision_count() == 0
	elif p_step == 1: return p_target.is_on_wall_only()
	elif p_step == 2: return p_target.is_on_wall() and target.is_on_ceiling()
	elif p_step == 3: return p_target.is_on_ceiling_only()
	
var physics_step_cbk = func(p_step: int, p_target: CharacterBody2D, is_transition: bool, p_monitor: GenericStepMonitor):
	if p_step == 0: p_target.velocity = Vector2(speed, 0) 
	elif p_step < 2: p_target.velocity = Vector2(speed, -speed)

var contact_monitor := create_generic_step_monitor(character, test_lambda, physics_step_cbk, simulation_duration)
contact_monitor.test_name = "sub test name"
```

1. a node that will be the parent of the monitor and will be sent as `p_target` to the test callback
2. a test callback (`Callable`)
3. a physics callback (`Callable`) that will be called on each physics steps
4. the maximum duration of the test

You can give details of the error by assigning a `String`to `p_monitor.error_message`.

### When a test fails because of a bug

If a bug is detected and you are not in the process of fixing it, you can indicate that this test is expected to fail, this allows the project to track regressions.

In a single monitor test, you must set the boolean `expected_to_fail` to `true`, example: `monitor.expected_to_fail = true`.

In a manual, multi-monitor test, you can set this boolean by calling `add_test_expected_to_fail()` after the the call of `add_test()`.

#### Physics engine other than GodotPhysics

If you wish to use the project to test/find regressions on another physics engine, it may happen that a test/feature cannot be implemented for that engine.

You can indicate this:
- in a single monitor test: by inserting the engine name in the array `engine_expected_to_fail`
- in a multi-test, by calling the `add_test_engine_expected_to_fail(Array[String])` method

## Tips

### Constants

There are constants in the `Global.gd` file to customize the execution of the tests.

### Debugging a test

You can press `P` to switch to Frame by Frame mode, in this mode, press `O` to move to the next frame or `P` a second time to exit this mode. This is a very easy way to debug a test, if you want to start a test in pause mode, edit the `base/pause.gd` file and set the first variable `var paused = false` to `true`. 

### Monitor extra fields

  - `monitor.frame`: return the current frame (since the test started)
  - `monitor.data`: an array where you can store/retrieve extra data
  - `expected_to_fail`: return `true` if the monitor, in the current state of the engine, is expected to fail
