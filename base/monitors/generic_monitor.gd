extends Monitor
class_name GenericMonitor

enum STEP_MODE { AUTO, MANUAL }

# AUTO MODE: test using [test_lambda] the [current_step]
# -> if [false], check if we need to pass to the next step
#	-> if the next step is returning [false], the test failed
#  	-> if the next step is [true], we increase [current_step]
# -> if [true], we do nothing
# When the [current_step] match the [total_step] the test is done

# MANUAL MODE: test using [test_lambda] the [current_step], the step should be
# Increased manually, if [test_lambda] return [false] the test failed. The test
# is done if [test_lambda] return [true] until all the step are done.

var mode := STEP_MODE.AUTO

var first_iteration = true
var current_step := 0
var total_step := 0
var test_lambda: Callable
var cbk_lambda: Callable
var test_name := "Generic monitor"

var target: CharacterBody2D

func monitor_name() -> String:
	return test_name
	
func setup(p_test_step_lamba,  p_cbk_lambda = null, p_maximum_duration := 5.0, p_mode = STEP_MODE.AUTO):
	test_lambda = p_test_step_lamba
	cbk_lambda = p_cbk_lambda
	monitor_maximum_duration = p_maximum_duration
	mode = p_mode
	
	var cpt = 0
	while(p_test_step_lamba.call(cpt, target) != null):
		cpt += 1
	total_step = cpt

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	# If all steps are completed
	if current_step == total_step - 1:
		success = true
		return monitor_completed()
		
	if cbk_lambda:
		cbk_lambda.call(current_step, target, first_iteration, self)
	
	# Test according to the lambda provided
	var result = test_lambda.call(current_step, target)
	if first_iteration and not result:
		error_message = "The verification of the first step has failed"
		success = false
		return monitor_completed()
	first_iteration = false	
	
	if mode == STEP_MODE.AUTO:
		# If the test is false, we check if we can pass to the next step
		if not result:
			var is_next = test_lambda.call(current_step + 1, target)
			
			if not is_next:
				error_message = "Error during the transition from step %d to step %d" % [current_step, current_step + 1]
				success = false
				return monitor_completed()
			else:
				current_step += 1
				if cbk_lambda:
					cbk_lambda.call(current_step, target, true, self)
	elif mode == STEP_MODE.MANUAL:
		error_message = "Error during step %d" % [current_step, current_step + 1]
		success = false
		return monitor_completed()

func next_step():
	assert(mode == STEP_MODE.AUTO, "Manual step change should only be done in manual mode.")
	current_step += 1
	if current_step == total_step:
		success = true
		return monitor_completed()
	else:
		cbk_lambda.call(current_step, target, true, self)
