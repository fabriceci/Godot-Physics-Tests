class_name PhysicsUnitTest2D
extends PhysicsTest2D

var monitors: Array[Monitor]

func start() -> void:
	super()
	# Setup Monitor
	for child in get_children():
		if child is Monitor:
			monitors.append(child)

func start_test_with_time_limit(p_time_limit):
	get_tree().create_timer(p_time_limit).timeout.connect(self._on_test_completed)

func _on_test_completed() -> void:
	for monitor in monitors:
		if monitor.has_method("is_test_passed"):
			var passed:bool = monitor.call("is_test_passed")
			if not passed:
				Global.HAS_ERROR = true
			var result =  "[color=green]SUCCESS[/color]" if passed else "[color=red]FAILED[/color]"
			output += "[indent][indent] → %s : %s[/indent][/indent]\n" % [monitor.monitor_name(), result]
		elif monitor.has_method("get_score"):
			output += "[indent][indent] → %s : score [b]%f[/b][/indent][/indent]\n" % [monitor.monitor_name(), monitor.call("get_score")]
		else:
			@warning_ignore(assert_always_false)
			assert(false, "Monitor without is_test_passed or get_score method")
	print_rich(output)
	process_mode = PROCESS_MODE_DISABLED
	completed.emit()
	queue_free()
