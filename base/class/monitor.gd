extends Node
class_name Monitor

var text: String:
	set(value):
		text = value

func _init() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED

func start() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT

func monitor_name() -> String:
	@warning_ignore(assert_always_false)
	assert(false, "ERROR: You must implement monitor_name()")
	return ""
