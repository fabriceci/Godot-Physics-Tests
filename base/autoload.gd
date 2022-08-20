extends Node

enum TEST_MODE {
	REGRESSION,
	QUALITY,
	PERFORMANCE
}

# View
var WINDOW_SIZE := Vector2(1024,600)
var NUMBER_TEST_PER_ROW := 2
var MAXIMUM_PARALLEL_TESTS := NUMBER_TEST_PER_ROW * NUMBER_TEST_PER_ROW

# Output
var VERBOSE := false
var NB_TESTS_COMPLETED := 0
var MONITOR_PASSED := 0
var MONITOR_FAILED := 0

func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	get_tree().debug_collisions_hint = true

func exit(p_code := 0) -> void:
	await get_tree().create_timer(1).timeout # sometimes the application quits before printing everything in the output
	get_tree().quit(p_code)
