extends Node
class_name Monitor
signal completed

var multi_test_list: Array[Dictionary] = []
var multi_test_current := 0
var monitor_duration := 0.0
var monitor_maximum_duration := 10.0
var error_message := ""
var success := false
var started := false
var frame := 0 # physics frame

var text: Dictionary:
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
	
func failed(p_message = ""):
	error_message = p_message
	success = false
	monitor_completed()

func passed():
	success = true
	monitor_completed()

func add_sub_test(name: String) -> void:
	multi_test_list.append({
		"name": name,
		"result": false,
		"errors": [],
	})

func add_test_error(p_error: String):
	multi_test_list[multi_test_current].errors.append(p_error)

func add_test_result(p_result: bool):
	multi_test_list[multi_test_current].result = p_result
	multi_test_current += 1
