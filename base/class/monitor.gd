extends Node
class_name Monitor
signal completed

var monitor_duration := 0.0
var monitor_maximum_duration := 10.0
var error_message := ""
var success := false
var started := false

var text: String:
	set(value):
		text = value

func _init() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED

func start() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	started = true

func is_test_passed() -> bool:
	return success
	
func _process(delta: float) -> void:
	# Maximum duration
	monitor_duration += delta
	if monitor_duration > monitor_maximum_duration:
		error_message = "The maximum duration has been exceeded (> %.1f s)" % [monitor_maximum_duration]
		return monitor_completed()

func monitor_name() -> String:
	@warning_ignore(assert_always_false)
	assert(false, "ERROR: You must implement monitor_name()")
	return ""

func monitor_completed() -> void:
	completed.emit()
	process_mode = PROCESS_MODE_DISABLED

