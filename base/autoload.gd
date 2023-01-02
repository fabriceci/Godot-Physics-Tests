extends Node

enum TEST_MODE {
	REGRESSION,
	QUALITY,
	PERFORMANCE
}

# View
var WINDOW_SIZE := Vector2(1152,648)
var NUMBER_TEST_PER_ROW := 2
var MAXIMUM_PARALLEL_TESTS := NUMBER_TEST_PER_ROW * NUMBER_TEST_PER_ROW

# Output
var VERBOSE := false
var NB_TESTS_COMPLETED := 0
var MONITOR_PASSED := 0
var MONITOR_FAILED := 0
var TEST_PASSED := 0

var RUN_2D_TEST := true
var RUN_3D_TEST := true

var PERFORMANCE_RESULT := {}

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		exit()

func _ready() -> void:
	get_tree().debug_collisions_hint = true

func exit(p_code := 0) -> void:
	await get_tree().create_timer(1).timeout # sometimes the application quits before printing everything in the output
	get_tree().quit(p_code)
