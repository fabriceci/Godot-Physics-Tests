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
var DEBUG := false
var VERBOSE := true
var NB_TESTS_COMPLETED := 0
var MONITOR_PASSED := 0
var MONITOR_FAILED := 0
var MONITOR_EXPECTED_TO_FAIL: Array[String] = []
var MONITOR_REGRESSION: Array[String] = []
var MONITOR_IMRPOVEMENT: Array[String] = []
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

func print_summary(duration: float) -> void:
	var status = "FAILED" if Global.MONITOR_REGRESSION.size() != 0 else "SUCCESS"
	var color = "red" if Global.MONITOR_REGRESSION.size() != 0 else "green"
	print_rich("[color=%s] > COMPLETED IN %.2fs | STATUS: %s (PASSED MONITORS: %d/%d)[/color]" % [color, duration, status, Global.MONITOR_PASSED, Global.MONITOR_PASSED + Global.MONITOR_FAILED])
	if Global.MONITOR_REGRESSION.size() != 0:
		print_rich("\n[indent]%d Regression(s):[/indent]" % [Global.MONITOR_REGRESSION.size()])
		var cpt := 0
		for regression in Global.MONITOR_REGRESSION:
			cpt += 1
			print_rich("[indent][indent][color=red]%d. %s[/color][/indent][/indent]" % [cpt, regression])
	if Global.MONITOR_IMRPOVEMENT.size() != 0:
		print_rich("\n[indent]%d Improvement(s):[/indent]" % [Global.MONITOR_REGRESSION.size()])
		var cpt := 0
		for improvement in Global.MONITOR_IMRPOVEMENT:
			cpt += 1
			print_rich("[indent][indent][color=green]%d. %s[/color][/indent][/indent]" % [cpt, improvement])

	if Global.VERBOSE and Global.MONITOR_EXPECTED_TO_FAIL.size() != 0:
		print_rich("\n[indent]%d Monitor(s) expected to fail:[/indent]" % [Global.MONITOR_EXPECTED_TO_FAIL.size()])
		var cpt := 0
		for expected in Global.MONITOR_EXPECTED_TO_FAIL:
			cpt += 1
			print_rich("[indent][indent]%d. %s[/indent][/indent]" % [cpt, expected])
