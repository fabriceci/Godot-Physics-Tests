class_name PhysicsUnitTest2D
extends PhysicsTest2D

var parts: Array[Part]

func start() -> void:
	super()
	# Setup Part
	for child in get_children():
		if child is Part:
			parts.append(child)

func start_test_with_time_limit(p_time_limit):
	get_tree().create_timer(p_time_limit).timeout.connect(self._on_test_completed)

func _on_test_completed() -> void:
	for part in parts:
		var result =  "[color=green]SUCCESS[/color]" if part.call('is_test_passed') else "[color=red]FAILED[/color]"
		print_rich("[indent][indent] → %s : %s[/indent][/indent]" % [part.part_name(), result])
	process_mode = PROCESS_MODE_DISABLED
	completed.emit()
	queue_free()
