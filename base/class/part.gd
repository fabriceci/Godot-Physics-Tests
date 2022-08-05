extends Node
class_name Part

var text: String:
	set(value):
		text = value

func _init() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED

func start(_p_target: Node) -> void:
	process_mode = Node.PROCESS_MODE_INHERIT

func part_name() -> String:
	@warning_ignore(assert_always_false)
	assert(false, "ERROR: You must implement part_name()")
	return ""

func get_score() -> float:
	return -1.0
