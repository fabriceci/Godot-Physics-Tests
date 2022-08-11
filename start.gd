extends Node2D

var request_quit := false
@export var mode: Global.TEST_MODE = Global.TEST_MODE.REGRESSION
var runner: TestRunner

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

func completed() -> void:
	print_rich("[color=orange]--- ALL TESTS ARE COMPLETED ---[/color]")
	request_quit = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var test_folder := []
	if mode == Global.TEST_MODE.REGRESSION:
		test_folder.append_array(["nodes", "features"])
	elif mode == Global.TEST_MODE.PERFORMANCE:
		test_folder.append("nodes")
		Global.MAXIMUM_PARALLEL_TESTS = 1
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
	
	print_rich("[color=orange]--- MODE: [b]%s[/b] → [b]%d[/b] TESTS FOUNDS ---[/color]\n" % [Global.TEST_MODE.keys()[mode], runner.total_tests])
	runner.start()

func _physics_process(_delta: float) -> void:
	if request_quit:
		# Sometimes, it goes out before the printing occurs.
		await get_tree().physics_frame
		await get_tree().physics_frame
		await get_tree().physics_frame
		var error_code = 1 if Global.HAS_ERROR else 0
		get_tree().quit(error_code)

func find_test(result: Dictionary, folder: String) -> void:
	var dir = Directory.new()
	var path = "res://tests/" + folder  + "/";

	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
	
		while file_name != "":
			var test_dir =  Directory.new()
			if test_dir.open(dir.get_current_dir() + file_name) == OK:
				test_dir.list_dir_begin()
				var test_file_name = test_dir.get_next()
				var test_scene_list = []
				while test_file_name != "":
					var test_path = test_dir.get_current_dir() + "/" + test_file_name
					if test_path.ends_with(".tscn"):
						test_scene_list.append(test_path)
					test_file_name = test_dir.get_next()
				if not test_scene_list.is_empty():
					result[file_name] = test_scene_list
			file_name = dir.get_next()
