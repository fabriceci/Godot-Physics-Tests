extends Monitor
class_name GenericMonitor

enum STEP_MODE { AUTO, MANUAL, ONE_AT_EXPIRATION }

# AUTO MODE: test using [test_lambda] the [current_step]
# -> if [false], checks if we need to pass to the next step
#	-> if the next step is returning [false], the test failed
#  	-> if the next step is [true], we increase [current_step]
# -> if [true], we do nothing
# When the [current_step] match the [total_step] the test is done

# MANUAL MODE: test using [test_lambda] the [current_step], the step should be
# Increased manually, if [test_lambda] return [false] the test failed. The test
# is done if [test_lambda] return [true] until all the step are done.

# ONE_AT_EXPIRATION: success if [test_lambda] return [true] when the time limit is done.

var mode := STEP_MODE.AUTO

var first_iteration = true
var current_step := 0
var total_step := 0
var test_lambda: Callable
var cbk_lambda: Callable
var test_name := "Generic monitor"

var target: Node
var data := {} # Dictionnary used to pass data to the monitor

func is_test_passed() -> bool:
	if mode != STEP_MODE.ONE_AT_EXPIRATION:
		return success
	return test_lambda.call(1, target, self)
	
func monitor_name() -> String:
	return test_name
	
func setup(p_test_step_lamba,  p_cbk_lambda = null, p_maximum_duration := 5.0, p_mode = STEP_MODE.AUTO):
	test_lambda = p_test_step_lamba
	cbk_lambda = p_cbk_lambda
	monitor_maximum_duration = p_maximum_duration
	mode = p_mode
	
	if mode == STEP_MODE.ONE_AT_EXPIRATION:
		total_step = 1
	else:
		var cpt = 0
		while(p_test_step_lamba.call(cpt, target, self) != null):
			cpt += 1
		total_step = cpt

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if mode == STEP_MODE.ONE_AT_EXPIRATION:
		return
	else:
		# If all steps are completed, in manual it's the total step but in [AUTO] is [total_step] as
		# [current step] + 1 is checked before the transition
		var last_step = total_step - 1 if mode == STEP_MODE.AUTO else total_step
		if current_step == last_step:
			return passed()
		
	if cbk_lambda:
		cbk_lambda.call(current_step, target, first_iteration, self)
	
	# Test according to the lambda provided
	var result = test_lambda.call(current_step, target, self)
	if first_iteration and not result:
		return failed("The verification of the first step has failed")
	first_iteration = false	
	
	if mode == STEP_MODE.AUTO:
		# If the test is false, we checks if we can pass to the next step
		if not result:
			var is_next = test_lambda.call(current_step + 1, target, self)
			
			if not is_next:
				return failed("Error during the transition from step %d to step %d" % [current_step, current_step + 1])
			else:
				current_step += 1
				if cbk_lambda:
					cbk_lambda.call(current_step, target, true, self)
	elif mode == STEP_MODE.MANUAL:
		if not result:
			return failed("Error during step %d" % [current_step])

func next_step():
	assert(mode == STEP_MODE.MANUAL, "Manual step change should only be done in manual mode.")
	current_step += 1
	if current_step == total_step:
		success = true
		return monitor_completed()
	else:
		cbk_lambda.call(current_step, target, true, self)

func failed(p_message = ""):
	error_message = p_message
	success = false
	monitor_completed()

func passed():
	success = true
	monitor_completed()
