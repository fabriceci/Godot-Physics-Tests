class_name TestScene
extends Node

var runner: TestRunner

func _ready() -> void:
	if get_tree().get_root() == get_parent(): # autostart if the scene is executed alone
		start()

func start() -> void:
	runner = TestRunner.new(self)
	runner.completed.connect(self.completed)
	var is_performance := false
	for child in get_children():
		if child is PhysicsPerformanceTest2D or child is PhysicsPerformanceTest3D:
			is_performance = true
			runner.add_test(child)
		if child is PhysicsTest2D:
			runner.add_test(child)
	
	if is_performance:
		Global.NUMBER_TEST_PER_ROW = 1
		Global.MAXIMUM_PARALLEL_TESTS = 1
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	runner.start()
			
func completed() -> void:
	if Global.MONITOR_FAILED != 0 || Global.MONITOR_PASSED != 0:
		var color = "red" if Global.MONITOR_FAILED > 0 else "green"
		print_rich("[indent][color=%s]→ PASSED TESTS: %d/%d[/color][/indent]" % [color, Global.MONITOR_PASSED, Global.MONITOR_PASSED + Global.MONITOR_FAILED])
	print_rich("[color=orange] > SCENE TESTS ARE COMPLETED[/color]")
	Global.exit()
