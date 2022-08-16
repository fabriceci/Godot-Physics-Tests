extends Monitor

var success := true
var current_step := 0
var total_step := 0
var monitor_duration := 0.0
var monitor_maximum_duration := 10.0
var test_lambda: Callable
var cbk_lambda: Callable
var test_name := "Step monitor"

var target: CharacterBody2D

var first_iteration = true

func is_test_passed() -> bool:
	return success

func monitor_name() -> String:
	return test_name

func setup(p_test_lamba, p_total_step, p_cbk_lambda = null, p_maximum_time := 10.0):
	test_lambda = p_test_lamba
	total_step = p_total_step
	cbk_lambda = p_cbk_lambda
	monitor_maximum_duration = p_maximum_time

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if cbk_lambda:
		cbk_lambda.call(current_step, target)
		
	# Maximum duration
	monitor_duration += delta
	if monitor_duration > monitor_maximum_duration:
		error_message = "The maximum duration has been exceeded"
		success = false
		return monitor_completed()
	
	# If all steps are completed
	if current_step == total_step - 1:
		success = true
		return monitor_completed()
	
	# Launch the callback for the first step
	if first_iteration and cbk_lambda:
		cbk_lambda.call(current_step, target)
	
	# Test according to the lambda provided
	var result = test_lambda.call(current_step, target)
	if first_iteration and not result:
		error_message = "The verification of the first step has failed"
		success = false
		return monitor_completed()
	first_iteration = false	
	
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
				cbk_lambda.call(current_step, target, true)
