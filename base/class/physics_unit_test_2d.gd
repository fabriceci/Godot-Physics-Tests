class_name PhysicsUnitTest2D
extends PhysicsTest2D

var monitors: Array[Monitor]
var monitor_completed := 0

func start() -> void:
	super()

func setup_monitors(p_monitors: Array[Monitor], p_owner: Node, p_start:= true):
	for monitor in p_monitors:
		monitors.append(monitor)
		monitor.completed.connect(self.on_monitor_completed)
		p_owner.add_child(monitor)
		monitor.owner = p_owner
		monitor.target = p_owner
		if p_start:
			monitor.start()

#func start_test_with_time_limit(p_time_limit):
#	get_tree().create_timer(p_time_limit).timeout.connect(self.on_test_completed)

func on_monitor_completed() -> void:
	monitor_completed += 1
	if monitor_completed == monitors.size():
		on_test_completed()

func on_test_completed() -> void:
	for monitor in monitors:
		if monitor.has_method("is_test_passed"):
			var passed:bool = monitor.call("is_test_passed")
			if passed:
				Global.MONITOR_PASSED += 1
			else:
				Global.MONITOR_FAILED += 1
			var result =  "[color=green]✓[/color]" if passed else "[color=red]FAILED[/color]"
			output += "[indent][indent] → %s : %s[/indent][/indent]\n" % [monitor.monitor_name(), result]
			if not passed and monitor.error_message != "" :
				output += "[color=red][indent][indent] %s [/indent][/indent][/color]" % [monitor.error_message]
		elif monitor.has_method("get_score"):
			output += "[indent][indent] → %s : score [b]%f[/b][/indent][/indent]\n" % [monitor.monitor_name(), monitor.call("get_score")]
		else:
			@warning_ignore(assert_always_false)
			assert(false, "Monitor without is_test_passed or get_score method")
	print_rich(output)
	process_mode = PROCESS_MODE_DISABLED
	completed.emit()
	if get_tree().get_root() == get_parent(): # autostart is the scene is alone
		await get_tree().physics_frame
		await get_tree().physics_frame
		await get_tree().physics_frame
		get_tree().quit()
	else:
		queue_free()
