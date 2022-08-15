class_name PhysicsUnitTest2D
extends PhysicsTest2D

var monitors: Array[Monitor]

func start() -> void:
	super()

func setup_monitors(p_monitors: Array[Monitor], p_owner: Node, p_start:= true):
	for monitor in p_monitors:
		monitors.append(monitor)
		p_owner.add_child(monitor)
		monitor.owner = p_owner
		monitor.target = p_owner
		if p_start:
			monitor.start()

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
			if monitor.error_message :
				output += "[color=red][indent][indent] - %s [/indent][/indent][/color]" % [monitor.error_message]
		elif monitor.has_method("get_score"):
			output += "[indent][indent] → %s : score [b]%f[/b][/indent][/indent]\n" % [monitor.monitor_name(), monitor.call("get_score")]
		else:
			@warning_ignore(assert_always_false)
			assert(false, "Monitor without is_test_passed or get_score method")
	print_rich(output)
	process_mode = PROCESS_MODE_DISABLED
	completed.emit()
	queue_free()
