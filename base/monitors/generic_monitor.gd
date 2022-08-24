extends Monitor
class_name GenericMonitor

enum STEP_MODE { AUTO, MANUAL, EXPIRATION }

# AUTO MODE: test using [test_lambda] the [current_auto_step]
# -> if [false], checks if we need to pass to the next step
#	-> if the next step is returning [false], the test failed
#  	-> if the next step is [true], we increase [current_auto_step]
# -> if [true], we do nothing
# When the [current_auto_step] match the [total_step] the test is done

# MANUAL MODE: test using [test_lambda] the [current_auto_step], the step should be
# Increased manually, the test is done when [passed()] or [failed()] are called.

# EXPIRATION: success if [test_lambda] return [true] when the time limit is done.

var mode := STEP_MODE.AUTO

var first_iteration = true
var current_auto_step := 0
var total_step := 0
var test_lambda: Callable
var cbk_lambda: Callable
var test_name := "Generic monitor"
var auto_steps_name := {} # Dictionnary with the name of sub steps
var auto_failure_step := 0

var target: Node
var data := {} # Dictionnary used to pass data to the monitor

func is_test_passed() -> bool:
	if mode != STEP_MODE.EXPIRATION:
		return success
	return test_lambda.call(1, target, self)
	
func monitor_name() -> String:
	return test_name
	
func setup(p_test_step_lamba,  p_cbk_lambda = null, p_maximum_duration := 5.0, p_mode = STEP_MODE.AUTO):
	test_lambda = p_test_step_lamba
	cbk_lambda = p_cbk_lambda
	monitor_maximum_duration = p_maximum_duration
	mode = p_mode
	
	if mode == STEP_MODE.AUTO:
		var cpt = 0
		while(p_test_step_lamba.call(cpt, target, self) != null):
			cpt += 1
		total_step = cpt

# Overload the method to avoid [error_message] for [EXPIRATION] mode
func _process(delta: float) -> void:
	# Maximum duration
	monitor_duration += delta
	if monitor_duration > monitor_maximum_duration:
		if mode != STEP_MODE.EXPIRATION:
			error_message = "The maximum duration has been exceeded (> %.1f s)" % [monitor_maximum_duration]
		return monitor_completed()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if mode == STEP_MODE.EXPIRATION:
		return
	elif mode == STEP_MODE.AUTO:
		# If all steps are completed
		var last_step = total_step - 1
		if current_auto_step == last_step:
			return passed()
		
	if cbk_lambda:
		cbk_lambda.call(current_auto_step, target, first_iteration, self)
	
	# Test according to the lambda provided
	var result = test_lambda.call(current_auto_step, target, self)
	if mode == STEP_MODE.AUTO and first_iteration and not result:
		return failed("The verification of the first step has failed")
	first_iteration = false	
	
	if mode == STEP_MODE.AUTO:
		# If the test is false, we checks if we can pass to the next step
		if not result:
			var is_next = test_lambda.call(current_auto_step + 1, target, self)
			
			if not is_next:
				auto_failure_step = current_auto_step + 1
				return failed("Error during the transition from step %d to step %d" % [current_auto_step, current_auto_step + 1])
			else:
				current_auto_step += 1
				if cbk_lambda:
					cbk_lambda.call(current_auto_step, target, true, self)

func next_step():
	current_auto_step += 1
	cbk_lambda.call(current_auto_step, target, true, self)

func failed(p_message = ""):
	error_message = p_message
	success = false
	monitor_completed()

func passed():
	success = true
	monitor_completed()
