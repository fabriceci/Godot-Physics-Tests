extends Monitor
class_name GenericManualMonitor

# MANUAL MODE: test using [test_lambda] the [current_step], the step should be
# Increased manually, the test is done when [passed()] or [failed()] are called.

# Callback
# var physics_step_cbk = func(p_target, p_monitor: Monitor):
# var test_lambda = func(target, p_monitor: Monitor):

var first_iteration = true
var current_step := 0
var test_lambda: Callable
var test_name := "Generic Manual Monitor"

var target: Node
var data := {} # Dictionnary used to pass data to the monitor
	
func monitor_name() -> String:
	return test_name
	
func setup(p_test_lambda: Callable, p_maximum_duration := 5.0):
	test_lambda = p_test_lambda
	monitor_maximum_duration = p_maximum_duration

# Overload the method to avoid [error_message] for [EXPIRATION] mode
func _process(delta: float) -> void:
	# Maximum duration
	monitor_duration += delta
	if monitor_duration > monitor_maximum_duration:
		error_message = "The maximum duration has been exceeded (> %.1f s)" % [monitor_maximum_duration]
		return monitor_completed()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	test_lambda.call(target, self)
	first_iteration = false	
