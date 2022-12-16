extends Monitor
class_name GenericStepMonitor

# This monitor works will send [current_step] to [test_lambda]
# -> if [test_lambda] return [false], it will pass send the number of the next step ([current_step + 1]
#	-> if the next step is returning [false], the test failed
#  	-> if the next step is [true], we increase [current_step]
# -> if [true], we do nothing
# When the [current_step] match the [total_step] the test is done

# Callback
# var physics_step_cbk = func(step: int, p_target, is_transition: bool, p_monitor: Monitor):
# var test_lambda = func(step: int, target, p_monitor: Monitor):

var first_iteration = true
var current_step := 0
var total_step := 0
var test_lambda: Callable
var physics_step_cbk = null
var test_name := "Auto Step Monitor"
var auto_steps_name := {} # Dictionnary with the name of sub steps

var target: Node
var data := {} # Dictionnary used to pass data to the monitor
	
func monitor_name() -> String:
	return test_name
	
func setup(p_test_step_lamba: Callable,  p_physics_step_cbk = null, p_maximum_duration := 5.0):
	test_lambda = p_test_step_lamba
	physics_step_cbk = p_physics_step_cbk
	monitor_maximum_duration = p_maximum_duration

	var cpt = 0
	while(p_test_step_lamba.call(cpt, target, self) != null):
		cpt += 1
	total_step = cpt

# Overload the method to avoid [error_message] for [EXPIRATION] mode
func _process(delta: float) -> void:
	# Maximum duration
	monitor_duration += delta
	if monitor_duration > monitor_maximum_duration:
		error_message = "The maximum duration has been exceeded (> %.1f s)" % [monitor_maximum_duration]
		return monitor_completed()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:

	# If all steps are completed
	var last_step = total_step - 1
	if current_step == last_step:
		return passed()
	
	if physics_step_cbk:
		physics_step_cbk.call(current_step, target, first_iteration, self)

	# Test according to the lambda provided
	var result = test_lambda.call(current_step, target, self)
	if first_iteration and not result:
		return failed("The verification of the first step has failed")
	first_iteration = false	
	
	# If the test is false, we checks if we can pass to the next step
	if not result:
		var is_next = test_lambda.call(current_step + 1, target, self)
		
		if not is_next:
			return failed("Error during the transition from step %d to step %d" % [current_step, current_step + 1])
		else:
			current_step += 1
			if physics_step_cbk:
				physics_step_cbk.call(current_step, target, true, self)
