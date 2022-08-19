class_name PhysicsUnitTest2D
extends PhysicsTest2D

var monitors: Array[Monitor]
var monitor_completed := 0

func register_monitors(p_monitors: Array[Monitor], p_owner: Node, p_start:= true):
	for monitor in p_monitors:
		monitors.append(monitor)
		monitor.completed.connect(self.on_monitor_completed)
		p_owner.add_child(monitor)
		monitor.owner = p_owner
		monitor.target = p_owner
		if p_start:
			monitor.start()

func on_monitor_completed() -> void:
	monitor_completed += 1
	if monitor_completed == monitors.size():
		test_completed()

func test_completed() -> void:
	super()
	var contain_error = false
	for monitor in monitors:
		if not contain_error and not monitor.call("is_test_passed"):
			contain_error = true
			output += "\t\t > %s" % [test_description()]
	
	for monitor in monitors:
		if monitor.has_method("is_test_passed"):
			var passed:bool = monitor.call("is_test_passed")
			if passed:
				Global.MONITOR_PASSED += 1
			else:
				Global.MONITOR_FAILED += 1

			var result =  "[color=green]✓[/color]" if passed else "[color=red]✗[/color]"
			output += "[indent][indent] → %s : %s[/indent][/indent]\n" % [monitor.monitor_name(), result]
			if not passed and monitor.error_message != "" :
				output += "[color=red][indent][indent] %s [/indent][/indent][/color]\n" % [monitor.error_message]
		elif monitor.has_method("get_score"):
			output += "[indent][indent] → %s : score [b]%f[/b][/indent][/indent]\n" % [monitor.monitor_name(), monitor.call("get_score")]
		else:
			@warning_ignore(assert_always_false)
			assert(false, "Monitor without is_test_passed or get_score method")
	print_rich(output)
	process_mode = PROCESS_MODE_DISABLED
	completed.emit()
	if get_tree().get_root() == get_parent(): # autostart is the scene is alone
		for i in range(10):
			await get_tree().physics_frame
		get_tree().quit()
	else:
		queue_free()

func create_generic_monitor(p_target: Node, p_test_step_lamba,  p_cbk_lambda = null, p_maximum_duration := 5.0, p_auto_start:= true,  p_mode = GenericMonitor.STEP_MODE.AUTO) -> GenericMonitor:
	var instance = load("res://base/monitors/generic_monitor.gd").new()
	register_monitors([instance as Monitor], p_target, p_auto_start)
	instance.setup(p_test_step_lamba, p_cbk_lambda, p_maximum_duration, p_mode)
	return instance

func create_generic_manual_monitor(p_target: Node, p_test_lamba, p_maximum_duration := 5.0, p_auto_start:= true) -> GenericMonitor:
	return create_generic_monitor(p_target, p_test_lamba, null, p_maximum_duration, p_auto_start, GenericMonitor.STEP_MODE.MANUAL)

func create_generic_expiration_monitor(p_target: Node, p_test_lamba, p_maximum_duration := 5.0, p_auto_start:= true) -> GenericMonitor:
	return create_generic_monitor(p_target, p_test_lamba, null, p_maximum_duration, p_auto_start, GenericMonitor.STEP_MODE.EXPIRATION)
