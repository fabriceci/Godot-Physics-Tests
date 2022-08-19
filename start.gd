extends Node2D

var request_quit := false
@export var mode: Global.TEST_MODE = Global.TEST_MODE.REGRESSION
var runner: TestRunner
var start_time := 0.0

func _init():
	runner = TestRunner.new(self)
	runner.completed.connect(self.completed)
	## Get Arguments
	var arguments = {}
	for argument in OS.get_cmdline_args():
		if argument.find("=") > -1:
			var key_value = argument.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]
		else: # Options without an argument 
			arguments[argument.lstrip("--")] = ""
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var test_folder := []
	if mode == Global.TEST_MODE.REGRESSION:
		test_folder.append_array(["nodes", "features"])
	elif mode == Global.TEST_MODE.PERFORMANCE:
		test_folder.append("nodes")
		Global.MAXIMUM_PARALLEL_TESTS = 1
		Global.NUMBER_TEST_PER_ROW = 1
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	elif mode == Global.TEST_MODE.QUALITY:
		test_folder.append("quality")

	var result = {}
	for folder in test_folder:
		find_test(result, folder)
	
	for key in result:
		for scene_file in result[key]:
			var scene: TestScene = load(scene_file).instantiate()	
			for child in scene.get_children():
				if child is PhysicsTest2D:
					runner.add_test(child)
			scene.queue_free()
	
	print_rich("[color=orange] > MODE: [b]%s[/b] → [b]%d[/b] TESTS FOUNDS[/color]\n" % [Global.TEST_MODE.keys()[mode], runner.total_tests])
	start_time = Time.get_unix_time_from_system()
	runner.start()

func _physics_process(_delta: float) -> void:
	if request_quit:
		# Sometimes, it goes out before the printing occurs.
		for i in range(10):
			await get_tree().physics_frame
		var error_code = 1 if Global.MONITOR_FAILED > 0 else 0
		get_tree().quit(error_code)

func find_test(result: Dictionary, folder: String) -> void:
	var dir = Directory.new()
	var path = "res://tests/" + folder  + "/";

	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
	
		while file_name != "":
			var test_dir =  Directory.new()
			var dir_path = dir.get_current_dir().plus_file(file_name)
			if test_dir.open(dir_path) == OK:
				test_dir.list_dir_begin()
				var test_file_name = test_dir.get_next()
				var test_scene_list = []
				while test_file_name != "":
					var test_path = test_dir.get_current_dir().plus_file(test_file_name)
					if test_path.ends_with(".tscn"):
						test_scene_list.append(test_path)
					test_file_name = test_dir.get_next()
				if not test_scene_list.is_empty():
					result[file_name] = test_scene_list
			else:
				print_rich("[color:red]Failed to open the directory: [/color] % [dir_path]")
				@warning_ignore(assert_always_false)
				assert(false, "Failed to read the directory")
			file_name = dir.get_next()

func completed() -> void:
	var duration = Time.get_unix_time_from_system() - start_time
	if Global.MONITOR_FAILED != 0 || Global.MONITOR_PASSED != 0:
		var color = "red" if Global.MONITOR_FAILED > 0 else "green"
		var status = "FAILED" if Global.MONITOR_FAILED > 0 else "PASSED"
		print_rich("[color=orange] > COMPLETED IN %.2fs, PASSED MONITORS: %d/%d, STATUS: [color=%s]%s[/color]" % [duration, Global.MONITOR_PASSED, Global.MONITOR_PASSED + Global.MONITOR_FAILED, color, status])
	else:
		print_rich("[color=orange] > COMPLETED IN %.2fs[/color]" % [duration])
	request_quit = true
